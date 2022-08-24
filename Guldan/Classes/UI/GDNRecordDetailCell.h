//
//  GDNRecordDetailCell.h
//  Guldan
//
//  Created by Alex023 on 2022/4/30.
//

#import <UIKit/UIKit.h>
@class GDNRecordDetailCell;
@class GDNRecordModel;

NS_ASSUME_NONNULL_BEGIN

@protocol GDNRecordDetailCellDelegate <NSObject>

- (void)recordCell:(GDNRecordDetailCell *)cell clickExpandWithSection:(NSInteger)section;

@end

@interface GDNRecordDetailCell : UITableViewCell

@property (nonatomic, weak) id<GDNRecordDetailCellDelegate> delegate;

- (void)bindRecordModel:(GDNRecordModel *)model
      isHiddenExpandBtn:(BOOL)isHidden
               isExpand:(BOOL)isExpand
                section:(NSInteger)section
        isCallCountType:(BOOL)isCallCountType;
@end

NS_ASSUME_NONNULL_END
