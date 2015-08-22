//
//  DSTracker.m
//  ds-iphone
//
//  Created by 徐 东 on 14/10/26.
//
//

#import "DSTracker.h"
#import "DSMatchReceiver.h"

@implementation DSTrackerResult

- (instancetype)init
{
    return [self initWithEvents:nil];
}

- (instancetype)initWithEvents:(NSArray *)events
{
    if (events.count == 0) {
        return nil;
    }
    self = [super init];
    if (self) {
        _events = [events copy];
    }
    return self;
}

- (NSString *)description
{
    return [self.events componentsJoinedByString:@"\n"];
}

- (NSString *)ds_value
{
    return [[self.events valueForKey:NSStringFromSelector(_cmd)] componentsJoinedByString:@"/"];
}

@end

@interface DSTracker ()

@property (strong,nonatomic,readonly) NSMutableArray *trackingEvents;

- (void)notifyMatchReceiversWithTrackerResult:(DSTrackerResult *)result context:(NSString *)context;

+ (BOOL)checkVersionWithMin:(NSString *)min max:(NSString *)max;

@end

@implementation DSTracker

@synthesize ds_identifier = _ds_identifier;
@synthesize ds_type = _ds_type;

- (instancetype)init
{
    return [self initWithID:nil eventPattern:nil matchReceivers:nil acceptedContext:nil minSupportedVersion:nil maxSupportedVersion:nil];
}

- (instancetype)initWithID:(NSString *)ident JSON:(id)trackerJSON
{
    if (!trackerJSON || ident.length == 0) {
        return nil;
    }
    if (![trackerJSON isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    id patternJSON = trackerJSON[@"pattern"];
    id<DSPatternProtocol> pattern = [DSPatternFactory patternWithJSON:patternJSON];
    id matchReceiversJSON = trackerJSON[@"match_receivers"];
    if (![matchReceiversJSON isKindOfClass:[NSArray class]] || [matchReceiversJSON count] == 0) {
        return nil;
    }
    NSMutableArray *receivers = [NSMutableArray arrayWithCapacity:[matchReceiversJSON count]];
    for (id receiverJSON in matchReceiversJSON) {
        if ([receiverJSON isKindOfClass:[NSDictionary class]]) {
            [receivers addObject:receiverJSON];
        }
    }
    
    id acceptedContextsJSON = trackerJSON[@"accepted_contexts"];
    NSMutableArray *acceptedContexts = [NSMutableArray array];
    if ([acceptedContextsJSON isKindOfClass:[NSArray class]] && [acceptedContextsJSON count] > 0) {
        for (id contextJSON in acceptedContextsJSON) {
            if ([contextJSON isKindOfClass:[NSString class]]) {
                [acceptedContexts addObject:contextJSON];
            }
        }
    }
    
    NSString *minVersion = trackerJSON[@"min_supported_version"];
    NSString *maxVersion = trackerJSON[@"max_supported_version"];
    return [self initWithID:ident eventPattern:pattern matchReceivers:receivers acceptedContext:acceptedContexts minSupportedVersion:minVersion maxSupportedVersion:maxVersion];
}

- (instancetype)initWithID:(NSString *)ident eventPattern:(id<DSPatternProtocol>)pattern matchReceivers:(NSArray *)receivers acceptedContext:(NSArray *)contexts minSupportedVersion:(NSString *)minVersion maxSupportedVersion:(NSString *)maxVersion
{
    if (!pattern || ident.length == 0 || ![receivers isKindOfClass:[NSArray class]] || receivers.count == 0) {
        return nil;
    }
    NSMutableArray *matchReceivers = [NSMutableArray array];
    for (NSDictionary *receiverJSON in receivers) {
        id receiver = [DSMatchReceiverFactory matchReceiverWithJSON:receiverJSON];
        if (receiver) {
            [matchReceivers addObject:receiver];
        }
    }
    if (matchReceivers.count == 0) {
        return nil;
    }
    NSString *minSupportedVersion = minVersion;
    if (![minVersion isKindOfClass:[NSString class]] || minVersion.length == 0) {
        minSupportedVersion = @"0";
    }
    NSString *maxSupportedVersion = maxVersion;
    if (![maxVersion isKindOfClass:[NSString class]] || maxVersion.length == 0) {
        maxSupportedVersion = @(INT_MAX).stringValue;
    }
    if (![self.class checkVersionWithMin:minSupportedVersion max:maxSupportedVersion]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _ds_identifier = [ident copy];
        _eventPattern = pattern;
        _matchReceivers = [matchReceivers copy];
        _trackingEvents = [NSMutableArray array];
        if (![contexts isKindOfClass:[NSArray class]] || contexts.count == 0) {
            _acceptedContexts = @[DSBuildinTokenizorAny];
        }else {
            NSSet *temp = [NSSet setWithArray:contexts];
            _acceptedContexts = [temp.allObjects copy];
        }
        _minSupportedVersion = minSupportedVersion;
        _maxSupportedVersion = maxSupportedVersion;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveEventEnqueueNotification:) name:DSEventEnqueueNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DSEventEnqueueNotification object:nil];
}

- (void)didReceiveEventEnqueueNotification:(NSNotification *)notification
{
    id<DSEventProtocol> event = notification.userInfo[@"event"];
    NSString *context = notification.userInfo[@"context"];
    if (![self.acceptedContexts containsObject:context] && ![self.acceptedContexts containsObject:DSBuildinTokenizorAny]) {
        return;
    }
    if (!event) {
        return;
    }
    [self.trackingEvents addObject:event];
    DSLog(@"%@ tracker receive event %@ in context %@",self,event,context);
    NSRange trackedRange = [self.eventPattern ds_matchEvents:self.trackingEvents];
    DSLog(@"evaluating pattern %@ for events %@ match range %@ ",self.eventPattern,self.trackingEvents,NSStringFromRange(trackedRange));
    if (trackedRange.location != NSNotFound) {
        NSArray *events = [self.trackingEvents subarrayWithRange:trackedRange];
        [self.trackingEvents removeObjectsInRange:NSMakeRange(0, trackedRange.location + trackedRange.length)];
        DSTrackerResult *tracked = [[DSTrackerResult alloc]initWithEvents:events];
        DSLog(@"%@ tracker fired with events %@",self.ds_identifier,[tracked ds_value]);
        [self notifyMatchReceiversWithTrackerResult:tracked context:context];
    }
}

- (void)notifyMatchReceiversWithTrackerResult:(DSTrackerResult *)result context:(NSString *)context
{
    for (id<DSMatchReceiverProtocol> receiver in self.matchReceivers) {
        [receiver onReceiveMatchResult:result context:context trackerID:self.ds_identifier];
    }
}

+ (BOOL)checkVersionWithMin:(NSString *)min max:(NSString *)max
{
    static NSString *version ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    });
    NSComparisonResult minr = [version compare:min options:NSNumericSearch];
    NSComparisonResult maxr = [version compare:max options:NSNumericSearch];
    BOOL newerThanMin = minr == NSOrderedDescending || minr == NSOrderedSame;
    BOOL olderThanMax = maxr == NSOrderedAscending || maxr == NSOrderedSame;
    if (newerThanMin && olderThanMax) {
        DSLog(@"tracker is compatible with min %@ max %@ current %@",min,max,version);
    }else {
        DSLog(@"tracker is not compatible with min %@ max %@ current %@",min,max,version);
    }
    return newerThanMin && olderThanMax;
}

@end