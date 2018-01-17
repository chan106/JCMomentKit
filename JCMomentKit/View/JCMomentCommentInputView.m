//
//  JCMomentCommentInputView.m
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import "JCMomentCommentInputView.h"
#import "YYKit.h"
#import "JCMomentKit.h"

@interface JCMomentCommentInputView()<YYTextViewDelegate>

@property (weak, nonatomic) IBOutlet YYTextView *inputView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewHeight;
@property (assign, nonatomic) CGRect tempFrame;

@end

@implementation JCMomentCommentInputView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)updateFrame:(CGRect)frame withTime:(CGFloat) time{
    _inputViewWidth.constant = frame.size.width - 85;
    _inputViewHeight.constant = frame.size.height - 16;
    [UIView animateKeyframesWithDuration:time delay:0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
        self.frame = frame;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    _tempFrame = frame;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    _inputView.layer.cornerRadius = 3;
    _inputView.layer.masksToBounds = YES;
    _inputView.layer.borderColor = MomentColorFromHex(0xcccccc).CGColor;
    _inputView.layer.borderWidth = 0.5;
    _inputView.font = [UIFont systemFontOfSize:15];
    _inputView.returnKeyType = UIReturnKeySend;
    _inputView.placeholderFont = _inputView.font = [UIFont systemFontOfSize:kTextFont];
    _inputView.placeholderTextColor = MomentColorFromHex(0x999999);
    _inputView.textColor = [UIColor blackColor];
    _inputView.delegate = self;
    _inputView.returnKeyType = UIReturnKeySend;
    _inputView.enablesReturnKeyAutomatically = YES;
    
    _sendButton.layer.cornerRadius = 3;
    _sendButton.layer.masksToBounds = YES;
    _sendButton.layer.borderColor = MomentColorFromHex(0xcccccc).CGColor;
    _sendButton.layer.borderWidth = 0.5;
    _sendButton.backgroundColor = [UIColor clearColor];
    _sendButton.enabled = NO;
    [_sendButton setTitleColor:MomentColorFromHex(0x999999) forState:UIControlStateNormal];
}

- (void)editState:(BOOL)editState{
    if (editState) {
        [_inputView becomeFirstResponder];
    }else{
        [_inputView resignFirstResponder];
    }
}

#pragma mark -- YYTextView代理
- (void)textViewDidChange:(YYTextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        _sendButton.layer.borderWidth = 0.5;
        _sendButton.backgroundColor = [UIColor clearColor];
        _sendButton.enabled = NO;
        [_sendButton setTitleColor:MomentColorFromHex(0x999999) forState:UIControlStateNormal];
    }else{
        _sendButton.layer.borderWidth = 0;
        _sendButton.enabled = YES;
        _sendButton.backgroundColor = MomentColorFromHex(0xec6c00);
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    YYTextLayout *layout = textView.textLayout;
    CGFloat height = MIN(layout.textBoundingSize.height, kInputViewMinHeight);
    height = MAX(18+height, kInputViewMinHeight);
    CGRect frame = self.frame;
    frame.size.height = height;
//    frame.origin.y -= (height - frame.size.height);
    _inputViewHeight.constant = frame.size.height - 16;
    if (_tempFrame.size.height != frame.size.height) {
        CGFloat temp = frame.size.height - _tempFrame.size.height;
        frame.origin.y =(_tempFrame.origin.y - temp);
    }else{
        frame = _tempFrame;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
        [self layoutIfNeeded];
    }];
}
- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if( [@"\n" isEqualToString: text]){
        if (textView.text.length >= 1000) {
            return NO;
        }else{
            [textView resignFirstResponder];
            [self editDone];
            return NO;
        }
    }
    return YES;
}

- (IBAction)sendAction:(UIButton *)sender {
    if (_inputView.text.length >= 1000) {
//        [self.hud showString:@"不能超过1000字" dimissAfterSecond:1];
    }else{
        [_inputView resignFirstResponder];
        [self editDone];
    }
}

- (void)editDone{
    if (_inputComplete) {
        _inputComplete(_inputView.text);
        _inputComplete = nil;
    }
    _inputView.text = @"";
}

- (void)setPlaceHoldString:(NSString *)placeHoldString{
    _inputView.placeholderText = placeHoldString;
}

@end
