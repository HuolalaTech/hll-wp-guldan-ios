//
//  GDNRecordModel.m
//  Guldan
//
//  Created by Alex023 on 2022/4/30.
//

#import "GDNRecordModel.h"

@implementation GDNRecordModel

- (instancetype)initWithCls:(Class)cls sel:(SEL)sel time:(uint64_t)costTime depth:(int)depth total:(int)total {
    self = [super init];
    if (self) {
        self.callCount = 0;
        self.cls = cls;
        self.sel = sel;
        self.costTime = costTime;
        self.depth = depth;
        self.total = total;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    GDNRecordModel *model = [[[self class]  allocWithZone:zone] init];
    model.cls = self.cls;
    model.sel = self.sel;
    model.costTime = self.costTime;
    model.depth = self.depth;
    model.total = self.total;
    model.callCount = self.callCount;
    return model;
}

- (BOOL)isEqualRecordModel:(GDNRecordModel *)model {
    if ([self.cls isEqual:model.cls] && self.sel == model.sel) {
        return YES;
    }
    return NO;
}
@end
