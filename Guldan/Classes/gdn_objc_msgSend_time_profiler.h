//
//  gdn_objc_msgSend_time_profiler.h
//  Pods
//
//  Created by Alex023 on 2021/11/15.
//

#ifndef gdn_objc_msgSend_time_profiler_h
#define gdn_objc_msgSend_time_profiler_h

#if defined(__arm64__)

#import <objc/objc.h>

typedef void(^GDNProductFilesBlock)(NSArray<NSString *> *filePaths);
typedef void(^GDNMainThreadMethodRecords)(NSArray *allMethodRecords);

/// 预处理
void gdn_timeProfilerPreprocess(void);

/// 启动耗时分析
/// @param traceChildThread 是否trace子线程的方法执行
/// @param traceSystemOnMainThread 是否trace主线程中的系统方法
void gdn_timeProfilerStart(bool traceChildThread, bool traceSystemOnMainThread);

/// 停止耗时分析
void gdn_timeProfilerStop(void);

/// 方法耗时阈值
/// @param threshold 默认100ms
void gdn_setTimeThreshold(uint64_t threshold);

void gdn_handleRecordsWithComplete(GDNProductFilesBlock onFiles, GDNMainThreadMethodRecords onRecords);


#endif  // __arm64__
#endif /* gdn_objc_msgSend_time_profiler_h */
