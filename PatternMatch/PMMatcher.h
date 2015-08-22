//
//  PMMatcher.h
//
//  Created by 徐 东 on 15/2/12.
//
//

#import <Foundation/Foundation.h>
#import "PMObject.h"

@interface PMMatchResult : NSObject

@property (strong,nonatomic,readonly) NSArray *pmObjects;
@property (assign,nonatomic,readonly) NSRange matchRange;

+ (instancetype)matchResultWithPMObject:(NSArray *)objs range:(NSRange)range;
- (instancetype)initWithPMObject:(NSArray *)objs range:(NSRange)range NS_DESIGNATED_INITIALIZER;

@end

@interface PMMatcher : NSObject

- (instancetype)initWithPattern:(id<PMPattern>)pattern;

//- (NSArray *)matchesInPMObjects:(NSArray *)pmObjects range:(NSRange)range;
//- (NSUInteger)numberOfMatchesInPMObjects:(NSArray *)pmObjects range:(NSRange)range;
//- (PMMatchResult *)firstMatchInPMObjects:(NSArray *)pmObjects range:(NSRange)range;
- (NSRange)rangeOfFirstMatchInPMObjects:(NSArray *)pmObjects range:(NSRange)range;

@end
