//
//  JCCommentCell.m
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import "JCCommentCell.h"
#import <YYKit/YYKit.h>
#import "JCMomentsModel.h"

@interface JCCommentCell ()
@property (weak, nonatomic) IBOutlet YYLabel *commentLabel;
@property (strong, nonatomic) JCMomentResponseModel *model;
@property (copy, nonatomic) NSString *currentUserID;
@end

@implementation JCCommentCell

- (void)setMomentResponseModel:(JCMomentResponseModel *)model
                 currentUserID:(NSString *)currentUserID{
    _model = model;
    _currentUserID = currentUserID;
    _commentLabel.attributedText = model.commentString;  //设置富文本
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _commentLabel.numberOfLines = 0;
    _commentLabel.displaysAsynchronously = YES;
    _commentLabel.textAlignment = NSTextAlignmentCenter;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];
    _commentLabel.displaysAsynchronously = YES;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)sender{
    BOOL isMyComment = [_model.rUserID isEqualToString:self.currentUserID];
    BOOL isMyTopic = [_model.momentModel.userID isEqualToString:self.currentUserID];
    BOOL isResponseMyComment = [_model.quote.userID isEqualToString:self.currentUserID];
    BOOL isAllowDelete = NO;
    if (isMyTopic) {///是我发布的帖子
        if (isMyComment) {
            ///自己的评论
            isAllowDelete = YES;
        }else{
            ///别人的评论
            isAllowDelete = YES;
        }
    }else{///不是我发布的帖子
        if (isMyComment) {
            ///自己的评论
            isAllowDelete = YES;
        }else{
            ///别人的评论
            
        }
    }
    if (isAllowDelete) {
        if (_longPressHandle) {
            _longPressHandle(_model);
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

