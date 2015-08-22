//
//  PMObjectCoder.m
//  pm-iphone
//
//  Created by 徐 东 on 15/3/31.
//
//

#import "PMObjectEncoder.h"

@implementation PMObjectEncoder

+ (NSString *)encode:(NSString *)str
{
    str = [str stringByReplacingOccurrencesOfString:PatternObjectKeyAttributeSeparator withString:@"%0"];
    
    return str;
}

@end


@implementation NSString (PMEncoder)

@dynamic pm_encoded;

- (NSString *)pm_encoded
{
    return [PMObjectEncoder encode:self];
}

@end