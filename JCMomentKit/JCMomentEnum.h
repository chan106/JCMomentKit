//
//  JCMomentEnum.h
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#ifndef JCMomentEnum_h
#define JCMomentEnum_h

typedef NS_ENUM(NSInteger, MomentTapActionType) {
    MomentTapActionTypeHeaderImageView,
    MomentTapActionTypeNickNameLabel,
    MomentTapActionTypeMomentTextLabel,
    MomentTapActionTypeMenuButton,
    MomentTapActionTypeLike,
    MomentTapActionTypeComment,
    MomentTapActionTypeMoreButton,
    MomentTapActionTypeWatchReport,
    MomentTapActionTypeReplayComment,
    MomentTapActionTypeDeleteComment,
    MomentTapActionTypeWatchOtherInfo
};

typedef NS_ENUM(NSInteger, MomentDataSourceType) {
    MomentDataSourceTypeRefresh,
    MomentDataSourceTypeAddMore
};

#endif /* JCMomentEnum_h */
