//
//  JCMomentImageView.h
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JCMomentsModel;

@interface JCMomentImageView : UIView

@property (nonatomic, copy) void(^clickVideoBlock)(NSURL *videoURL);
- (void)setModelData:(JCMomentsModel *)model placeHoldImage:(UIImage *)placeHoldImage;

@end
