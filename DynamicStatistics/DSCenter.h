//
//  DynamicStatisticsCenter.h
//
//  Created by 徐 东 on 14/10/24.
//
//

#import <Foundation/Foundation.h>
#import "DSTracker.h"
#import "DSOnlineConfigServer.h"

@interface DSCenter : NSObject

- (instancetype)initWithCenterConfigServer:(id<DSOnlineConfigServerProtocol>)server;

- (void)start;

- (void)enqueueEventWithType:(NSString *)type action:(NSString *)action identifier:(NSString *)ident context:(NSString *)context;

- (void)enqueueEventWithType:(NSString *)type action:(NSString *)action identifier:(NSString *)ident context:(NSString *)context customInfo:(NSDictionary *)customInfo;

- (void)registerTracker:(DSTracker *)tracker;

@end
