//
//  JCCommentCell.h
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JCMomentResponseModel;
@class JCMomentQuotoModel;

@interface JCCommentCell : UITableViewCell

@property (nonatomic, copy) void(^longPressHandle)(JCMomentResponseModel *responseModel);

- (void)setMomentResponseModel:(JCMomentResponseModel *)model
                 currentUserID:(NSString *)currentUserID;

@end

