//
//  JCMomentCell.h
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCMomentSetting.h"
#import "JCMomentEnum.h"
@class JCMomentsModel;
@class JCMomentCell;


@protocol JCMomentCellDelegate <NSObject>

/**
 点击事件代理
 @params    momentCell       Cell
 @params    actionType       点击类型
 @params    momentModel      数据模型
 */
- (void)momentCellDidTapAction:(JCMomentCell *)momentCell
                    actionType:(MomentTapActionType) actionType
                    momentMode:(JCMomentsModel *)momentModel
             responseIndexPath:(NSIndexPath *) responseIndex;

@end

@interface JCMomentCell : UITableViewCell

@property (nonatomic, strong) UIImage *commentBackImage;
@property (nonatomic, strong) UIColor *nameColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *watchMoreButtonColor;
@property (nonatomic, strong) UIColor *addressColor;
@property (nonatomic, strong) UIColor *timeColor;
@property (nonatomic, strong) UIColor *viewColor;
@property (nonatomic, strong) UIColor *headerLayerColor;
@property (nonatomic, assign) CGFloat headerborderWidth;
@property (nonatomic, strong) UIColor *commentCutLineBackColor;

@property (nonatomic, copy) void(^clickVideoBlock)(NSURL *videoURL);
/**
 赋予数据
 @params    model           数据模型
 @params    indexPath       索引
 @params    delegate        代理
 */
- (void)setModel:(JCMomentsModel *)model
       indexPath:(NSIndexPath *)indexPath
        delegate:(id<JCMomentCellDelegate>)delegate
headerPlaceholdImage:(UIImage *)headerPlaceholdImage
momentPlaceholdImage:(UIImage *)momentPlaceholdImage;

@end
