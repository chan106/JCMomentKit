//
//  NSBundle+JCMoment.m
//  test
//
//  Created by 郭吉成 on 2018/1/17.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import "NSBundle+JCMoment.h"
#import "JCMomentKit.h"

@implementation NSBundle (JCMoment)

+ (NSString *)JCLocalizedStringForKey:(NSString *)key{
    NSString *title = [[NSBundle bundleForClass:[JCMomentView class]] localizedStringForKey:key value:@"" table:@"Localizable"];
    return title;
}

@end
