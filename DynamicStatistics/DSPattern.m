//
//  DSPattern.m
//  ds-iphone
//
//  Created by 徐 东 on 14/10/26.
//
//

#import "DSPattern.h"
#import "PMMatcher.h"

@interface DSPattern ()

@property (strong,nonatomic) NSString *type;
@property (strong,nonatomic) NSArray *actions;
@property (strong,nonatomic) NSArray *identifiers;
@property (assign,nonatomic) BOOL actionsAreAccepted;
@property (assign,nonatomic) BOOL identifiersAreAccepted;
@property (copy,nonatomic) NSString *ds_matchQuantifier;
@property (strong,nonatomic) PMMatcher *matcher;

@end

@implementation DSPattern

@synthesize ds_matchQuantifier = _ds_matchQuantifier;
@synthesize pm_patternString = _pm_patternString;

- (instancetype)init
{
    return [self initWithType:nil actions:nil accepted:NO identifiers:nil accepted:NO matchQuantifier:nil];
}

- (instancetype)initWithJSON:(id)pattern
{
    if (!([pattern isKindOfClass:[NSDictionary class]] && [pattern count] > 0)) {
        return nil;
    }
    NSString *type = pattern[@"type"];
    if (![type isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSArray *actions = pattern[@"actions"];
    BOOL actionsAreAccepted = ![pattern[@"actions_are_banned"] boolValue];
    NSArray *idents = pattern[@"ids"];
    BOOL identsAreAccepted = ![pattern[@"identifiers_are_banned"] boolValue];
    NSString *matchQuantifier = [pattern[@"match_quantifier"] description];
    return [self initWithType:type actions:actions accepted:actionsAreAccepted identifiers:idents accepted:identsAreAccepted matchQuantifier:matchQuantifier];
}

- (instancetype)initWithType:(NSString *)type actions:(NSArray *)actions accepted:(BOOL)actionsAreAccepted identifiers:(NSArray *)idents accepted:(BOOL)identifiersAreAccepted matchQuantifier:(NSString *)matchQuantifier
{
    self = [super init];
    if (![type isKindOfClass:[NSString class]] || type.length == 0) {
        return nil;
    }
    if (![actions isKindOfClass:[NSArray class]] && actions) {
        return nil;
    }
    if (![idents isKindOfClass:[NSArray class]] && idents) {
        return nil;
    }
    if (self) {
        _type = [type copy];
        _actions = actions.count ? [actions copy] : @[DSBuildinTokenizorAny];
        _actionsAreAccepted = actionsAreAccepted;
        _identifiers = idents.count ? [idents copy] : @[DSBuildinTokenizorAny];
        _identifiersAreAccepted = identifiersAreAccepted;
        _ds_matchQuantifier = matchQuantifier.length > 0 ? [matchQuantifier copy]: DSPatternBuildinTokenizorDefaultQuantifier;
    }
    return self;
}

- (PMMatcher *)matcher
{
    if (!_matcher) {
        _matcher = [[PMMatcher alloc]initWithPattern:self];
    }
    return _matcher;
}

- (NSRange)ds_matchEvents:(NSArray *)events
{
    NSRange result = [self.matcher rangeOfFirstMatchInPMObjects:events range:NSMakeRange(0, events.count)];
    return result;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ type : %@ , actions : %@ , accpeted : %d , identifiers : %@ ,accepted : %d , matchQuantifier : %@ }",self.type,self.actions,self.actionsAreAccepted,self.identifiers,self.identifiersAreAccepted,self.ds_matchQuantifier];
}

- (NSString *)pm_patternString
{
    if (!_pm_patternString) {
        NSString *commonPattern = @"[^_]+";
        NSString *complement = @"^";
        NSString *or = @"|";
        NSString *typePattern = [NSString stringWithFormat:@"%@%@%@",PatternGroupLeftSymbol,([self.type isEqualToString:DSBuildinTokenizorAny] ? commonPattern : [self.type pm_encoded]),PatternGroupRightSymbol];
        NSString *actionPattern = [NSString stringWithFormat:@"%@%@%@%@",self.actionsAreAccepted ? @"" : complement,PatternGroupLeftSymbol,[self.actions containsObject:DSBuildinTokenizorAny] ? commonPattern : [[self.actions valueForKey:@"pm_encoded"] componentsJoinedByString:or],PatternGroupRightSymbol];
        NSString *idPattern = [NSString stringWithFormat:@"%@%@%@%@",self.identifiersAreAccepted ? @"" : complement,PatternGroupLeftSymbol,[self.identifiers containsObject:DSBuildinTokenizorAny] ? commonPattern : [[self.identifiers valueForKey:@"pm_encoded"] componentsJoinedByString:or],PatternGroupRightSymbol];
        _pm_patternString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@",PatternGroupLeftSymbol,PatternGroupLeftSymbol,typePattern,PatternObjectKeyAttributeSeparator,actionPattern,PatternObjectKeyAttributeSeparator,idPattern,PatternObjectKeyAttributeSeparator,PatternGroupRightSymbol,[self.ds_matchQuantifier pm_encoded],PatternGroupRightSymbol];
    }
    return _pm_patternString;
}

@end

@implementation DSPatternGroup

@synthesize pm_patternString = _pm_patternString_g;

- (instancetype)init
{
    return [self initWithPatterns:nil matchQuantifier:nil];
}

- (instancetype)initWithJSON:(id)json
{
    if (![json isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if ([json count] == 0) {
        return nil;
    }
    id patternsJSON = json[DSPatternBuildinJSONKeyPatterns];
    if (!([patternsJSON isKindOfClass:[NSArray class]] && [patternsJSON count] != 0)) {
        return nil;
    }
    NSMutableArray *patterns = [NSMutableArray arrayWithCapacity:[patternsJSON count]];
    for (id patternJSON in patternsJSON) {
        DSPattern *p = [[DSPattern alloc]initWithJSON:patternJSON];
        [patterns addObject:p];
    }
    NSString *matchQuantifier = [json[DSPatternBuildinJSONKeyMatchQuantifier] description];
    return [self initWithPatterns:patterns matchQuantifier:matchQuantifier];
}

- (instancetype)initWithPatterns:(NSArray *)patterns matchQuantifier:(NSString *)matchQuantifier
{
    if (patterns.count == 0) {
        return nil;
    }
    if (self) {
        _eventPatterns = [patterns copy];
        super.ds_matchQuantifier = matchQuantifier.length > 0 ? [matchQuantifier copy]: DSPatternBuildinTokenizorDefaultQuantifier;
    }
    return self;
}

- (NSString *)description
{
    return [self.eventPatterns componentsJoinedByString:@" || "];
}

- (NSString *)pm_patternString
{
    if (!_pm_patternString_g) {
        _pm_patternString_g = [NSString stringWithFormat:@"%@%@%@%@%@%@",PatternGroupLeftSymbol,PatternGroupLeftSymbol,[[self.eventPatterns valueForKey:@"pm_patternString"] componentsJoinedByString:@"|"],PatternGroupRightSymbol,[self.ds_matchQuantifier pm_encoded],PatternGroupRightSymbol];
    }
    return _pm_patternString_g;
}

@end

@implementation DSPatternQueue

@dynamic ds_matchQuantifier;

@synthesize pm_patternString = _pm_patternString_q;

- (instancetype)init
{
    return [self initWithPatterns:nil];
}

- (instancetype)initWithJSON:(id)patternsJSON
{
    if (![patternsJSON isKindOfClass:[NSArray class]]) {
        return nil;
    }
    if ([patternsJSON count] == 0) {
        return nil;
    }
    NSMutableArray *patterns = [NSMutableArray arrayWithCapacity:[patternsJSON count]];
    for (id patternJSON in patternsJSON) {
        DSPattern *p = [[DSPattern alloc]initWithJSON:patternJSON];
        [patterns addObject:p];
    }
    return [self initWithPatterns:patterns];
}

- (instancetype)initWithPatterns:(NSArray *)patterns
{
    if (patterns.count == 0) {
        return nil;
    }
    if (self) {
        _eventPatterns = [patterns copy];
    }
    return self;
}

- (NSString *)ds_matchQuantifier
{
    return DSPatternBuildinTokenizorDefaultQuantifier;
}

- (NSString *)description
{
    return [self.eventPatterns componentsJoinedByString:@" => "];
}

- (NSString *)pm_patternString
{
    if (!_pm_patternString_q) {
        _pm_patternString_q = [NSString stringWithFormat:@"%@%@%@",PatternGroupLeftSymbol,[[self.eventPatterns valueForKey:@"pm_patternString"] componentsJoinedByString:@""],PatternGroupRightSymbol];
    }
    return _pm_patternString_q;
}

@end

@implementation DSPatternFactory

+ (id<DSPatternProtocol>)patternWithJSON:(id)json
{
    id<DSPatternProtocol> pattern = nil;
    if ([json isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[json count]];
        for (id patternJSON in json) {
            id<DSPatternProtocol> patternInQueue = [self patternWithJSON:patternJSON];
            if (patternInQueue) {
                [array addObject:patternInQueue];
            }
        }
        pattern = [[DSPatternQueue alloc]initWithPatterns:array];
    }else if ([json isKindOfClass:[NSDictionary class]]) {
        id patterns = json[@"patterns"];
        if ([patterns isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[patterns count]];
            for (id patternJSON in patterns) {
                id<DSPatternProtocol> patternInGroup = [self patternWithJSON:patternJSON];
                if (patternInGroup) {
                    [array addObject:patternInGroup];
                }
            }
            NSString *quantifier = json[@"match_quantifier"];
            pattern = [[DSPatternGroup alloc]initWithPatterns:array matchQuantifier:quantifier];

        }else {
            pattern = [[DSPattern alloc] initWithJSON:json];
        }
    }
    return pattern;
}

@end

