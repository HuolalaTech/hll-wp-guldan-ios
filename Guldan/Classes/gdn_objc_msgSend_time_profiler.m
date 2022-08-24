//
//  gdn_objc_msgSend_time_profiler.m
//  Pods
//
//  Created by Alex023 on 2021/11/15.
//

#if defined(__arm64__)

#import "gdn_objc_msgSend_time_profiler.h"
#import <stdlib.h>
#import <stdio.h>
#import <string.h>
#import <assert.h>
#import <pthread.h>
#import <dispatch/once.h>
#import <objc/objc.h>
#import <objc/runtime.h>
#include <sys/time.h>
#import "HLLFishhook.h"
#import "gdn_objc_msgSend.h"
#import "GDNRecordModel.h"
#import "GDNRecordHierarchyModel.h"
#import <mach/mach.h>

#define STACK_ENTRY_SIZE 800000
#define MSG_SEND_INFO_SIZE 50
#define GDN_MAX_THREAD_ID   400000

id (*origin_objc_msgSend)(id self, SEL _cmd, ...);

#pragma mark - Struct Define
typedef struct {
    void *cls;
    char *cmd;
    double start_time;
    double consume_time;
    double shallow_consume_time;
    unsigned long stack_depth;
} gdn_stack_entry_t;

typedef struct {
    void *cls;
    char *cmd;
    double start_time;
    void *lr;
    double total_consume_time;
} gdn_msgsend_info_t;

typedef struct {
    unsigned int stack_depth;
    unsigned int stack_entry_count;
    unsigned int stack_entry_count_max;
    gdn_stack_entry_t stackEntries[STACK_ENTRY_SIZE];
    gdn_msgsend_info_t msgsendInfos[MSG_SEND_INFO_SIZE];
} gdn_thread_info_t;

gdn_thread_info_t *g_mainThreadInfo;
static void *g_main_thread_get_class_result;

void *g_classAddressMin;
void *g_classAddressMax;

static gdn_thread_info_t **g_threadInfos;
static unsigned int g_mainThreadID;
static bool g_trace_enabled = false;
static bool g_traceChildThread = false;
static bool g_traceSystemOnMainThread = false;
static uint64_t g_timeThreshold = 100; //unit:ms

double currentTimestamp(void) {
    static double timeCoefficient;
    static double baseTimestamp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mach_timebase_info_data_t s_timebase_info;
        mach_timebase_info(&s_timebase_info);
        timeCoefficient = 1.0 * s_timebase_info.numer / (1e9 * s_timebase_info.denom);
        baseTimestamp = mach_absolute_time() * timeCoefficient;
    });
    return mach_absolute_time() * timeCoefficient - baseTimestamp;
}

NSUInteger findStartDepthIndex(NSUInteger start, NSArray *arr) {
    NSUInteger index = start;
    if (arr.count > index) {
        GDNRecordModel *model = arr[index];
        int minDepth = model.depth;
        int minTotal = model.total;
        for (NSUInteger i = index+1; i < arr.count; i++) {
            GDNRecordModel *tmp = arr[i];
            if (tmp.depth < minDepth || (tmp.depth == minDepth && tmp.total < minTotal)) {
                minDepth = tmp.depth;
                minTotal = tmp.total;
                index = i;
            }
        }
    }
    return index;
}

NSArray *recursive_getRecord(NSMutableArray *arr) {
    if ([arr isKindOfClass:NSArray.class] && arr.count > 0) {
        BOOL isValid = YES;
        NSMutableArray *recordArr = [NSMutableArray array];
        NSMutableArray *splitArr = [NSMutableArray array];
        NSUInteger index = findStartDepthIndex(0, arr);
        if (index > 0) {
            [splitArr addObject:[NSMutableArray array]];
            for (int i = 0; i < index; i++) {
                [[splitArr lastObject] addObject:arr[i]];
            }
        }
        GDNRecordModel *model = arr[index];
        [recordArr addObject:model];
        [arr removeObjectAtIndex:index];
        int startDepth = model.depth;
        int startTotal = model.total;
        for (NSUInteger i = index; i < arr.count; ) {
            model = arr[i];
            if (model.total == startTotal && model.depth - 1 == startDepth) {
                [recordArr addObject:model];
                [arr removeObjectAtIndex:i];
                startDepth++;
                isValid = YES;
            } else {
                if (isValid) {
                    isValid = NO;
                    [splitArr addObject:[NSMutableArray array]];
                }
                [[splitArr lastObject] addObject:model];
                i++;
            }
            
        }
        
        for (NSUInteger i = splitArr.count; i > 0; i--) {
            NSMutableArray *sArr = splitArr[i - 1];
            [recordArr addObjectsFromArray:recursive_getRecord(sArr)];
        }
        return recordArr;
    }
    return @[];
}

void setRecordDicWithRecord(NSMutableArray *arr, gdn_stack_entry_t stackEntry) {
    if ([arr isKindOfClass:NSMutableArray.class]) {
        int total = 1;
        for (NSUInteger i = 0; i < arr.count; i++)
        {
            GDNRecordModel *model = arr[i];
            if (model.depth == stackEntry.stack_depth) {
                total = model.total + 1;
                break;
            }
        }
        GDNRecordModel *model = [[GDNRecordModel alloc] initWithCls:(__bridge Class _Nullable)stackEntry.cls sel:(SEL)stackEntry.cmd time:stackEntry.consume_time * 1e6 depth:(int)stackEntry.stack_depth total:total];
        [arr insertObject:model atIndex:0];
    }
}

#pragma mark - Core

gdn_thread_info_t *get_thread_info(unsigned int thread_id) {
    assert(thread_id < GDN_MAX_THREAD_ID);
    gdn_thread_info_t *threadInfo = g_threadInfos[thread_id];
    if (threadInfo == NULL) {
        threadInfo = (gdn_thread_info_t *)calloc(1, sizeof(gdn_thread_info_t));
        threadInfo->stack_entry_count_max = STACK_ENTRY_SIZE;
        threadInfo->stack_depth = 0;
        threadInfo->stack_entry_count = 0;
        g_threadInfos[thread_id] = threadInfo;
    }
    return threadInfo;
}

void pre_objc_msgSend(void *obj, char *cmd, void *lr) {
    gdn_thread_info_t *threadInfo = NULL;
    unsigned int currentStackDepth = 0;
    if (pthread_main_np()) {
        threadInfo = g_mainThreadInfo;
        currentStackDepth = threadInfo->stack_depth;
        threadInfo->msgsendInfos[currentStackDepth] = ((gdn_msgsend_info_t){g_main_thread_get_class_result, cmd, currentTimestamp(), lr, 0});
    } else {
        unsigned int thread_id = pthread_mach_thread_np(pthread_self());
        threadInfo = get_thread_info(thread_id);
        currentStackDepth = threadInfo->stack_depth;
        threadInfo->msgsendInfos[currentStackDepth] = (gdn_msgsend_info_t){(__bridge void *)object_getClass((__bridge id)obj), cmd, currentTimestamp(), lr, 0};
    }
    threadInfo->stack_depth = currentStackDepth + 1;
}

void *post_objc_msgSend(void) {
    gdn_thread_info_t *threadInfo = NULL;
    if (pthread_main_np()) {
        threadInfo = g_mainThreadInfo;
    } else {
        unsigned int thread_id = pthread_mach_thread_np(pthread_self());
        threadInfo = get_thread_info(thread_id);
    }
    
    threadInfo->stack_depth -= 1;
    int currentStackDepth = threadInfo->stack_depth;
    gdn_msgsend_info_t *msgsendInfo = &threadInfo->msgsendInfos[currentStackDepth];
    
    if (threadInfo->stack_entry_count < threadInfo->stack_entry_count_max && g_trace_enabled) {
        double consume_time = currentTimestamp() - msgsendInfo->start_time;
        int lastStackDepth = currentStackDepth - 1;
        if (lastStackDepth >= 0) {
            gdn_msgsend_info_t *last_msgsendInfo = &threadInfo->msgsendInfos[lastStackDepth];
            last_msgsendInfo->total_consume_time += consume_time;
        }
        double shallow_consume_time = consume_time - msgsendInfo->total_consume_time;
        if (pthread_main_np()) {
            if (consume_time * 1e6 > g_timeThreshold) {
                threadInfo->stackEntries[threadInfo->stack_entry_count] = ((gdn_stack_entry_t){msgsendInfo->cls, msgsendInfo->cmd, msgsendInfo->start_time, consume_time, currentStackDepth, shallow_consume_time});
                threadInfo->stack_entry_count++;
            }
        } else {
            threadInfo->stackEntries[threadInfo->stack_entry_count] = ((gdn_stack_entry_t){msgsendInfo->cls, msgsendInfo->cmd, msgsendInfo->start_time, consume_time, currentStackDepth, shallow_consume_time});
            threadInfo->stack_entry_count++;
        }
    }
    return msgsendInfo->lr;
}

static void * g_NSObjectAddress;
bool needs_profiler(void *obj) {
    if (!g_trace_enabled) {
        return false;
    }
    void *class_address = (__bridge void *)object_getClass((__bridge id)obj);
    if (pthread_main_np()) {
        g_main_thread_get_class_result = class_address;
        if (g_traceSystemOnMainThread) {
            return true;
        }
    } else {
        if (!g_traceChildThread) {
            return false;
        }
    }
    
    // 非系统库
    while (class_address != nil && class_address != g_NSObjectAddress) {
        if (class_address >= g_classAddressMin && class_address <= g_classAddressMax) {
            return true;
        }
        class_address = (__bridge void *)class_getSuperclass((__bridge Class _Nullable)(class_address));
    }
    
    return false;
}

#pragma mark - Public
void gdn_timeProfilerPreprocess() {
    assert(pthread_main_np());
    g_NSObjectAddress = (__bridge void *)(objc_getClass("NSObject"));
    g_threadInfos = (gdn_thread_info_t **)calloc(GDN_MAX_THREAD_ID, sizeof(gdn_thread_info_t *));
    g_mainThreadID = pthread_mach_thread_np(pthread_self());
    g_mainThreadInfo = get_thread_info(g_mainThreadID);
    
    // 只处理非系统库区间
    const char *exeImage = [[NSBundle mainBundle].executablePath UTF8String];
    unsigned int count = 0;
    const char **classNames = objc_copyClassNamesForImage(exeImage, &count);
    g_classAddressMin = (__bridge void *)objc_getClass(classNames[0]);
    g_classAddressMax = (__bridge void *)objc_getClass(classNames[count - 1]);
    free(classNames);
    
    rebind_symbols((struct rebinding[1]){{"objc_msgSend", (void *)gdn_objc_msgSend, (void **)&origin_objc_msgSend}}, 1);
}

void gdn_timeProfilerStart(bool traceChildThread, bool traceSystemOnMainThread) {
    assert(pthread_main_np());
    g_trace_enabled = true;
    g_traceChildThread = traceChildThread;
    g_traceSystemOnMainThread = traceSystemOnMainThread;
}

void gdn_timeProfilerStop() {
    g_trace_enabled = false;
}

void gdn_setTimeThreshold(uint64_t threshold) {
    g_timeThreshold = threshold;
}

void gdn_handleRecordsWithComplete(GDNProductFilesBlock onFiles, GDNMainThreadMethodRecords onRecords) {
    NSString *userRootDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSMutableArray *tmpFilePaths = [NSMutableArray array];
    
    for (int threadId = 0; threadId < GDN_MAX_THREAD_ID; threadId++) {
        gdn_thread_info_t *threadInfo = g_threadInfos[threadId];
        if (!threadInfo || threadInfo->stack_entry_count_max != STACK_ENTRY_SIZE) {
            continue;
        }

        NSMutableData *dataM = [NSMutableData data];
        BOOL isMainThread = (threadId == g_mainThreadID);
        NSString *threadName = isMainThread ? @"mainthread" : [NSString stringWithFormat:@"childthread_%d", threadId];
        unsigned int recordsCount = threadInfo->stack_entry_count;
        
        if (isMainThread) {
            NSMutableArray *allMethodRecords = [NSMutableArray array];
            unsigned int ii = 0, jj;
            while (ii < recordsCount) {
                @autoreleasepool {
                    NSMutableArray *methodRecord = [NSMutableArray array];
                    for (jj = ii; jj < recordsCount; jj++) {
                        gdn_stack_entry_t stackEntry = threadInfo->stackEntries[jj];
                        setRecordDicWithRecord(methodRecord, stackEntry);
                        if (stackEntry.stack_depth == 0 || jj == recordsCount - 1) {
                            NSArray *recordModels = recursive_getRecord(methodRecord);
                            if (recordModels.count > 0) {
                                GDNRecordHierarchyModel *model = [[GDNRecordHierarchyModel alloc] initWithRecordModels:recordModels];
                                [allMethodRecords addObject:model];
                            }
                            //退出循环
                            break;
                        }
                    }
                    ii = jj + 1;
                }
            }
             if (onRecords) {
                 onRecords(allMethodRecords);
            }
        }
        
        for (unsigned int i = 0; i < recordsCount; i++) {
            @autoreleasepool {
                gdn_stack_entry_t stackEntry = threadInfo->stackEntries[i];
                Class cls = (__bridge Class _Nullable)(stackEntry.cls);
                BOOL isClassMethod = class_isMetaClass(cls);
                const char *className = class_getName(cls);
                char *selName = stackEntry.cmd;
                
                if (cls && strlen(className) > 0 && strlen(selName) > 0) {
                    NSDictionary *pieceDic = @{
                        @"name": [NSString stringWithFormat:@"%@[%s %s]",(isClassMethod ? @"+" : @"-"), className, selName],
                        @"tname": threadName,
                        @"st": @(stackEntry.start_time * 1e6),
                        @"consume": @(stackEntry.consume_time * 1e6),
                        @"args": @{
                            @"stack_depth": @(stackEntry.stack_depth),
                            @"shallow_consume": @(stackEntry.shallow_consume_time * 1e6),
                        }
                    };
                    NSData *pieceData = [NSJSONSerialization dataWithJSONObject:pieceDic
                                                                    options:NSJSONWritingPrettyPrinted
                                                                      error:nil];
                    if (i == 0) {
                        [dataM appendData:[@"[" dataUsingEncoding:NSUTF8StringEncoding]];
                    } else if (i == recordsCount - 1) {
                        [dataM appendData:[@"]" dataUsingEncoding:NSUTF8StringEncoding]];
                    } else {
                        [dataM appendData:pieceData];
                        [dataM appendData:[@"," dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                }
            }
        }
        NSString *productName = [NSString stringWithFormat:@"oc_method_cost_%@", threadName];
        NSString *productPath = [userRootDir stringByAppendingPathComponent:productName];
        [tmpFilePaths addObject:productPath];
        [[NSFileManager defaultManager] createFileAtPath:productPath
                                                contents:dataM
                                              attributes:nil];
        threadInfo->stack_entry_count = 0;
        threadInfo->stack_depth = 0;
        if (!isMainThread) {
            free(threadInfo);
            g_threadInfos[threadId] = NULL;
        }
    }
    if (onFiles) {
        onFiles(tmpFilePaths);
    }
}

#endif  // __arm64__

