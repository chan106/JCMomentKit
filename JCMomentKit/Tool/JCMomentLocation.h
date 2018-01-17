//
//  JCMomentLocation.h
//  PYQDemo
//
//  Created by Guo.JC on 2017/9/2.
//  Copyright © 2017年 coollang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^CompletionHandler)(NSString *addrssString);
typedef void(^GetLocationComplete)(CLLocation *location,NSError *error);

@interface JCMomentLocation : NSObject

+ (instancetype)shareInstance;

/**
 开始定位并获取当前经纬度,返回自己方便链式调用
 @param     locationBlock           获取位置后的回调
 */
- (void)getCLLocationCallBack:(GetLocationComplete)locationBlock;

/**
 停止定位
 */
- (void)stopLocation ;

/**
 经纬度反编译成地址
 @param     latitude                经度
 @param     longitude               纬度
 @param     completionHandler       编译地址结束回调
 */
- (void)reverseGeocodeLocationWithLatitude:(double) latitude
                                 longitude:(double) longitude
                                  complete:(CompletionHandler) completionHandler;


/**
 经纬度反编译成地址
 @param     address                 地址
 @param     geocodeBlock       编译地址结束回调
 */
- (void)geocodeAddressString:(NSString *)address geocodeCallBack:(GetLocationComplete)geocodeBlock;


@end
