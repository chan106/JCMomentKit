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
- (void)sendButtonBackColor:(UIColor *)backColor
                   tinColor:(UIColor *)tinColor
                borderColor:(UIColor *)borderColor;
- (void)inputViewBorderColor:(UIColor *) inputBorderColor
              placeholdColor:(UIColor *) placeholdColor
                   textColor:(UIColor *) textColor;
- (void)updateFrame:(CGRect)frame withTime:(CGFloat) time;
- (void)editState:(BOOL) editState;
- (void)setPlaceHoldString:(NSString *)placeHoldString;

@end
