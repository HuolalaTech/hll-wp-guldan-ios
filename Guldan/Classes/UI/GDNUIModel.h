//
//  GDNUIModel.h
//  Guldan
//
//  Created by Alex023 on 2022/4/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDNUIModel : NSObject
@property (nonatomic, copy) NSArray *sequentialMethodRecord;
@property (nonatomic, copy) NSArray *costTimeSortMethodRecord;
@property (nonatomic, copy) NSArray *callCountSortMethodRecord;
@end

NS_ASSUME_NONNULL_END
