//
//  JCLikeListModel.h
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCLikeListModel : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *userName;

/**
 创建点赞人模型
 @param         sourceArray         源数据，网络请求回来的数组
 @return                            解析好的数组模型
 */
+ (NSArray <JCLikeListModel *> *)creatModelWithArray:(NSArray <NSDictionary *> *)sourceArray;

@end
