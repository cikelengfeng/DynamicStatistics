//
//  DSPattern.h
//  ds-iphone
//
//  Created by 徐 东 on 14/10/26.
//
//

#import <Foundation/Foundation.h>
#import "DSEvent.h"
#import "PMObject.h"

#define DSPatternBuildinTokenizorDefaultQuantifier @"{1}"
#define DSPatternBuildinJSONKeyPatterns @"patterns"
#define DSPatternBuildinJSONKeyMatchQuantifier @"match_quantifier"

@protocol DSPatternProtocol <NSObject>

@property (copy,nonatomic,readonly) NSString *ds_matchQuantifier;// * + ? {n} {n,} {n,m} default is {1} ,note there MUST NOT be any character between "{" and number

- (NSRange)ds_matchEvents:(NSArray *)events;//id<DSEventProtocol>

@end

@interface DSPattern : NSObject<DSPatternProtocol,PMPattern>

@property (strong,nonatomic,readonly) NSString *type;
@property (strong,nonatomic,readonly) NSArray *actions;
@property (strong,nonatomic,readonly) NSArray *identifiers;
@property (assign,nonatomic,readonly) BOOL actionsAreAccepted;
@property (assign,nonatomic,readonly) BOOL identifiersAreAccepted;


- (instancetype)initWithType:(NSString *)type actions:(NSArray *)actions accepted:(BOOL)actionsAreAccepted identifiers:(NSArray *)idents accepted:(BOOL)identifiersAreAccepted matchQuantifier:(NSString *)matchQuantifier;

- (instancetype)initWithJSON:(id)json;//不解析嵌套pattern

@end

@interface DSPatternGroup : DSPattern<DSPatternProtocol,PMPattern>

@property (strong,nonatomic,readonly) NSArray *eventPatterns;

- (instancetype)initWithPatterns:(NSArray *)patterns matchQuantifier:(NSString *)matchQuantifier;

@end

@interface DSPatternQueue : DSPattern<DSPatternProtocol,PMPattern>

@property (strong,nonatomic,readonly) NSArray *eventPatterns;

- (instancetype)initWithPatterns:(NSArray *)patterns;

@end

@interface DSPatternFactory : NSObject

/**
 *  @Author DeanXu, 14-10-26 13:10:51
 *
 *  工厂方法，将json解析成pattern
 *  
 *  @note 该方法会递归解析嵌套的pattern
 */
+ (id<DSPatternProtocol>)patternWithJSON:(id)json;

@end
