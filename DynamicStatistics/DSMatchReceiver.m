//
//  DSMatchReceiver.m
//  ds-iphone
//
//  Created by 徐 东 on 14/10/26.
//
//

#import "DSMatchReceiver.h"

@interface DSMatchReceiverFactory ()

+ (NSMutableDictionary *)classes;

@end

@implementation DSMatchReceiverFactory

+ (NSMutableDictionary *)classes
{
    static NSMutableDictionary *classes ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [NSMutableDictionary dictionary];
    });
    return classes;
}

+ (void)registerReceiverClass:(Class<DSMatchReceiverProtocol>)clazz name:(NSString *)name
{
    if (clazz && [name isKindOfClass:[NSString class]] && name.length > 0) {
        [self classes][name] = clazz;
    }
}

+ (id<DSMatchReceiverProtocol>)matchReceiverWithJSON:(NSDictionary *)json
{
    id<DSMatchReceiverProtocol> receiver = nil;
    if ([json isKindOfClass:[NSDictionary class]] && json.count > 0) {
        NSString *name = json[@"id"];
        if ([name isKindOfClass:[NSString class]] && name.length) {
            Class<DSMatchReceiverProtocol> c = [self classes][name];
            receiver = [c matchReceiverWithName:name userInfo:json];
        }
    }
    return receiver;
}

@end