//
//  DSMatchReceiverMock.m
//  ds-iphone
//
//  Created by 徐 东 on 15/2/12.
//
//

#import "DSMatchReceiverMock.h"
#import "DSMatchReceiver.h"

@implementation DSMatchReceiverMock

+ (void)load
{
    [DSMatchReceiverFactory registerReceiverClass:self name:@"mock"];
}

+ (id<DSMatchReceiverProtocol>)matchReceiverWithName:(NSString *)name userInfo:(NSDictionary *)userInfo
{
    return [self new];
}

- (void)onReceiveMatchResult:(DSTrackerResult *)result context:(NSString *)context trackerID:(NSString *)ident
{
    //do nothing
}


@end
