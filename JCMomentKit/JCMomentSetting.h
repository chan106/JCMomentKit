//
//  JCMomentSetting.h
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#ifndef JCMomentSetting_h
#define JCMomentSetting_h
#import "JCMomentKit.h"

/**___________________________________________________________________*/
/**______________________________颜色设置______________________________*/
/**___________________________________________________________________*/
// 用户名颜色
#define     kNickNameColor                  MomentColorFromHex(0x566B94)
// 文本颜色
#define     kMomentTextColor                MomentColorFromHex(0x000000)
// [全文]按钮颜色
#define     kMoreButtonColor                MomentColorFromHex(0x566B94)
// 地址颜色
#define     kAddressColor                   MomentColorFromHex(0x566B94)
// 时间
#define     kPostTimeColor                  MomentColorFromHex(0x999999)
// 浏览数
#define     kWatchCountColor                MomentColorFromHex(0x999999)
// 赞
#define     kLikeColor                      MomentColorFromHex(0x000000)
// 评论
#define     kCommentColor                   MomentColorFromHex(0x000000)
// 点赞人列表
#define     kLIkeListColor                  MomentColorFromHex(0x576b95)
// 评论列表
#define     kCommentListColor               MomentColorFromHex(0x576b95)

/*
|         45                                35         |
|<-15->[HEADER]<-8->[   NAME LABEL  ]<-15->[MENU]<-15->|
|                                                      |
*/
#define     kTextLabelWidth                 ([UIScreen mainScreen].bounds.size.width - 68 - 15)//文本Label宽度 距屏幕左边和右边间隙
#define     kTextLabelNormalHeight          84//未展开时文本最大高度（显示5行时）
#define     kWatchMoreBtnHeight             30
#define     kImageHeight                    (85 * ([UIScreen mainScreen].bounds.size.width/375.0))
#define     kImageMaxWidth                  (0.8*kTextLabelWidth)
#define     kImageMinWidth                  150
#define     kImageHMinWidth                 30//长横图时，最小的高
#define     kTextFont                       14
#define     kLikeListWidth                  (kTextLabelWidth - 16)

#define     kNickNameHeight                 46
#define     kShowTextBtnHeight              30
#define     kHideTextBtnHeight              10
#define     kValidAdressHeight              45
#define     kAvalidAdressHeight             22
#define     kReportHeight                   50
#define     kBottomSpaceHeight              15

#define     kCommentWidth                   160

#define     kInputViewMinHeight             55

#define     kNoticeCancelAllEdit            @"JCMomentCancelAllEdit"
#define     kNoticeWatchUserInfo            @"JCMomentWatchUserInfoClick"

#define     kPlaceholdImage             [UIImage imageNamed:@"placehold_image.png"]

#endif /* JCMomentSetting_h */
