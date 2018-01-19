//
//  JCMomentsModel.m
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import "JCMomentsModel.h"
#import "NSString+CheckIsString.h"
#import "JCMomentLocation.h"
#import "JCLikeListModel.h"
#import <YYKit/YYKit.h>
#import "JCMomentKit.h"
#import "NSBundle+JCMoment.h"

@interface JCMomentsModel ()

@end

@implementation JCMomentsModel

/**
 @bref 创建帖子数据模型
 @param         sourceArray         源数据，网络请求回来的数组
 @return                            解析好的数组模型
 */
+ (NSArray <JCMomentsModel *> *)creatModelWithArray:(NSArray <NSDictionary *> *)sourceArray
                                      currentUserID:(NSString *)currentUserID
                                    currentUserName:(NSString *)currentUserName
                                          nameColor:(UIColor *)nameColor
                                       contentColor:(UIColor *)contentColor{
    
    NSMutableArray *modelArray = [NSMutableArray array];
    for (NSDictionary *sourceDic in sourceArray) {
        JCMomentsModel *model = [JCMomentsModel new];
        model.nameColor = nameColor?nameColor:kNickNameColor;
        model.contentColor = contentColor?contentColor:kMomentTextColor;
        model.userName = [NSString checkIfNullWithString:sourceDic[@"UserName"]];
        model.currentUserID = currentUserID;
        model.currentUserName = currentUserName;
        model.icon = [NSString checkIfNullWithString:sourceDic[@"Icon"]];
        model.userID = [NSString checkIfNullWithString:sourceDic[@"UserID"]];
        model.topicID = [NSString checkIfNullWithString:sourceDic[@"ID"]];
        model.text = [NSString checkIfNullWithString:sourceDic[@"Text"]];
        NSString *position = [NSString checkIfNullWithString:sourceDic[@"Position"]];
        model.longitude = [position componentsSeparatedByString:@","].firstObject.doubleValue;
        model.latitude = [position componentsSeparatedByString:@","].lastObject.doubleValue;
        model.createTime = [NSString checkIfNullWithString:sourceDic[@"CreateTime"]];
        model.images = sourceDic[@"ImgList"];
        model.likeList = [NSMutableArray arrayWithArray:[JCLikeListModel creatModelWithArray:sourceDic[@"LikeList"]]];
        model.isLike = [NSString checkIfNullWithString:sourceDic[@"IsLiked"]].boolValue;
        model.isHandpicked = [[NSString checkIfNullWithString:sourceDic[@"Feature"]] boolValue];
        model.views = [NSString checkIfNullWithString:sourceDic[@"Views"]].integerValue;
        model.responseList = [JCMomentResponseModel creatModelWithArray:sourceDic[@"ResponseList"]
                                                            momentModel:model
                                                              nameColor:model.nameColor
                                                           contentColor:model.contentColor];
        model.subName = [NSString checkIfNullWithString:sourceDic[@"UserTypeName"]];
        model.vLevelType = [[NSString checkIfNullWithString:sourceDic[@"UserType"]] integerValue];
        model.vImageURL = [NSString checkIfNullWithString:sourceDic[@"VUrl"]];
        model.reportURL = [NSString checkIfNullWithString:sourceDic[@"ReportUrl"]];
        model.reportImage = [NSString checkIfNullWithString:sourceDic[@"ReportImg"]];
        model.reportTitle = [NSString checkIfNullWithString:sourceDic[@"ReportTitle"]];
        model.videoURL = [NSString checkIfNullWithString:sourceDic[@"VideoUrl"]];
        model.videoCoverURL = [NSString checkIfNullWithString:sourceDic[@"VideoThumb"]];
        
        //计算图片高度、文本高度、时间地址高度
        model.imagesHeight = [model caculImageViewHeight];
        model.textLabelHeight = [model caculLabelWithString:model.text width:kTextLabelWidth font:kTextFont];
        model.timeAdressHeight = model.latitude?kValidAdressHeight:kAvalidAdressHeight;
        //计算点赞列表的高度及生成点赞字符串
        [model dealLikes];
        //计算评论所需高度
        [model calculCommetHeight];
        //计算cell高度
        [model caucalCellHeight];
        model.showMoreSate = ShowMoreBtnSatePackUp;
        model.isMyMoment = [model.userID isEqualToString:currentUserID]?YES:NO;
        model.isAninated = YES;
        [modelArray addObject:model];
    }
    return [modelArray mutableCopy];
}

/**
 计算label显示需要的高度
 */
- (CGFloat)caculLabelWithString:(NSString *)string width:(CGFloat)width font:(CGFloat)font{
    if (string == nil || [string isEqualToString:@""]) {
        return 0;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, CGFLOAT_MAX)];
    label.font = [UIFont systemFontOfSize:kTextFont];
    label.numberOfLines = 0;
    label.text = string;
    [label sizeToFit];
    CGFloat height = label.bounds.size.height;
    return height;
}

/**
 计算图片显示需要的高度
 */
- (CGFloat)caculImageViewHeight{
    NSInteger count = self.images.count;
    NSInteger height = 0;
    self.isLongImage = NO;
    if (self.videoURL != nil && ![self.videoURL isEqualToString:@""]) {
        //有视频
        height = 125 * ([UIScreen mainScreen].bounds.size.width/375.0);
    }else{
        //有图片
        if (count == 1) {///一张图
            NSString *urlString = self.images.firstObject;
            NSString *sizeString = [urlString componentsSeparatedByString:@"-"].lastObject;
            CGSize imageSize = CGSizeMake([sizeString componentsSeparatedByString:@"*"].firstObject.floatValue, [sizeString componentsSeparatedByString:@"*"].lastObject.floatValue);
            CGFloat ratio;
            /**
             横图处理----------------------------
             */
            if (imageSize.width > imageSize.height){
                if (imageSize.width > 2.0 * imageSize.height) {
                    /*很长的横图:
                     宽度直接设置为最大宽，同时高度等比缩小
                     如果：高度 < kImageHMinWidth,则不管缩小比例,强制性设置为kImageHMinWidth
                     */
                    CGFloat W2 = kImageMaxWidth;
                    imageSize.height = (W2 * imageSize.height)/imageSize.width;
                    imageSize.width = W2;
                    if (imageSize.height < kImageHMinWidth) {
                        imageSize.height = kImageHMinWidth;
                    }
                    self.isLongImage = YES;
                }else{
                    /*正常的横图:
                     图片的宽度 / 2 之后
                     +小于kImageMinWidth：
                     ->小于kImageMinWidth
                     |   宽度直接设置为kImageMinWidth，高度等比缩
                     ->大于kImageMinWidth
                     |   宽度、高度都缩小2倍
                     +大于kImageMinWidth：
                     宽度直接设置kImageMaxWidth、高度等比缩
                     */
                    if (imageSize.width / 2.0 < kTextLabelWidth) {
                        ///小于
                        if (imageSize.width / 2.0 < kImageMinWidth) {
                            CGFloat W2 = kImageMinWidth;
                            imageSize.height = (W2 * imageSize.height)/imageSize.width;
                            imageSize.width = W2;
                        }else{
                            ratio = 2.0;
                            imageSize.width = imageSize.width / ratio;
                            imageSize.height = imageSize.height / ratio;
                        }
                    }else{
                        ///大于
                        CGFloat W2 = kImageMaxWidth;
                        ///H2=(W2*H1)/W1
                        imageSize.height = (W2 * imageSize.height)/imageSize.width;
                        imageSize.width = W2;//宽为最大
                    }
                }
            }
            /**
             长图处理----------------------------
             */
            else if(imageSize.width < imageSize.height){
                if (imageSize.height / imageSize.width > 2) {
                    /*很长的图:
                     宽度直接设置为0.3*kImageMaxWidth，同时高度等比缩小
                     如果：高度 > 3倍宽,则强制让高等于3倍宽
                     */
                    CGFloat W2 = 0.3*kImageMaxWidth;
                    imageSize.height = (W2 * imageSize.height)/imageSize.width;
                    imageSize.width = W2;
                    if (imageSize.height > imageSize.width * 3) {
                        imageSize.height = imageSize.width * 3;
                    }
                    self.isLongImage = YES;
                }else{
                    ///普通竖直方向图片
                    ratio = (CGFloat)imageSize.width / imageSize.height;//宽高比
                    if (imageSize.width / 2.0 < kTextLabelWidth) {
                        ///小于屏宽
                        if (imageSize.width / 2.0 < kImageMinWidth) {
                            CGFloat W2 = kImageMinWidth * 0.6;
                            imageSize.height = (W2 * imageSize.height)/imageSize.width;
                            imageSize.width = W2;
                        }else{
                            CGFloat W2 = kImageMinWidth * 0.6;
                            imageSize.height = (W2 * imageSize.height)/imageSize.width;
                            imageSize.width = W2;
                        }
                    }else{
                        ///大于屏宽
                        CGFloat W2 = kImageMaxWidth * 0.6;
                        ///H2=(W2*H1)/W1
                        imageSize.height = (W2 * imageSize.height)/imageSize.width;
                        imageSize.width = W2;//宽为最大
                    }
                }
            }
            else{
                ///相等处理
                imageSize = CGSizeMake(kImageMinWidth, kImageMinWidth);
            }
            
            self.singleImageSize = imageSize;
            height = imageSize.height;
        }else if(count == 2 || count == 3){
            height = kImageHeight;
        }else if (count == 0){
            height = 0;
        }else{
            height = 2*kImageHeight + 4;
        }
    }
    return height;
}

#pragma mark -- 点赞人列表生成、高度计算
- (void)dealLikes{
    
    NSString *userNameLink = @"";
    NSMutableAttributedString *allLikeListText;
    NSMutableArray *sourceArray = [NSMutableArray array];
    CGRect rect;
    
    for (NSInteger i = 0; i < self.likeList.count; i++) {
        JCLikeListModel *model = self.likeList[i];
        if (i == self.likeList.count - 1) {
            userNameLink = [userNameLink stringByAppendingString:model.userName];
        }else{
            userNameLink = [userNameLink stringByAppendingString:[model.userName stringByAppendingString:@"、"]];
        }
        [sourceArray addObject:model.userName];
    }
    
    UIImage *image = [UIImage imageNamed:@"find_like_list.png"];
    NSMutableAttributedString *attachText =
    [NSMutableAttributedString attachmentStringWithContent:image
                                               contentMode:UIViewContentModeCenter
                                            attachmentSize:CGSizeMake(1.5*kTextFont, kTextFont)
                                               alignToFont:[UIFont systemFontOfSize:kTextFont]
                                                 alignment:YYTextVerticalAlignmentCenter];
    allLikeListText = [[NSMutableAttributedString alloc] initWithAttributedString:attachText];
    [allLikeListText appendString:[NSString stringWithFormat:@" %@",userNameLink]];
    allLikeListText.lineSpacing = 2;
    allLikeListText.font = [UIFont boldSystemFontOfSize:kTextFont];
    allLikeListText.color = self.contentColor;
    
    //计算出高度
    YYLabel *label = [[YYLabel alloc] initWithFrame:CGRectMake(0, 0, kLikeListWidth, CGFLOAT_MAX)];
    label.attributedText = allLikeListText;
    label.numberOfLines = 0;
    [label sizeToFit];
    rect = label.frame;
    
    if ([userNameLink isEqualToString:@""]) {
        self.likeHeight = 0;
        self.likesString = nil;
    }else{
        for (NSInteger i = 0 ; i < sourceArray.count; i++) {
            NSRange range;
            NSString *preString;
            NSString *needString = sourceArray[i];
            NSArray *subArray = [sourceArray subarrayWithRange:NSMakeRange(0, i)];
            for (NSString *sub in subArray) {
                if (preString == nil) {
                    preString = sub;
                }else{
                    preString = [preString stringByAppendingString:[NSString stringWithFormat:@"、%@",sub]];
                }
            }
            NSInteger preStringLength = preString.length;
            if (preStringLength == 0) {
                range = NSMakeRange(preStringLength+2, needString.length);
            }else{
                range = NSMakeRange(preStringLength+3, needString.length);
            }
            ///点赞人的点击事件
            [allLikeListText setTextHighlightRange:range
                                             color:self.nameColor
                                   backgroundColor:[UIColor grayColor]
                                         tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                                             [[NSNotificationCenter defaultCenter] postNotificationName:kNoticeWatchUserInfo object:nil userInfo:@{@"userID":_likeList[i].userID}];
                                         }];
        }
        self.likeHeight = rect.size.height+4;
        self.likesString = allLikeListText;
    }
}

/**
 计算评论需要的高度
 */
- (void)calculCommetHeight{
    self.commentHeigh = 0;
    for (JCMomentResponseModel *model in self.responseList) {
        self.commentHeigh += model.commentHeight;
    }
    if (self.responseList.count > 0) {
        self.commentHeigh += 3;
    }
}

/**
 点赞、取消赞
 @param         state        YES:点赞 NO:取消赞
 */
- (void)editLikeState:(BOOL)state{
    if (state) {
        ///点赞
        JCLikeListModel *model = [JCLikeListModel new];
        model.userID = self.currentUserID;
        model.userName = self.currentUserName;
        [self.likeList addObject:model];
    }else{
        ///取消赞
        JCLikeListModel *remove;
        for (JCLikeListModel *model in self.likeList) {
            if ([model.userID isEqualToString:self.currentUserID]) {
                remove = model;
            }
        }
        [self.likeList removeObject:remove];
    }
    ///重新计算高度、生成点赞列表字符串
    [self dealLikes];
    ///计算cell高度
    [self caucalCellHeight];
}

/**
 添加一条评论
 @param         model        评论数据模型
 */
- (void)addCommentModel:(JCMomentResponseModel *)model{
    model.momentModel = self;
    ///添加新的数据
    [self.responseList addObject:model];
    ///计算评论所需高度
    [self calculCommetHeight];
    ///计算cell高度
    [self caucalCellHeight];
}

/**
 添加一条回复
 @param         model        回复数据模型
 */
- (void)addResponseModel:(JCMomentResponseModel *)model{
    model.momentModel = self;
    ///添加新的数据
    [self.responseList addObject:model];
    ///计算评论所需高度
    [self calculCommetHeight];
    ///计算cell高度
    [self caucalCellHeight];
}

- (void)caucalCellHeight{
    NSInteger space;
    NSInteger reportHeight;
    if (self.reportURL != nil && ![self.reportURL isEqualToString:@""]) {
        reportHeight = kReportHeight;
    }else{
        reportHeight = 0;
    }
    if (self.likeHeight == 0 && self.commentHeigh == 0) {
        space = 8;
    }else{
        space = 16;
    }
    if (self.textLabelHeight > kTextLabelNormalHeight) {
        ///需要显示更多
        self.isNeedShowMoreBtn = YES;
        self.normalCellHeight = kNickNameHeight +
                                kTextLabelNormalHeight +
                                kShowTextBtnHeight +
                                self.imagesHeight +
                                self.timeAdressHeight +
                                reportHeight +
                                (kBottomSpaceHeight + self.likeHeight + space + self.commentHeigh);
        self.showMoreCellHeight =
                                kNickNameHeight +
                                self.textLabelHeight +
                                kShowTextBtnHeight +
                                self.imagesHeight +
                                self.timeAdressHeight +
                                reportHeight +
                                (kBottomSpaceHeight + self.likeHeight + space + self.commentHeigh);
    }else{
        ///无需显示更多
        self.isNeedShowMoreBtn = NO;
        self.normalCellHeight = self.showMoreCellHeight = kNickNameHeight + self.textLabelHeight + kHideTextBtnHeight + self.imagesHeight + self.timeAdressHeight + reportHeight + (kBottomSpaceHeight + self.likeHeight + space + self.commentHeigh);
    }
    if (self.images.count == 0 && self.latitude != 0) {//无图片
        self.normalCellHeight -= 10;
        self.showMoreCellHeight -= 10;
    }
}

@end









@interface JCMomentResponseModel ()

@property (nonatomic, strong) UIColor *nameColor;
@property (nonatomic, strong) UIColor *contentColor;

@end

@implementation JCMomentResponseModel

/**
 创建回复列表模型
 @param         sourceArray         源数据，网络请求回来的数组
 @param         momentModel         帖子数据模型
 @return                            解析好的数组模型
 */
+ (NSMutableArray <JCMomentResponseModel *> *)creatModelWithArray:(NSArray <NSDictionary *> *)sourceArray
                                                      momentModel:(JCMomentsModel *)momentModel
                                                        nameColor:(UIColor *)nameColor
                                                     contentColor:(UIColor *)contentColor{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *sourceDic in sourceArray) {
        JCMomentResponseModel *model = [JCMomentResponseModel new];
        model.nameColor = nameColor?nameColor:kNickNameColor;
        model.contentColor = contentColor?contentColor:kMomentTextColor;
        model.momentModel = momentModel;
        model.postID = [NSString checkIfNullWithString:sourceDic[@"PostID"]];
        model.responseID = [NSString checkIfNullWithString:sourceDic[@"RID"]];
        model.creatTime = [NSString checkIfNullWithString:sourceDic[@"CreateTime"]];
        model.text = [NSString checkIfNullWithString:sourceDic[@"Text"]];
        model.parentID = [NSString checkIfNullWithString:sourceDic[@"ParentID"]];
        model.rUserID = [NSString checkIfNullWithString:sourceDic[@"RUserID"]];
        model.rUserName = [NSString checkIfNullWithString:sourceDic[@"RUserName"]];
        model.quote = [JCMomentQuotoModel creatModelWithDictionary:sourceDic[@"Quote"]];
        [model caucalCommentHeight];
        [array addObject:model];
    }
    return array;
}

/**
 计算评论需要的高度,生成评论文字
 */
- (void)caucalCommentHeight{
    NSString *userNameLink;
    NSString *commentText;
    NSMutableAttributedString *text;
    NSString *replay = [NSBundle JCLocalizedStringForKey:@"Reply"];
    if (self.quote == nil) {
        ///是一条评论
        userNameLink = [NSString stringWithFormat:@"%@: ",self.rUserName];
        commentText = self.text;
        text  = [[NSMutableAttributedString alloc] initWithString:[userNameLink stringByAppendingString:commentText]];
    }else{
        ///是一条回复
        userNameLink = [NSString stringWithFormat:@"%@%@%@: ",self.rUserName,replay,self.quote.userName];
        commentText = self.text;
        text  = [[NSMutableAttributedString alloc] initWithString:[userNameLink stringByAppendingString:commentText]];
    }
    text.lineSpacing = 2;
    text.font = [UIFont systemFontOfSize:kTextFont];
    text.color = self.contentColor;
    [text addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:kTextFont] range:NSMakeRange(0, self.rUserName.length)];
    [text addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:kTextFont] range:NSMakeRange(self.rUserName.length+(replay.length), self.quote.userName.length)];
    self.commentString = text;
    
    __weak typeof(self)weakSelf = self;
    if (self.quote == nil) {
        ///是一条评论
        [self.commentString setTextHighlightRange:NSMakeRange(0, self.rUserName.length)
                                            color:self.nameColor
                                   backgroundColor:[UIColor grayColor]
                                         tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                                             [[NSNotificationCenter defaultCenter] postNotificationName:kNoticeWatchUserInfo object:nil userInfo:@{@"userID":weakSelf.rUserID}];
                                         }];
    }else{
        ///是一条回复
        [self.commentString setTextHighlightRange:NSMakeRange(0, self.rUserName.length)
                                             color:self.nameColor
                                   backgroundColor:[UIColor grayColor]
                                         tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                                             [[NSNotificationCenter defaultCenter] postNotificationName:kNoticeWatchUserInfo object:nil userInfo:@{@"userID":weakSelf.rUserID}];
                                         }];
        [self.commentString setTextHighlightRange:NSMakeRange(self.rUserName.length+(replay.length), self.quote.userName.length)
                                             color:self.nameColor
                                   backgroundColor:[UIColor grayColor]
                                         tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                                             [[NSNotificationCenter defaultCenter] postNotificationName:kNoticeWatchUserInfo object:nil userInfo:@{@"userID":weakSelf.quote.userID}];
                                         }];
    }
    //计算出高度
    YYLabel *label = [[YYLabel alloc] initWithFrame:CGRectMake(0, 0, kTextLabelWidth - 10, CGFLOAT_MAX)];
    label.attributedText = self.commentString;
    label.numberOfLines = 0;
    [label sizeToFit];
    self.commentHeight = label.frame.size.height + 4;
}

/**
 创建评论模型
 @param         text                评论的内容
 @param         responseID          服务器返回的评论ID
 @return                            数据模型
 */
+ (JCMomentResponseModel *)creatNewCommentWithText:(NSString *)text
                                            postID:(NSString *)postID
                                        responseID:(NSString *)responseID
                                     currentUserID:(NSString *)currentUserID
                                   currentUserName:(NSString *)currentUserName
                                         nameColor:(UIColor *)nameColor
                                      contentColor:(UIColor *)contentColor{
    JCMomentResponseModel *model = [JCMomentResponseModel new];
    model.text = text;
    model.postID = postID;
    model.responseID = responseID;
    model.rUserID = currentUserID;
    model.rUserName = currentUserName;
    model.nameColor = nameColor?:kNickNameColor;
    model.contentColor = contentColor?contentColor:kMomentTextColor;
    [model caucalCommentHeight];
    return model;
}

/**
 创建回复模型
 @param         text                回复的内容
 @param         responseID          服务器返回的评论ID
 @param         commentModel        回复的那条评论的数据模型
 @return                            数据模型
 */
+ (JCMomentResponseModel *)creatNewResponseWithText:(NSString *)text
                                         responseID:(NSString *)responseID
                                       commentModel:(JCMomentResponseModel *)commentModel
                                      currentUserID:(NSString *)currentUserID
                                    currentUserName:(NSString *)currentUserName{
    JCMomentResponseModel *model = [JCMomentResponseModel new];
    model.momentModel = commentModel.momentModel;
    model.text = text;
    model.postID = commentModel.postID;
    model.responseID = responseID;
    model.parentID = commentModel.responseID;
    model.rUserID = currentUserID;
    model.rUserName = currentUserName;
    JCMomentQuotoModel *quoto = [JCMomentQuotoModel new];
    quoto.userID = commentModel.rUserID;
    quoto.userName = commentModel.rUserName;
    model.quote = quoto;
    model.nameColor = commentModel.momentModel.nameColor;
    model.contentColor = commentModel.momentModel.contentColor;
    [model caucalCommentHeight];
    return model;
}

@end











@implementation JCMomentQuotoModel

/**
 创建回复谁的评论
 @param         sourceDic           源数据
 @return                            解析好的模型
 */
+ (instancetype)creatModelWithDictionary:(NSDictionary *)sourceDic{
    if (sourceDic.count == 0 || sourceDic == nil) {
        return nil;
    }
    JCMomentQuotoModel *quote = [[JCMomentQuotoModel alloc] init];
    quote.userID = [NSString checkIfNullWithString:sourceDic[@"UserID"]];
    quote.userName = [NSString checkIfNullWithString:sourceDic[@"UserName"]];
    return quote;
}

@end
