//
//  GDNOCMethodTimeProfilerProtocol.h
//  Pods
//
//  Created by Alex023 on 2021/11/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GDNOCMethodTimeProfilerProtocol <NSObject>

@required

- (void)startProfiler;

- (void)stopProfiler;

- (void)handleRecordsWithComplete:(void (^)(NSArray<NSString *> *filePaths))onComplete;

@end

NS_ASSUME_NONNULL_END
