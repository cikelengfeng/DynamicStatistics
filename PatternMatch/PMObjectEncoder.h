//
//  PMObjectCoder.h
//  pm-iphone
//
//  Created by 徐 东 on 15/3/31.
//
//

#import <Foundation/Foundation.h>

#define PatternObjectKeyAttributeSeparator @"_"

#define PatternGroupLeftSymbol @"("
#define PatternGroupRightSymbol @")"

@interface PMObjectEncoder : NSObject

+ (NSString *)encode:(NSString *)str;

@end

@interface NSString (PMEncoder)

@property (copy,nonatomic,readonly) NSString *pm_encoded;

@end
