//
//  DSEvent.h
//  ds-iphone
//
//  Created by 徐 东 on 14/10/26.
//
//

#import <Foundation/Foundation.h>
#import "PMObject.h"

#define DSBuildinTokenizorNone @"none"
#define DSBuildinTokenizorAny @"any"
#define DSEventBuildinTokenizorActionAppear @"appear"
#define DSEventBuildinTokenizorActionDisappear @"disappear"

#if DEBUG
#define DSLog(v,...) NSLog(v,## __VA_ARGS__)
#else
#define DSLog(v,...)
#endif

@protocol DSValueProtocol <NSObject>

- (NSString *)ds_value;

@end

@protocol DSIdentificationProtocol <NSObject>

@property (strong,nonatomic) NSString *ds_identifier;
@property (strong,nonatomic) NSString *ds_type;

@end

@protocol DSEventProtocol <NSObject,DSValueProtocol,DSIdentificationProtocol,PMObject>

@property (strong,nonatomic,readonly) NSString *ds_action;
@property (strong,nonatomic) NSDictionary *ds_customInfo;

@end

@interface DSEvent : NSObject<DSEventProtocol>

- (instancetype)initWithType:(NSString *)type action:(NSString *)action identifier:(NSString *)ident;
- (instancetype)initWithType:(NSString *)type action:(NSString *)action identifier:(NSString *)ident customInfo:(NSDictionary *)customInfo;

@end
