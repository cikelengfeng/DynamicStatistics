//
//  DSMatchReceiver.h
//  ds-iphone
//
//  Created by 徐 东 on 14/10/26.
//
//

#import <Foundation/Foundation.h>
#import "DSTracker.h"

@protocol DSMatchReceiverProtocol <NSObject>

- (void)onReceiveMatchResult:(DSTrackerResult *)result context:(NSString *)context trackerID:(NSString *)ident;

+ (id<DSMatchReceiverProtocol>)matchReceiverWithName:(NSString *)name userInfo:(NSDictionary *)userInfo;

@end

@interface DSMatchReceiverFactory : NSObject

+ (id<DSMatchReceiverProtocol>)matchReceiverWithJSON:(NSDictionary *)json;

+ (void)registerReceiverClass:(Class<DSMatchReceiverProtocol>)clazz name:(NSString *)name;

@end

