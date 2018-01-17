//
//  JCMomentViewController.h
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCMomentEnum.h"
@class JCMomentsModel;
@class JCMomentView;
@class JCMomentResponseModel;

@protocol JCMomentViewDelegate <NSObject>

- (void)didTapAction:(JCMomentView *) momentView
          actionType:(MomentTapActionType) actionType
          momentMode:(JCMomentsModel *) momentModel
           indexPath:(NSIndexPath *) indexPath
         inputString:(NSString *) inputString;

@end

@interface JCMomentView : UIView

@property (nonatomic, weak) id <JCMomentViewDelegate> delegate;
@property (nonatomic, copy) void(^requestDataBlock)(MomentDataSourceType requestDataType);
@property (nonatomic, copy) void(^clickVideoBlock)(NSURL *videoURL);

- (void)setMomentDataArray:(NSArray <JCMomentsModel *> *) momentArray
            dataSourceType:(MomentDataSourceType) dataSourceType;
///删除帖子
- (void)deleteMoment:(JCMomentsModel *) deleteMoment;
///给帖子点赞
- (void)likeMoment:(JCMomentsModel *) likeMoment;
///删除评论或者回复
- (void)deleteCommentResponse:(JCMomentsModel *) momentModel
                responseModel:(JCMomentResponseModel *) responseModel
                    indexPath:(NSIndexPath *) indexPath;
///新加一条评论
- (void)addNewCommentForMoment:(JCMomentsModel *) moment
                    responseID:(NSString *) responseID
                commentContent:(NSString *) commentContent;
///新加一条回复
- (void)addNewCommentResponseForMoment:(JCMomentsModel *) moment
                         responseModel:(JCMomentResponseModel *) responseModel
                            responseID:(NSString *) responseID
                       responseContent:(NSString *) responseContent;

@end
