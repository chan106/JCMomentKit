//
//  JCMomentsModel.h
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCMomentSetting.h"
@class JCLikeListModel;
@class JCMomentResponseModel;
@class JCMomentQuotoModel;
@class TYTextContainer;
@class JCUser;

typedef NS_ENUM(NSInteger, ShowMoreBtnSate) {
    ///收起
    ShowMoreBtnSatePackUp,
    ///全文
    ShowMoreBtnSateShow
};

///加V认证
typedef NS_ENUM(NSInteger, VLevelType) {
    ///个人
    VLevelTypePersonUser,
    ///明星
    VLevelTypeStar,
    ///机构
    VLevelTypeOrganization,
    ///媒体
    VLevelTypeNews,
    ///官方
    VLevelTypeOfficial,
};

/**
 ------   帖子数据模型   ------
 */
@interface JCMomentsModel : NSObject

@property (nonatomic, copy) NSString *userName;           //用户名
@property (nonatomic, copy) NSString *userID;             //用户ID
@property (nonatomic, copy) NSString *currentUserID;
@property (nonatomic, copy) NSString *currentUserName;
@property (nonatomic, copy) NSString *topicID;            //帖子ID
@property (nonatomic, copy) NSString *icon;               //头像
@property (nonatomic, assign) VLevelType vLevelType;      //【V】认证
@property (nonatomic, copy) NSString *vImageURL;          //【V】认证链接
@property (nonatomic, copy) NSString *subName;            //副标题
@property (nonatomic, copy) NSString *text;               //文本内容
@property (nonatomic, strong) NSArray <NSString *>*images;              //图片url数组
@property (nonatomic, copy) NSString *videoURL;           //视频播放链接
@property (nonatomic, copy) NSString *videoCoverURL;      //视频封面链接
@property (nonatomic, copy) NSString *reportURL;          //运动报告链接
@property (nonatomic, copy) NSString *reportTitle;
@property (nonatomic, copy) NSString *reportImage;
@property (nonatomic, assign) double longitude;             //经度
@property (nonatomic, assign) double latitude;              //纬度
@property (nonatomic, copy) NSString *address;            //地址
@property (nonatomic, copy) NSString *createTime;         //创建时间
@property (nonatomic, assign) BOOL isLike;                  //自己是否点过赞
@property (nonatomic, assign) NSInteger views;              //阅读数
@property (nonatomic, strong) NSMutableArray <JCLikeListModel *> *likeList;         //点赞人数组
@property (nonatomic, strong) NSMutableAttributedString *likesString;               //点赞人富文本
@property (nonatomic, strong) NSMutableArray <JCMomentResponseModel *> *responseList;//回复列表
/**--------------------------------------------------------------------------------------**/
@property (nonatomic, assign) CGSize singleImageSize;       //单张图片时的size
@property (nonatomic, assign) BOOL isLongImage;
@property (nonatomic, assign) NSInteger normalCellHeight;   //cell高度
@property (nonatomic, assign) NSInteger showMoreCellHeight; //cell高度
@property (nonatomic, assign) BOOL isAninated;              //是否显示动画
@property (nonatomic, assign) NSInteger textLabelHeight;    //文本高度
@property (nonatomic, assign) BOOL isNeedShowMoreBtn;       //是否需要显示更多
@property (nonatomic, assign) ShowMoreBtnSate showMoreSate; //[显示更多]button的状态
@property (nonatomic, assign) NSInteger imagesHeight;       //图片高度
@property (nonatomic, assign) NSInteger timeAdressHeight;   //时间地址高度
@property (nonatomic, assign) NSInteger likeHeight;         //点赞高度
@property (nonatomic, assign) NSInteger commentHeigh;       //评论高度
@property (nonatomic, assign) BOOL isMyMoment;              //是否是我发的帖子
@property (nonatomic, strong) NSIndexPath *indexPath;       //索引
@property (nonatomic, assign) BOOL isHandpicked;            //是否是精选

/**
 创建帖子数据模型
 @param         sourceArray         源数据，网络请求回来的数组
 @return                            解析好的数组模型
 */
+ (NSArray <JCMomentsModel *> *)creatModelWithArray:(NSArray <NSDictionary *> *)sourceArray
                                      currentUserID:(NSString *)currentUserID
                                    currentUserName:(NSString *)currentUserName;

/**
 计算label显示需要的高度
 */
- (CGFloat)caculLabelWithString:(NSString *)string
                          width:(CGFloat)width
                           font:(CGFloat)font;

/**
 计算图片显示需要的高度
 */
- (CGFloat)caculImageViewHeight;

/**
 计算评论所需高度
 */
- (void)calculCommetHeight;

/**
 计算cell高度
 */
- (void)caucalCellHeight;

/**
 点赞、取消赞
 @param         state        YES:点赞 NO:取消赞
 */
- (void)editLikeState:(BOOL)state;

/**
 添加一条评论
 @param         model        评论数据模型
 */
- (void)addCommentModel:(JCMomentResponseModel *)model;

/**
 添加一条回复
 @param         model        回复数据模型
 */
- (void)addResponseModel:(JCMomentResponseModel *)model;

@end









/**
 ------   回复列表数据模型   ------
 */
@interface JCMomentResponseModel : NSObject
@property (nonatomic, weak) JCMomentsModel *momentModel;            //帖子模型
@property (nonatomic, copy) NSString *postID;                     //帖子的ID
@property (nonatomic, copy) NSString *responseID;                 //回复ID
@property (nonatomic, copy) NSString *creatTime;
@property (nonatomic, copy) NSString *text;                       //回复内容
@property (nonatomic, copy) NSString *parentID;                   //(是回复的话才有，是评论则没有)（--> 回复的目标(是一条评论)ID）
@property (nonatomic, copy) NSString *rUserID;                    //评论人ID
@property (nonatomic, copy) NSString *rUserName;                  //评论人昵称
@property (nonatomic, strong) JCMomentQuotoModel *quote;            //(是回复的话才有，是评论则没有)（--> 指向回复的目标）
/**-----------------------------------------------------------------*/
@property (nonatomic, assign) CGFloat commentHeight;                //评论需要的高度
@property (nonatomic, strong) NSMutableAttributedString *commentString;       //评论富文本

/**
 创建回复列表模型
 @param         sourceArray         源数据，网络请求回来的数组
 @param         momentModel         帖子数据模型
 @return                            解析好的数组模型
 */
+ (NSMutableArray <JCMomentResponseModel *> *)creatModelWithArray:(NSArray <NSDictionary *> *)sourceArray momentModel:(JCMomentsModel *)momentModel;

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
                                   currentUserName:(NSString *)currentUserName;

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
                                    currentUserName:(NSString *)currentUserName;

@end










@interface JCMomentQuotoModel : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;

/**
 创建回复谁的评论
 @param         sourceDic           源数据
 @return                            解析好的模型
 */
+ (instancetype)creatModelWithDictionary:(NSDictionary *)sourceDic;

@end
