//
//  DSCenter.m
//  ds-iphone
//
//  Created by 徐 东 on 14/10/24.
//
//

#import "DSCenter.h"

#ifndef DEBUG
#define DEBUG 0
#endif

@interface DSCenter ()

- (void)applyOnlineConfig;

- (NSString *)configParamsWithName:(NSString *)name;

@property (strong,nonatomic) NSMutableArray *eventTrackers;
@property (strong,nonatomic) id<DSOnlineConfigServerProtocol> onlineConfigServer;
@property (weak,nonatomic) dispatch_queue_t workQueue;

@end

@implementation DSCenter

- (instancetype)initWithCenterConfigServer:(id<DSOnlineConfigServerProtocol>)server
{
    self = [super init];
    if (self) {
        _onlineConfigServer = server;
    }
    return self;
}

- (void)registerTracker:(DSTracker *)tracker
{
    dispatch_async(self.workQueue, ^{
        NSString *tID = tracker.ds_identifier;
        NSMutableArray *replaced = [NSMutableArray array];
        [self.eventTrackers enumerateObjectsUsingBlock:^(DSTracker *obj, NSUInteger idx, BOOL *stop) {
            if ([tID isEqualToString:obj.ds_identifier]) {
                [replaced addObject:obj];
            }
        }];
        [self.eventTrackers removeObjectsInArray:replaced];
        [self.eventTrackers addObject:tracker];
    });
}

- (void)start
{
    [[self onlineConfigServer] ds_refreshOnlineConfigWithCompletion:^() {
        [self applyOnlineConfig];
    }];
}

- (void)enqueueEventWithType:(NSString *)type action:(NSString *)action identifier:(NSString *)ident context:(NSString *)context customInfo:(NSDictionary *)customInfo
{
    dispatch_async(self.workQueue, ^{
        id<DSEventProtocol> event = [[DSEvent alloc]initWithType:type action:action identifier:ident customInfo:customInfo];
        if (event) {
            [[NSNotificationCenter defaultCenter]postNotificationName:DSEventEnqueueNotification object:self userInfo:@{@"event":event,@"context":context}];
        }
    });
}

- (void)enqueueEventWithType:(NSString *)type action:(NSString *)action identifier:(NSString *)ident context:(NSString *)context
{
    [self enqueueEventWithType:type action:action identifier:ident context:context customInfo:nil];
}

- (void)applyOnlineConfig
{
    NSString *statisticsConfigs = [self configParamsWithName:@"statistics_config"];
    NSString *flag = DEBUG ? @"development" : @"production";
    id trackerIDs = [NSJSONSerialization JSONObjectWithData:[statisticsConfigs dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil][flag];
    if (![trackerIDs isKindOfClass:[NSArray class]]) {
        return;
    }
    for (NSString *trackerID in trackerIDs) {
        id trackerJSONString = [self configParamsWithName:trackerID];
        id trackerJSON = [NSJSONSerialization JSONObjectWithData:[trackerJSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        DSTracker *tracker = [[DSTracker alloc]initWithID:trackerID JSON:trackerJSON];
        if (tracker) {
            [self registerTracker:tracker];
        }
    }
    
}

#pragma mark - getter / setter

- (dispatch_queue_t)workQueue
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *queueName = [NSString stringWithFormat:@"dynamicstatistics.%lu",(unsigned long)[self hash]];
        queue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}


- (NSString *)configParamsWithName:(NSString *)name
{
    return [self.onlineConfigServer ds_getOnlineParameterWithKey:name];
}

- (NSMutableArray *)eventTrackers
{
    static NSMutableArray *trackers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trackers = [NSMutableArray array];
    });
    return trackers;
}


@end
