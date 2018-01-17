//
//  NSString+CheckIsString.m
//  CoolMove
//
//  Created by CA on 15/5/20.
//  Copyright (c) 2015年 CA. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "NSString+CheckIsString.h"

@implementation NSString (CheckIsString)

+ (NSString *)checkIfNullWithString:(id)obj
{
    
    if (!obj||[obj isEqual:[NSNull null]])
        return @"";
    NSString *tempStr;
    if ([obj isKindOfClass:[NSString class]]) {
        tempStr = obj;
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        tempStr = [obj stringValue];
    }
    return tempStr;
}

- (BOOL)checkIsEnglishAndNumberWithInCounts:(NSInteger)count
{
    NSString *predicateStr = [NSString stringWithFormat:@"^[a-zA-Z0-9]{%d}$",count];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",predicateStr];
    return [predicate evaluateWithObject:self];
}

- (NSString *)trimmingSpecailSymbolWithOutUnderLine
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=\\|~＜＞$€^•'@#$%^&*()+'\""]; //(@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\)
    return [self stringByTrimmingCharactersInSet:set];
}

- (NSString *)trimmingSpecailSymbol
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""];
    return [self stringByTrimmingCharactersInSet:set];
}


/**
 *  将阿拉伯数字转换为中文数字
 */
+(NSString *)translationArabicNum:(NSInteger)arabicNum
{
    NSString *arabicNumStr = [NSString stringWithFormat:@"%ld",(long)arabicNum];
    NSArray *arabicNumeralsArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    NSArray *chineseNumeralsArray = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"零"];
    NSArray *digits = @[@"个",@"十",@"百",@"千",@"万",@"十",@"百",@"千",@"亿",@"十",@"百",@"千",@"兆"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:chineseNumeralsArray forKeys:arabicNumeralsArray];
    
    if (arabicNum < 20 && arabicNum > 9) {
        if (arabicNum == 10) {
            return @"十";
        }else{
            NSString *subStr1 = [arabicNumStr substringWithRange:NSMakeRange(1, 1)];
            NSString *a1 = [dictionary objectForKey:subStr1];
            NSString *chinese1 = [NSString stringWithFormat:@"十%@",a1];
            return chinese1;
        }
    }else{
        NSMutableArray *sums = [NSMutableArray array];
        for (int i = 0; i < arabicNumStr.length; i ++)
        {
            NSString *substr = [arabicNumStr substringWithRange:NSMakeRange(i, 1)];
            NSString *a = [dictionary objectForKey:substr];
            NSString *b = digits[arabicNumStr.length -i-1];
            NSString *sum = [a stringByAppendingString:b];
            if ([a isEqualToString:chineseNumeralsArray[9]])
            {
                if([b isEqualToString:digits[4]] || [b isEqualToString:digits[8]])
                {
                    sum = b;
                    if ([[sums lastObject] isEqualToString:chineseNumeralsArray[9]])
                    {
                        [sums removeLastObject];
                    }
                }else
                {
                    sum = chineseNumeralsArray[9];
                }
                
                if ([[sums lastObject] isEqualToString:sum])
                {
                    continue;
                }
            }
            
            [sums addObject:sum];
        }
        NSString *sumStr = [sums  componentsJoinedByString:@""];
        NSString *chinese = [sumStr substringToIndex:sumStr.length-1];
        return chinese;
    }
}

- (NSArray *)getWeeks {
    NSArray *weeks;
    if (self.length > 2) {
        weeks = [self componentsSeparatedByString:@","];
    } else if ([self isEqualToString:@""]) {
        weeks = @[];
    } else {
        weeks = @[self];
    }
    
    return weeks;
}

- (NSString *)md5String {
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}
- (NSString *)trimingAllNumber {
    
    // Intermediate
    NSMutableString *numberString = [[NSMutableString alloc] init];
    NSString *tempStr;
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    while (![scanner isAtEnd]) {
        // Throw away characters before the first number.
        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
        
        // Collect numbers.
        [scanner scanCharactersFromSet:numbers intoString:&tempStr];
        [numberString appendString:[NSString checkIfNullWithString:tempStr]];
        tempStr = @"";
    }
    return numberString.copy;
    
}

- (CGSize)textSizeWithtextMaxSize:(CGSize)maxSize font:(UIFont *)font
{
    if (self.length == 0) {
        return CGSizeZero;
    }
    NSDictionary *attr = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
}

/**
 * 字典转json
 
 * NSJSONWritingPrettyPrinted  是有换位符的。
 
 * 如果NSJSONWritingPrettyPrinted 是nil 的话 返回的数据是没有 换位符的
 */
+ (NSString*)dictionaryToJson:(id)dic {
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

+ (id)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                             options:0
                                               error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
