//
//  NSString+CheckIsString.h
//  CoolMove
//
//  Created by CA on 15/5/20.
//  Copyright (c) 2015年 CA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (CheckIsString)
+ (NSString *)checkIfNullWithString:(id)obj;
- (BOOL)checkIsEnglishAndNumberWithInCounts:(NSInteger)count;
- (NSString *)trimmingSpecailSymbolWithOutUnderLine;
- (NSString *)trimmingSpecailSymbol;

/**
 *  阿拉伯数字转中文数字
 *
 *  @param arabicNum 阿拉伯数字
 *
 *  @return 中文数字
 */
+(NSString *)translationArabicNum:(NSInteger)arabicNum;

- (NSArray *)getWeeks;

- (NSString *)md5String;

// 找出字符串中的数字
- (NSString *)trimingAllNumber;
// 计算文本大小
- (CGSize)textSizeWithtextMaxSize:(CGSize)maxSize font:(UIFont *)font;

/**
 *  字典转json
 */
+ (NSString*)dictionaryToJson:(id)dic;

// json字符串转字典
+ (id)dictionaryWithJsonString:(NSString *)jsonString;

@end
