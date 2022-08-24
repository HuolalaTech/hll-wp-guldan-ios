//
//  GDNOCMethodTimeProfiler.h
//  Pods
//
//  Created by Alex023 on 2021/11/15.
//

#import <Foundation/Foundation.h>
#import "GDNOCMethodTimeProfilerProtocol.h"
@class GDNUIModel;

FOUNDATION_EXPORT NSNotificationName _Nonnull const GDNRecordsDataDidReadyNotification;

NS_ASSUME_NONNULL_BEGIN

@interface GDNOCMethodTimeProfiler : NSObject<GDNOCMethodTimeProfilerProtocol>

/// 启动
+ (void)start;

/// 结束
+ (void)stop;

+ (NSMutableArray<GDNUIModel *> *)modelsArr;
+ (void)handleRecordsWithComplete:(void (^)(NSArray<NSString *> *filePaths))onComplete;

@end

NS_ASSUME_NONNULL_END
