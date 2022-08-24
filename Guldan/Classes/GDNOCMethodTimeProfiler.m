//
//  GDNOCMethodTimeProfiler.m
//  Pods
//
//  Created by Alex023 on 2021/11/15.
//

#import "GDNOCMethodTimeProfiler.h"
#import "gdn_objc_msgSend_time_profiler.h"
#import "GDNUIModel.h"
#import "GDNRecordHierarchyModel.h"

NSNotificationName const GDNRecordsDataDidReadyNotification = @"gdn.records.data.did.ready";

@interface GDNOCMethodTimeProfiler ()
@property (nonatomic, strong)NSMutableArray<GDNUIModel *> *modelArr;
@end

@implementation GDNOCMethodTimeProfiler

+ (instancetype)defaultProfiler {
    static dispatch_once_t onceToken;
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)start {
    [[GDNOCMethodTimeProfiler defaultProfiler] startProfiler];
}

+ (void)stop {
    [[GDNOCMethodTimeProfiler defaultProfiler] stopProfiler];
}

+ (NSMutableArray<GDNUIModel *> *)modelsArr {
    return [GDNOCMethodTimeProfiler defaultProfiler].modelArr;
}

+ (void)handleRecordsWithComplete:(void (^)(NSArray<NSString *> *filePaths))onComplete {
    [[GDNOCMethodTimeProfiler defaultProfiler] handleRecordsWithComplete:onComplete];
}

#pragma mark - Private

- (void)startProfiler {
#if defined(__arm64__)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gdn_timeProfilerPreprocess();
    });
    gdn_timeProfilerStart(YES, YES);
#endif
}

- (void)stopProfiler {
#if defined(__arm64__)
    gdn_timeProfilerStop();
#endif
}

- (void)handleRecordsWithComplete:(void (^)(NSArray<NSString *> *filePaths))onComplete {
#if defined(__arm64__)
    if (!onComplete) {
        return;
    }
    gdn_handleRecordsWithComplete(^(NSArray<NSString *> *filePaths1) {
        onComplete(filePaths1);
    }, ^(NSArray *allMethodRecords) {
        GDNUIModel *model = [[GDNUIModel alloc] init];
        NSArray *records = [[NSArray alloc] initWithArray:allMethodRecords copyItems:YES];
        model.sequentialMethodRecord = records;
        model.costTimeSortMethodRecord = [self sortRecordByCostTime:records];
        model.callCountSortMethodRecord = [self sortRecordByCallCount:records];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.modelArr addObject:model];
            [[NSNotificationCenter defaultCenter] postNotificationName:GDNRecordsDataDidReadyNotification object:nil];
        });
    });
#endif
}

- (NSArray *)sortRecordByCostTime:(NSArray *)arr {
    NSArray *sortArr = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        GDNRecordHierarchyModel *model1 = (GDNRecordHierarchyModel *)obj1;
        GDNRecordHierarchyModel *model2 = (GDNRecordHierarchyModel *)obj2;
        if (model1.rootMethod.costTime > model2.rootMethod.costTime) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    for (GDNRecordHierarchyModel *model in sortArr) {
        model.isExpand = NO;
    }
    return sortArr;
}


- (NSArray *)sortRecordByCallCount:(NSArray *)arr {
    NSMutableArray *arrM = [NSMutableArray array];
    for (GDNRecordHierarchyModel *model in arr) {
        [self addRecord:model.rootMethod to:arrM];
        if ([model.subMethods isKindOfClass:NSArray.class]) {
            for (GDNRecordModel *recoreModel in model.subMethods) {
                [self addRecord:recoreModel to:arrM];
            }
        }
    }
    
    NSArray *sortArr = [arrM sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        GDNRecordModel *model1 = (GDNRecordModel *)obj1;
        GDNRecordModel *model2 = (GDNRecordModel *)obj2;
        if (model1.callCount > model2.callCount) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    return sortArr;
}

- (void)addRecord:(GDNRecordModel *)model to:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count; i++) {
        GDNRecordModel *temp = arr[i];
        if ([temp isEqualRecordModel:model]) {
            temp.callCount++;
            return;
        }
    }
    model.callCount = 1;
    [arr addObject:model];
}

- (NSMutableArray<GDNUIModel *> *)modelArr {
    if (!_modelArr) {
        _modelArr = [NSMutableArray array];
    }
    return _modelArr;
}

@end
