//
//  GDNRecordHierarchyModel.m
//  Guldan
//
//  Created by Alex023 on 2022/4/30.
//

#import "GDNRecordHierarchyModel.h"

@implementation GDNRecordHierarchyModel

- (instancetype)initWithRecordModels:(NSArray *)recordModels {
    self = [super init];
    if (self) {
        if ([recordModels isKindOfClass:NSArray.class] && recordModels.count > 0) {
            self.rootMethod = recordModels[0];
            self.isExpand = YES;
            if (recordModels.count > 1) {
                self.subMethods = [recordModels subarrayWithRange:NSMakeRange(1, recordModels.count-1)];
            }
        }
    }
    return self;
}

- (GDNRecordModel *)getRecordModel:(NSInteger)index {
    if (index==0) {
        return self.rootMethod;
    }
    return self.subMethods[index-1];
}

- (id)copyWithZone:(NSZone *)zone {
    GDNRecordHierarchyModel *model = [[[self class] allocWithZone:zone] init];
    model.rootMethod = self.rootMethod;
    model.subMethods = self.subMethods;
    model.isExpand = self.isExpand;
    return model;
}

@end
