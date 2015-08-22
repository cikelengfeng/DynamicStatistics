//
//  DSEvent.m
//  ds-iphone
//
//  Created by 徐 东 on 14/10/26.
//
//

#import "DSEvent.h"
#import "DSStringValidator.h"

@implementation DSEvent

@synthesize ds_type = _ds_type;
@synthesize ds_action = _ds_action;
@synthesize ds_identifier = _ds_identifier;
@synthesize ds_customInfo = _ds_customInfo;
@synthesize pm_string = _pm_string;

- (instancetype)init
{
    return [self initWithType:nil action:nil identifier:nil];
}

- (id)initWithType:(NSString *)type action:(NSString *)action identifier:(NSString *)ident customInfo:(NSDictionary *)customInfo
{
    if (![DSStringValidator isValidString:type] || ![DSStringValidator isValidString:action] || ![DSStringValidator isValidString:ident]) {
        DSLog(@"any of the three args MUST NOT be invalid string");
        return nil;
    }
    self = [super init];
    if (self) {
        _ds_type = [type copy];
        _ds_action = [action copy];
        _ds_identifier = [ident copy];
        _ds_customInfo = [customInfo copy];
    }
    return self;
}

- (instancetype)initWithType:(NSString *)type action:(NSString *)action identifier:(NSString *)ident
{
    return [self initWithType:type action:action identifier:ident customInfo:nil];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ type : %@ , action : %@ , identifier : %@ }",self.ds_type,self.ds_action,self.ds_identifier];
}

- (NSString *)ds_value
{
    return [NSString stringWithFormat:@"%@_%@_%@",self.ds_type,self.ds_action,self.ds_identifier];
}

- (NSString *)pm_string
{
    if (!_pm_string) {
        _pm_string = [NSString stringWithFormat:@"%@%@%@%@%@%@",[self.ds_type pm_encoded],PatternObjectKeyAttributeSeparator,[self.ds_action pm_encoded],PatternObjectKeyAttributeSeparator,[self.ds_identifier pm_encoded],PatternObjectKeyAttributeSeparator];
    }
    return _pm_string;
}

@end
