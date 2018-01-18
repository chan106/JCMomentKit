//
//  JCMomentImageView.m
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import "JCMomentImageView.h"
#import "JCMomentsModel.h"
#import "JCMomentKit.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "YYPhotoGroupView.h"
#import <YYKit/YYImage.h>
#import "NSBundle+JCMoment.h"

@interface JCMomentImageView ()

@property (nonatomic , strong) JCMomentsModel *model;
@property (nonatomic , strong) NSMutableArray <UIImageView *> *imageViewArray;
@property (nonatomic , strong) NSMutableArray <UILabel *> *tipLabelArray;
@property (nonatomic , strong) UIImageView *videoCover;
@property (nonatomic , strong) UIImage *placeHoldImage;

@end

@implementation JCMomentImageView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)initCode{
    if (_imageViewArray == nil) {
        _imageViewArray = [NSMutableArray array];
        _tipLabelArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 6; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            imageView.userInteractionEnabled = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.tag = i;
            ///添加手势
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [imageView addGestureRecognizer:tap];
            [self addSubview:imageView];
            [self.imageViewArray addObject:imageView];
            
            UILabel *tipLabel = [UILabel new];
            tipLabel.backgroundColor = MomentColorFromHex(0x8599C5);
            tipLabel.textColor = [UIColor whiteColor];
            tipLabel.font = [UIFont systemFontOfSize:12];
            tipLabel.textAlignment = NSTextAlignmentRight;
            tipLabel.text = [NSBundle JCLocalizedStringForKey:@"LongImage"];
            [tipLabel sizeToFit];
            tipLabel.hidden = YES;
            tipLabel.tag = i;
            [imageView addSubview:tipLabel];
            [_tipLabelArray addObject:tipLabel];
        }
    }
    if (_videoCover == nil) {
        _videoCover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200 * ([UIScreen mainScreen].bounds.size.width/375.0), 125 * ([UIScreen mainScreen].bounds.size.width/375.0))];
        _videoCover.userInteractionEnabled = YES;
        _videoCover.contentMode = UIViewContentModeScaleAspectFill;
        _videoCover.clipsToBounds = YES;
        [self addSubview:_videoCover];
        UIImageView *play = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        play.image = [UIImage imageNamed:@"post_videoPlayIcon"];
        [play sizeToFit];
        play.center = _videoCover.center;
        [_videoCover addSubview:play];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlayVideo)];
        [_videoCover addGestureRecognizer:tap];
    }
}

- (void)setModelData:(JCMomentsModel *)model placeHoldImage:(UIImage *)placeHoldImage{
    _model = model;
    _placeHoldImage = placeHoldImage;
    [self initCode];
    if (model.videoURL != nil && ![model.videoURL isEqualToString:@""]) {
        //视频
        _videoCover.hidden = NO;
        for (UIImageView *view in _imageViewArray) {
            view.hidden = YES;
        }
        [_videoCover sd_setImageWithURL:[NSURL URLWithString:model.videoCoverURL] placeholderImage:[UIImage imageNamed:@"placehold_image"]];
    }else{
        //图片
        for (UIImageView *view in _imageViewArray) {
            view.hidden = NO;
        }
        _videoCover.hidden = YES;
        NSString *param_1 = @"?imageMogr2/thumbnail/102400@";
        NSString *param_2 = @"?imageMogr2/thumbnail/64000@";
        NSString *parma_3 = @"?imageMogr2/thumbnail/200x200";
        NSInteger count = model.images.count;
        ///一张图
        if (count == 1) {
            ///隐藏1-5
            for (NSInteger i = 1; i < 6; i++) {
                UIImageView *imageView = _imageViewArray[i];
                imageView.frame = CGRectMake(0, 0, 0, 0);
            }
            ///调整0的坐标及尺寸
            UIImageView *imageView = _imageViewArray[0];
            imageView.frame = CGRectMake(0, 0, model.singleImageSize.width, _model.singleImageSize.height);
            NSString *urlString = _model.images.firstObject;
            [self setImageView:imageView imageUrl:[NSURL URLWithString:[urlString stringByAppendingString:param_1]]];
            
            UILabel *tipLabel = _tipLabelArray[0];
            if (model.isLongImage) {
                tipLabel.hidden = NO;
                tipLabel.text = [NSBundle JCLocalizedStringForKey:@"LongImage"];
                [tipLabel sizeToFit];
            }else if ([urlString containsString:@"gif"]) {
                tipLabel.hidden = NO;
                tipLabel.text = @"GIF";
                [tipLabel sizeToFit];
            }else{
                tipLabel.hidden = YES;
            }
            CGRect frame = tipLabel.frame;
            frame.origin = CGPointMake(imageView.bounds.size.width - frame.size.width, imageView.bounds.size.height - frame.size.height);
            tipLabel.frame = frame;
        }
        ///2、3、5、6张图
        else if (count == 2 || count == 3 ||  count == 5 || count == 6 || count > 6){
            if (count > 6) {
                count = 6;
            }
            for (NSInteger i = 0; i < 6; i++) {
                UIImageView *imageView = _imageViewArray[i];
                if (i < count) {
                    imageView.frame = CGRectMake((i>=3?i-3:i%3)*(kImageHeight+4), 0+(i/3 * (kImageHeight+4)), kImageHeight, kImageHeight);
                    [self setImageView:imageView imageUrl:[NSURL URLWithString:[self.model.images[i] stringByAppendingString:parma_3]]];
                    
                    NSString *urlString = self.model.images[i];
                    UILabel *tipLabel = _tipLabelArray[i];
                    if ([urlString containsString:@"gif"]) {
                        tipLabel.hidden = NO;
                        tipLabel.text = @"GIF";
                        [tipLabel sizeToFit];
                    }else{
                        tipLabel.hidden = YES;
                    }
                    CGRect frame = tipLabel.frame;
                    frame.origin = CGPointMake(imageView.bounds.size.width - frame.size.width, imageView.bounds.size.height - frame.size.height);
                    tipLabel.frame = frame;
                    
                }else{
                    imageView.frame = CGRectMake(0, 0, 0, 0);
                    _tipLabelArray[i].hidden = YES;
                }
            }
        }
        ///4张图
        else if (count == 4){///四张图
            ///隐藏 4 - 5
            for (NSInteger i = 4; i < 6; i++) {
                UIImageView *imageView = _imageViewArray[i];
                imageView.frame = CGRectMake(0, 0, 0, 0);
                _tipLabelArray[i].hidden = YES;
            }
            ///排布0 - 3
            for (NSInteger i = 0; i < 4; i++) {
                UIImageView *imageView = _imageViewArray[i];
                imageView.frame = CGRectMake((i%2)*(kImageHeight+4), 0+((i/2) * (kImageHeight+4)), kImageHeight, kImageHeight);
                [self setImageView:imageView imageUrl:[NSURL URLWithString:[self.model.images[i] stringByAppendingString:param_2]]];
                
                NSString *urlString = self.model.images[i];
                UILabel *tipLabel = _tipLabelArray[i];
                if ([urlString containsString:@"gif"]) {
                    tipLabel.hidden = NO;
                    tipLabel.text = @"GIF";
                    [tipLabel sizeToFit];
                }else{
                    tipLabel.hidden = YES;
                }
                CGRect frame = tipLabel.frame;
                frame.origin = CGPointMake(imageView.bounds.size.width - frame.size.width, imageView.bounds.size.height - frame.size.height);
                tipLabel.frame = frame;
            }
        }
        ///隐藏所有
        else if (count == 0){
            for (UIImageView *imageView in _imageViewArray) {
                imageView.frame = CGRectMake(0, 0, 0, 0);
            }
            for (UILabel *label in _tipLabelArray) {
                label.hidden = YES;
            }
        }
    }
}

- (void)tapAction:(UITapGestureRecognizer *)sender{
    NSMutableArray *items = [NSMutableArray array];
    UIImageView *fromView = nil;
    for (NSInteger i = 0; i < _model.images.count; i++) {
        NSString *urlString = _model.images[i];
        YYPhotoGroupItem *item = [[YYPhotoGroupItem alloc] init];
        UIImageView *imageView = _imageViewArray[i];
        item.thumbView = imageView;
        item.largeImageURL = [NSURL URLWithString:urlString];
        NSString *sizeString = [urlString componentsSeparatedByString:@"-"].lastObject;
        CGSize imageSize = CGSizeMake([sizeString componentsSeparatedByString:@"*"].firstObject.floatValue, [sizeString componentsSeparatedByString:@"*"].lastObject.floatValue);
        item.largeImageSize = imageSize;
        [items addObject:item];
        if (sender.view == imageView) {
            fromView = imageView;
        }
    }
    YYPhotoGroupView *v = [[YYPhotoGroupView alloc] initWithGroupItems:items];
    v.blurEffectBackground = NO;
    [v presentFromImageView:fromView toContainer:[UIApplication sharedApplication].keyWindow animated:YES completion:nil];
}

//播放视频
- (void)tapPlayVideo{
    if (_clickVideoBlock) {
        _clickVideoBlock([NSURL URLWithString:_model.videoURL]);
    }
}

- (void)setImageView:(UIImageView *)imageView imageUrl:(NSURL *)url{
    [imageView sd_setImageWithURL:url
                 placeholderImage:_placeHoldImage?_placeHoldImage:[UIImage imageNamed:@"placehold_image.png"]
                        completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
                        }];
}

@end
