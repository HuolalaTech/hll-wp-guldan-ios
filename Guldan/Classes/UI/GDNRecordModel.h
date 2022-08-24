//
//  GDNRecordModel.h
//  Guldan
//
//  Created by Alex023 on 2022/4/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDNRecordModel : NSObject<NSCopying>

@property (nonatomic, strong) Class cls;
@property (nonatomic) SEL sel;
@property (nonatomic, assign) uint64_t costTime; //单位：纳秒（百万分之一秒）
@property (nonatomic, assign) int depth;

// 辅助堆栈排序
@property (nonatomic, assign) int total;

//call 次数
@property (nonatomic, assign) int callCount;

- (instancetype)initWithCls:(Class)cls sel:(SEL)sel time:(uint64_t)costTime depth:(int)depth total:(int)total;

- (BOOL)isEqualRecordModel:(GDNRecordModel *)model;

@end

NS_ASSUME_NONNULL_END
