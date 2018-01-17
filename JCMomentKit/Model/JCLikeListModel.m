//
//  JCLikeListModel.m
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import "JCLikeListModel.h"
#import "NSString+CheckIsString.h"

@implementation JCLikeListModel


/**
 创建点赞人模型
 @param         sourceArray         源数据，网络请求回来的数组
 @return                            解析好的数组模型
 */
+ (NSArray <JCLikeListModel *> *)creatModelWithArray:(NSArray <NSDictionary *> *)sourceArray{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *sourceDic in sourceArray) {
        JCLikeListModel *model = [JCLikeListModel new];
        model.userID = [NSString checkIfNullWithString:sourceDic[@"UserID"]];
        model.userName = [NSString checkIfNullWithString:sourceDic[@"UserName"]];
        [array addObject:model];
    }
    return [array mutableCopy];
}

@end
