//
//  PMObject.h
//  pm-iphone
//
//  Created by 徐 东 on 15/2/11.
//
//

#import "PMObjectEncoder.h"

@protocol PMObject <NSObject>

@property (copy,nonatomic,readonly) NSString *pm_string;

@end

@protocol PMPattern <NSObject>

@property (copy,nonatomic,readonly) NSString *pm_patternString;

@end
