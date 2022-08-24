//
//  GDNRecordHierarchyModel.h
//  Guldan
//
//  Created by Alex023 on 2022/4/30.
//

#import <Foundation/Foundation.h>
#import "GDNRecordModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GDNRecordHierarchyModel : NSObject<NSCopying>
@property (nonatomic, strong) GDNRecordModel *rootMethod;
@property (nonatomic, copy) NSArray *subMethods;
@property (nonatomic, assign) BOOL isExpand;   //是否展开所有的子函数

- (instancetype)initWithRecordModels:(NSArray *)recordModels;
- (GDNRecordModel *)getRecordModel:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
