//
//  DSStringValidator.m
//  Pods
//
//  Created by 徐 东 on 15/8/22.
//
//

#import "DSStringValidator.h"

@implementation DSStringValidator

+ (BOOL)isValidString:(NSString *)str
{
    if (![str isKindOfClass:[NSString class]]) {
        return NO;
    }
    return str.length != 0;
}

@end
