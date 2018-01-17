//
//  JCMomentKit.h
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#ifndef JCMomentKit_h
#define JCMomentKit_h

#import "JCMomentSetting.h"
#import "JCMomentCell.h"
#import "JCCommentCell.h"
#import "JCMomentsModel.h"
#import "JCLikeListModel.h"
#import "JCMomentImageView.h"
#import "JCMomentView.h"
#import "JCMomentEnum.h"
#import "NSString+CheckIsString.h"
#import "JCMomentLocation.h"
#import "JCMomentCommentInputView.h"

#define         MomentColorFromHex(s)       [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0\
                                                            green:(((s &0xFF00) >>8))/255.0\
                                                             blue:((s &0xFF))/255.0\
                                                            alpha:1.0]


#endif /* JCMomentKit_h */
