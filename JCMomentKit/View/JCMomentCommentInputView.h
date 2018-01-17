//
//  JCMomentCommentInputView.h
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCMomentCommentInputView : UIView

@property (nonatomic, copy) void(^inputComplete)(NSString *inputString);
- (void)updateFrame:(CGRect)frame withTime:(CGFloat) time;
- (void)editState:(BOOL) editState;
- (void)setPlaceHoldString:(NSString *)placeHoldString;

@end
