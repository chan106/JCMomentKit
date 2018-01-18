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
#import "NSBundle+JCMoment.h"

@interface JCMomentCommentInputView()<YYTextViewDelegate>

@property (strong, nonatomic) YYTextView *inputView;
@property (strong, nonatomic) UIButton *sendButton;
@property (assign, nonatomic) CGRect tempFrame;
@property (nonatomic, strong) UIColor *sendButtonBackColor;
@property (nonatomic, strong) UIColor *sendButtonTinColor;
@property (nonatomic, strong) UIColor *sendButtonBorderColor;

@end

@implementation JCMomentCommentInputView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initCodeForFrame:frame];
    }
    return self;
}

- (void)updateFrame:(CGRect)frame withTime:(CGFloat) time{
    [UIView animateKeyframesWithDuration:time delay:0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
        self.frame = frame;
        _inputView.frame = CGRectMake(15, 8, frame.size.width - 85, frame.size.height - 16);
        _sendButton.frame = CGRectMake(15 + _inputView.frame.size.width + 10, 8, 50, 40);
    } completion:^(BOOL finished) {
        
    }];
    _tempFrame = frame;
}

- (void)initCodeForFrame:(CGRect) frame{
    
    self.backgroundColor = MomentColorFromHex(0xf0f0f0);
    _sendButtonBackColor = [UIColor yellowColor];
    _sendButtonTinColor = MomentColorFromHex(0x999999);
    _sendButtonBorderColor = MomentColorFromHex(0xcccccc);
    
    _inputView = [[YYTextView alloc] initWithFrame:CGRectMake(15, 8, frame.size.width - 85, frame.size.height - 16)];
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
    [self addSubview:_inputView];
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.frame = CGRectMake(15 + _inputView.frame.size.width + 10, 8, 50, 40);
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _sendButton.backgroundColor = _sendButtonBackColor;
    _sendButton.layer.cornerRadius = 3;
    _sendButton.layer.masksToBounds = YES;
    _sendButton.layer.borderColor = _sendButtonBorderColor.CGColor;
    _sendButton.layer.borderWidth = 0.5;
    _sendButton.backgroundColor = [UIColor clearColor];
    _sendButton.enabled = NO;
    [_sendButton setTitleColor:_sendButtonTinColor forState:UIControlStateNormal];
    [_sendButton setTitle:[NSBundle JCLocalizedStringForKey:@"Send"] forState:UIControlStateNormal];
    [self addSubview:_sendButton];
}

- (void)sendButtonBackColor:(UIColor *) backColor
                   tinColor:(UIColor *) tinColor
                borderColor:(UIColor *) borderColor{
    
    _sendButtonTinColor = tinColor;
    _sendButtonBackColor = backColor;
    _sendButtonBorderColor = borderColor;
    
    _sendButton.layer.borderColor = borderColor.CGColor;
    if ([_inputView.text isEqualToString:@""]) {
        _sendButton.layer.borderWidth = 0.5;
        _sendButton.backgroundColor = [UIColor clearColor];
        _sendButton.enabled = NO;
        [_sendButton setTitleColor:MomentColorFromHex(0xcccccc) forState:UIControlStateNormal];
    }else{
        _sendButton.layer.borderWidth = 0;
        _sendButton.enabled = YES;
        _sendButton.backgroundColor = _sendButtonBackColor;
        [_sendButton setTitleColor:_sendButtonTinColor forState:UIControlStateNormal];
    }
}

- (void)inputViewBorderColor:(UIColor *)inputBorderColor
              placeholdColor:(UIColor *)placeholdColor
                   textColor:(UIColor *)textColor{
    _inputView.layer.borderColor = inputBorderColor.CGColor;
    _inputView.placeholderTextColor = placeholdColor;
    _inputView.textColor = textColor;
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
        [_sendButton setTitleColor:MomentColorFromHex(0xcccccc) forState:UIControlStateNormal];
    }else{
        _sendButton.layer.borderWidth = 0;
        _sendButton.enabled = YES;
        _sendButton.backgroundColor = _sendButtonBackColor;
        [_sendButton setTitleColor:_sendButtonTinColor forState:UIControlStateNormal];
    }
    
    YYTextLayout *layout = textView.textLayout;
    CGFloat height = MIN(layout.textBoundingSize.height, kInputViewMinHeight);
    height = MAX(18+height, kInputViewMinHeight);
    CGRect frame = self.frame;
    frame.size.height = height;
    _inputView.frame = CGRectMake(15, 8, frame.size.width - 85, frame.size.height - 16);
    _sendButton.frame = CGRectMake(15 + _inputView.frame.size.width + 10, height - 48, 50, 40);
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
