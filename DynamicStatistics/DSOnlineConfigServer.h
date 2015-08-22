//
//  DSOnlineConfigServer.h
//  ds-iphone
//
//  Created by 徐 东 on 14/10/27.
//
//

#import <Foundation/Foundation.h>

@protocol DSOnlineConfigServerProtocol <NSObject>

- (void)ds_refreshOnlineConfigWithCompletion:(void(^)())onlineConfigReceivedBlock;
- (void)ds_refreshOnlineConfigWithKeys:(NSArray *)keys completion:(void(^)())onlineConfigReceivedBlock;

- (NSDictionary *)ds_getOnlineParameters;
- (id)ds_getOnlineParameterWithKey:(NSString *)key;

@end

