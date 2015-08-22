//
//  DSTracker.h
//  ds-iphone
//
//  Created by 徐 东 on 14/10/26.
//
//

#import <Foundation/Foundation.h>
#import "DSPattern.h"

#define DSEventEnqueueNotification @"dynamic_statistics_event_enqueue"

@interface DSTrackerResult : NSObject<DSValueProtocol>

@property (strong,nonatomic,readonly) NSArray *events;

- (instancetype)initWithEvents:(NSArray *)events;

@end

@interface DSTracker : NSObject<DSIdentificationProtocol>

@property (strong,nonatomic,readonly) id<DSPatternProtocol> eventPattern;
@property (strong,nonatomic,readonly) NSArray *matchReceivers;
@property (strong,nonatomic,readonly) NSArray *acceptedContexts;
@property (strong,nonatomic,readonly) NSString *minSupportedVersion;
@property (strong,nonatomic,readonly) NSString *maxSupportedVersion;

- (instancetype)initWithID:(NSString *)ident JSON:(id)json;

- (instancetype)initWithID:(NSString *)ident eventPattern:(id<DSPatternProtocol> )pattern matchReceivers:(NSArray *)receivers acceptedContext:(NSArray *)contexts minSupportedVersion:(NSString *)minVersion maxSupportedVersion:(NSString *)maxVersion;

@end

