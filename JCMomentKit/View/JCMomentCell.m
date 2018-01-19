//
//  JCMomentCell.m
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import "JCMomentCell.h"
#import "JCMomentKit.h"
#import "JCMomentsModel.h"
#import "JCMomentImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "JCMomentSetting.h"
#import "JCMomentLocation.h"
#import "YYKit.h"
#import "JCCommentCell.h"
#import "NSBundle+JCMoment.h"

@interface JCMomentCell ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentPopConstraint;
@property (weak, nonatomic) IBOutlet UIView *popCommentView;
@property (strong, nonatomic) JCMomentsModel *model;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<JCMomentCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *momentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *watchTextMoreBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *watchMoreHeight;
@property (weak, nonatomic) IBOutlet JCMomentImageView *imagesBoardView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentBoardHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *commentBoardView;
@property (weak, nonatomic) IBOutlet UIImageView *commentBackImageView;
/**点赞**/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likeListHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likeListTopConstraint;
@property (weak, nonatomic) IBOutlet YYLabel *likeListLabel;
@property (weak, nonatomic) IBOutlet UIView *cutLine;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
/**评论**/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentTableviewTopConstraint;
@property (weak, nonatomic) IBOutlet UITableView *commentTableview;
/**右上角菜单*/
@property (weak, nonatomic) IBOutlet UIButton *menuBtn;
@property (strong, nonatomic) NSTimer *dismissCommentViewTimer;
/**认证V*/
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
/**训练报告*/
@property (weak, nonatomic) IBOutlet UIView *reportView;
@property (weak, nonatomic) IBOutlet UIImageView *reportImage;              //训练报告图片
@property (weak, nonatomic) IBOutlet UILabel *reportTitleLabel;             //训练报告标题
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reportViewHeight;  //训练报告高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reportViewTopConstraint;

@property (assign, nonatomic) BOOL alreadySetCommentBackImage;

@end

@implementation JCMomentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initCode];
}

- (void)initCode{
    NSBundle *xibBundle = [NSBundle bundleForClass:[self class]];
    [_commentTableview registerNib:[UINib nibWithNibName:@"JCCommentCell" bundle:xibBundle] forCellReuseIdentifier:@"JCCommentCell"];
    _popCommentView.layer.cornerRadius = 4;
    _popCommentView.layer.masksToBounds = YES;
    [self drawLineWithView:_popCommentView
                startPoint:CGPointMake(0.5*kCommentWidth, 8)
                  endPoint:CGPointMake(0.5*kCommentWidth, 32)
                 lineColor:MomentColorFromHex(0x333333)
                 lineWidth:0.5];
    _headerImage.layer.cornerRadius = 22.5;
    _headerImage.layer.borderWidth = 0.5;
    _headerImage.layer.borderColor = MomentColorFromHex(0x999999).CGColor;
    
    UITapGestureRecognizer *nickTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nickTapAction:)];
    [_nameLabel addGestureRecognizer:nickTap];
    _nameLabel.textColor = kNickNameColor;
    _momentTextLabel.textColor = kMomentTextColor;
    [_watchTextMoreBtn setTitleColor:kMoreButtonColor forState:UIControlStateNormal];
    _addressLabel.textColor = kAddressColor;
    _creatTimeLabel.textColor = kPostTimeColor;
    _viewCountLabel.textColor = kWatchCountColor;
    
    UIImage *backImage = [[UIImage imageNamed:@"find_friend_comment_list.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10,25,0,0) resizingMode:UIImageResizingModeStretch];
    _commentBackImageView.image = backImage;
    
    UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapAction:)];
    [_headerImage addGestureRecognizer:headerTap];
    [self addNitice];
    _commentPopConstraint.constant = 0;

    [UIView performWithoutAnimation:^{
        [_commentTableview reloadData];
    }];
    
    _likeListLabel.numberOfLines = 0;
    _likeListLabel.displaysAsynchronously = YES;
    _likeListLabel.textAlignment = NSTextAlignmentCenter;
    [self localized];
}

- (void)localized{
    [self.watchTextMoreBtn setTitle:[NSBundle JCLocalizedStringForKey:@"ReadAll"] forState:UIControlStateNormal];
    [self.watchTextMoreBtn setTitle:[NSBundle JCLocalizedStringForKey:@"PackUp"] forState:UIControlStateSelected];
    [_likeBtn setTitle:[NSBundle JCLocalizedStringForKey:@"Like"] forState:UIControlStateNormal];
    [_likeBtn setTitle:[NSBundle JCLocalizedStringForKey:@"UnLike"] forState:UIControlStateSelected];
    [_commentBtn setTitle:[NSBundle JCLocalizedStringForKey:@"Comment"] forState:UIControlStateNormal];
}

-(void)setNameColor:(UIColor *)nameColor{
    if (_nameColor || !nameColor) {
        return;
    }
    _nameColor = nameColor;
    _nameLabel.textColor = nameColor;
}

-(void)setTextColor:(UIColor *)textColor{
    if (_textColor || !textColor) {
        return;
    }
    _textColor = textColor;
    _momentTextLabel.textColor = textColor;
}

-(void)setWatchMoreButtonColor:(UIColor *)watchMoreButtonColor{
    if (_watchMoreButtonColor || !watchMoreButtonColor) {
        return;
    }
    _watchMoreButtonColor = watchMoreButtonColor;
    [_watchTextMoreBtn setTitleColor:watchMoreButtonColor forState:UIControlStateNormal];
    [_watchTextMoreBtn setTitleColor:watchMoreButtonColor forState:UIControlStateSelected];
}

-(void)setAddressColor:(UIColor *)addressColor{
    if (_addressColor || !addressColor) {
        return;
    }
    _addressLabel.textColor = addressColor;
    _addressColor = addressColor;
}

-(void)setTimeColor:(UIColor *)timeColor{
    if (_timeColor || !timeColor) {
        return;
    }
    _creatTimeLabel.textColor = timeColor;
    _timeColor = timeColor;
}

-(void)setViewColor:(UIColor *)viewColor{
    if (_viewColor || !viewColor) {
        return;
    }
    _viewCountLabel.textColor = viewColor;
    _viewColor = viewColor;
}

- (void)setHeaderLayerColor:(UIColor *)headerLayerColor{
    if (_headerLayerColor || !headerLayerColor) {
        return;
    }
    _headerImage.layer.borderColor = headerLayerColor.CGColor;
    _headerLayerColor = headerLayerColor;
}

- (void)setHeaderborderWidth:(CGFloat)headerborderWidth{
    if (_headerborderWidth != headerborderWidth) {
        _headerImage.layer.borderWidth = headerborderWidth;
        _headerborderWidth = headerborderWidth;
    }
}

- (void)setCommentCutLineBackColor:(UIColor *)commentCutLineBackColor{
    if (_commentCutLineBackColor || !commentCutLineBackColor) {
        return;
    }
    _commentCutLineBackColor = commentCutLineBackColor;
    _cutLine.backgroundColor = commentCutLineBackColor;
}

- (void)setCommentBackImage:(UIImage *)commentBackImage{
    if (_alreadySetCommentBackImage || !commentBackImage) {
        return;
    }
    UIImage *backImage = [commentBackImage resizableImageWithCapInsets:UIEdgeInsetsMake(10,25,0,0) resizingMode:UIImageResizingModeStretch];
    _commentBackImageView.image = backImage;
    _commentBackImage = commentBackImage;
    _alreadySetCommentBackImage = YES;

}

- (void)addNitice{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAllEdit) name:kNoticeCancelAllEdit object:nil];
}

/**
 取消所有控件的响应
 */
- (void)cancelAllEdit{
    [_dismissCommentViewTimer invalidate];
    if (_commentPopConstraint.constant == kCommentWidth) {
        _commentPopConstraint.constant = 0;
        [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self layoutIfNeeded];
        } completion:nil];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoticeCancelAllEdit object:nil];
}

/**
 赋予数据，排版布局
 @params    model           数据模型
 @params    indexPath       索引
 @params    delegate        代理
 */
- (void)setModel:(JCMomentsModel *)model
       indexPath:(NSIndexPath *)indexPath
        delegate:(id<JCMomentCellDelegate>)delegate
headerPlaceholdImage:(UIImage *)headerPlaceholdImage
momentPlaceholdImage:(UIImage *)momentPlaceholdImage{
    _model = model;
    _indexPath = indexPath;
    _delegate = delegate;
    model.indexPath = indexPath;
    _nameLabel.text = model.userName;
    [_headerImage sd_setImageWithURL:[NSURL URLWithString:model.icon]
                    placeholderImage:headerPlaceholdImage?headerPlaceholdImage:kMomentPlaceholdImage
                           completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                               
                           }];
    _momentTextLabel.text = model.text;
    _addressLabel.text = model.address;
    _creatTimeLabel.text = model.createTime;
    _viewCountLabel.text = @(model.views).stringValue;
    _imageViewHeight.constant = model.imagesHeight;
    
    if (model.address) {
        _addressTopConstraint.constant = 10;
        _addressLabel.text = model.address;
    }else{
        if (model.latitude) {
            _addressLabel.text = [NSBundle JCLocalizedStringForKey:@"LocationAcquisition"];
            _addressTopConstraint.constant = 10;
            __weak typeof(self)weakSelf = self;
            [[JCMomentLocation new] reverseGeocodeLocationWithLatitude:model.latitude
                                                             longitude:model.longitude
                                                              complete:^(NSString *addrssString) {
                                                                  model.address = addrssString;
                                                                  weakSelf.addressLabel.text = addrssString;
                                                              }];
        }else{
            _addressTopConstraint.constant = 2;
        }
    }
    
    if (model.isNeedShowMoreBtn) {///显示更多模式
        _watchMoreHeight.constant = 30;
        _watchTextMoreBtn.hidden = NO;
        if (model.showMoreSate == ShowMoreBtnSatePackUp) {///收起
            _momentTextLabel.numberOfLines = 5;
            _watchTextMoreBtn.selected = NO;
        }else{///展开
            _momentTextLabel.numberOfLines = 0;
            _watchTextMoreBtn.selected = YES;
        }
    }else{
        _watchMoreHeight.constant = 10;
        _watchTextMoreBtn.hidden = YES;
    }
    //图片区域/视频区域
    [_imagesBoardView setModelData:model placeHoldImage:momentPlaceholdImage?momentPlaceholdImage:kMomentPlaceholdImage];
    _imagesBoardView.clickVideoBlock = _clickVideoBlock;
    if (model.images.count == 0) {
        _addressTopConstraint.constant = 0;
    }
    
    _likeBtn.selected = model.isLike;
    _likeListHeightConstraint.constant = model.likeHeight;
    _likeListLabel.attributedText = model.likesString;
    ///点赞列表高度及位置
    _likeListHeightConstraint.constant = model.likeHeight;
    if (model.likeList.count == 0) {
        _cutLine.hidden = YES;
        _likeListTopConstraint.constant = 0;
        _commentTableviewTopConstraint.constant = 8;
    }else{
        _cutLine.hidden = NO;
        _likeListTopConstraint.constant = 8;
        _commentTableviewTopConstraint.constant = 0;
    }
    ///评论高度+boardView高度
    _commentBoardHeightConstraint.constant = model.commentHeigh + 8 + model.likeHeight;
//    _commentDataSource.sourceArray = model.responseList;
    [UIView performWithoutAnimation:^{
        [_commentTableview reloadData];
    }];
    if (model.likeHeight == 0 && model.commentHeigh == 0) {
        _commentBoardView.hidden = YES;
    }else{
        _commentBoardView.hidden = NO;
    }
    ///右上角菜单
    //    _menuBtn.hidden = !model.isMyMoment;
    _menuBtn.hidden = NO;
    //V认证
    [_imageV sd_setImageWithURL:[NSURL URLWithString:model.vImageURL] placeholderImage:kMomentPlaceholdImage];
    if (model.vLevelType == VLevelTypePersonUser) {
        _imageV.hidden = YES;
    }else{
        _imageV.hidden = NO;
    }
    //训练报告
    if (model.reportURL != nil && ![model.reportURL isEqualToString:@""]) {
        _reportViewHeight.constant = 40;
        _reportViewTopConstraint.constant = 10;
        _reportView.hidden = NO;
        [_reportImage sd_setImageWithURL:[NSURL URLWithString:model.reportImage] placeholderImage:kMomentPlaceholdImage];
        _reportTitleLabel.text = model.reportTitle;
    }else{
        _reportViewHeight.constant =
        _reportViewTopConstraint.constant = 0;
        _reportView.hidden = YES;
        _reportImage.image = nil;
        _reportTitleLabel.text = @"";
    }
}

#pragma mark -- action
/**
 展开、收起文本详情
 */
- (IBAction)watchMoreText:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        ///查看更多
        _momentTextLabel.numberOfLines = 0;
        _model.showMoreSate = ShowMoreBtnSateShow;
    }else{
        ///收起模式
        _momentTextLabel.numberOfLines = 5;
        _model.showMoreSate = ShowMoreBtnSatePackUp;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(momentCellDidTapAction:actionType:momentMode:responseIndexPath:)]) {
        [_delegate momentCellDidTapAction:self actionType:MomentTapActionTypeMoreButton momentMode:_model responseIndexPath:nil];
    }
}

/**
 弹出点赞、评论框
 */
- (IBAction)commentAction:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoticeCancelAllEdit object:nil];
    _likeBtn.selected = _model.isLike;
    if (_commentPopConstraint.constant == kCommentWidth) {
        _commentPopConstraint.constant = 0;
    }else{
        _commentPopConstraint.constant = kCommentWidth;
        _dismissCommentViewTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                                    target:self
                                                                  selector:@selector(cancelAllEdit)
                                                                  userInfo:nil
                                                                   repeats:NO];
    }
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

/**
 发表评论
 */
- (IBAction)commentEdit:(UIButton *)sender {
    [self cancelAllEdit];
    if (_delegate && [_delegate respondsToSelector:@selector(momentCellDidTapAction:actionType:momentMode:responseIndexPath:)]) {
        [_delegate momentCellDidTapAction:self actionType:MomentTapActionTypeComment momentMode:_model responseIndexPath:nil];
    }
}

/**
 点赞
 */
- (IBAction)likeAction:(UIButton *)sender {
    [UIView animateKeyframesWithDuration:.3 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        sender.alpha = 0;
        sender.transform = CGAffineTransformScale(sender.transform, 1.5, 1.5);
    } completion:^(BOOL finished) {
        sender.alpha = 1;
        sender.transform = CGAffineTransformIdentity;
        [self cancelAllEdit];
        if (_delegate && [_delegate respondsToSelector:@selector(momentCellDidTapAction:actionType:momentMode:responseIndexPath:)]) {
            [_delegate momentCellDidTapAction:self actionType:MomentTapActionTypeLike momentMode:_model responseIndexPath:nil];
        }
    }];
}

/**
 点击昵称
 */
- (void)nickTapAction:(UITapGestureRecognizer *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(momentCellDidTapAction:actionType:momentMode:responseIndexPath:)]) {
        [_delegate momentCellDidTapAction:self actionType:MomentTapActionTypeNickNameLabel momentMode:_model responseIndexPath:nil];
    }
}

/**
 点击头像
 */
- (void)headerTapAction:(UITapGestureRecognizer *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(momentCellDidTapAction:actionType:momentMode:responseIndexPath:)]) {
        [_delegate momentCellDidTapAction:self actionType:MomentTapActionTypeHeaderImageView momentMode:_model responseIndexPath:nil];
    }
}

/**
 右上角菜单
 */
- (IBAction)menuAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(momentCellDidTapAction:actionType:momentMode:responseIndexPath:)]) {
        [_delegate momentCellDidTapAction:self actionType:MomentTapActionTypeMenuButton momentMode:_model responseIndexPath:nil];
    }
}

/**
 训练报告
 */
- (IBAction)reportAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(momentCellDidTapAction:actionType:momentMode:responseIndexPath:)]) {
        [_delegate momentCellDidTapAction:self actionType:MomentTapActionTypeWatchReport momentMode:_model responseIndexPath:nil];
    }
}

#pragma mark -- 工具方法

- (void)drawLineWithView:(UIView *)view
              startPoint:(CGPoint)startPoint
                endPoint:(CGPoint)endPoint
               lineColor:(UIColor *)lineColor
               lineWidth:(CGFloat)lineWidth{
    
    CAShapeLayer *solidShapeLayer = [CAShapeLayer layer];
    CGMutablePathRef solidShapePath =  CGPathCreateMutable();
    [solidShapeLayer setFillColor:[lineColor CGColor]];
    [solidShapeLayer setStrokeColor:[lineColor CGColor]];
    solidShapeLayer.lineWidth = lineWidth ;
    CGPathMoveToPoint(solidShapePath, NULL, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(solidShapePath, NULL, endPoint.x,endPoint.y);
    [solidShapeLayer setPath:solidShapePath];
    CGPathRelease(solidShapePath);
    [view.layer addSublayer:solidShapeLayer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -- 评论列表Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _model.responseList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self)weakSelf = self;
    JCCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCCommentCell" forIndexPath:indexPath];
    [cell setMomentResponseModel:_model.responseList[indexPath.row]
                   currentUserID:_model.currentUserID];
    cell.longPressHandle = ^(JCMomentResponseModel *responseModel) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(momentCellDidTapAction:actionType:momentMode:responseIndexPath:)]) {
            [weakSelf.delegate momentCellDidTapAction:weakSelf actionType:MomentTapActionTypeDeleteComment momentMode:weakSelf.model responseIndexPath:indexPath];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(momentCellDidTapAction:actionType:momentMode:responseIndexPath:)]) {
        [_delegate momentCellDidTapAction:self actionType:MomentTapActionTypeReplayComment momentMode:_model responseIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger height = ((JCMomentResponseModel *)_model.responseList[indexPath.row]).commentHeight;
    return height;
}

@end

