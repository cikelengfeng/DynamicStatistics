//
//  PMMatcher.m
//
//  Created by 徐 东 on 15/2/12.
//
//

#import "PMMatcher.h"

@interface PMMatchResult ()

@property (strong,nonatomic) NSArray *pmObjects;
@property (assign,nonatomic) NSRange matchRange;

@end

@implementation PMMatchResult

- (instancetype)initWithPMObject:(NSArray *)objs range:(NSRange)range
{
    self = [super init];
    if (self) {
        _pmObjects = objs;
        _matchRange = range;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithPMObject:nil range:NSMakeRange(NSNotFound, 0)];
}

+ (instancetype)matchResultWithPMObject:(NSArray *)objs range:(NSRange)range
{
    return [[self alloc]initWithPMObject:objs range:range];
}

@end


@interface PMObjectSource : NSObject

@property (strong,nonatomic) NSArray *pmObjects;
@property (strong,nonatomic) NSArray *pmObjectRanges;

+ (instancetype)objectSourceWithPMObjects:(NSArray *)objs;

- (NSString *)stringForSource;
- (NSRange)objectRangeFromStringRange:(NSRange)range;
- (NSRange)stringRangeFromObjectRange:(NSRange)range;

@end

@implementation PMObjectSource

+ (instancetype)objectSourceWithPMObjects:(NSArray *)objs
{
    if (objs.count == 0) {
        return nil;
    }
    PMObjectSource *os = [[PMObjectSource alloc]init];
    os.pmObjects = objs;
    return os;
}

- (NSArray *)pmObjectRanges
{
    if (!_pmObjectRanges) {
        NSMutableArray *ranges = [NSMutableArray arrayWithCapacity:self.pmObjects.count];
        NSUInteger location = 0;
        NSRange range;
        NSUInteger length;
        for (id<PMObject> obj in self.pmObjects) {
            length = obj.pm_string.length;
            range = NSMakeRange(location, length);
            [ranges addObject:NSStringFromRange(range)];
            location += length;
        }
        _pmObjectRanges = [NSMutableArray arrayWithArray:ranges];
    }
    return _pmObjectRanges;
}

- (NSString *)stringForSource
{
    return [[self.pmObjects valueForKey:@"pm_string"] componentsJoinedByString:@""];
}

- (NSRange)objectRangeFromStringRange:(NSRange)strRange
{
    if (strRange.location == NSNotFound) {
        return NSMakeRange(NSNotFound, 0);
    }
    NSRange enumRange;
    
    NSUInteger objLocation = NSNotFound;
    NSUInteger objLength = 0;
    for (int i = 0;i < self.pmObjectRanges.count;i++) {
        enumRange = NSRangeFromString(self.pmObjectRanges[i]);
        if (objLocation == NSNotFound && enumRange.location >= strRange.location) {
            objLocation = i;
        }
        if (objLocation != NSNotFound) {
            if ((enumRange.location + enumRange.length) <= (strRange.location + strRange.length)) {
                objLength += 1;
            }else {
                break;
            }
        }
    }
    return NSMakeRange(objLocation, objLength);
}

- (NSRange)stringRangeFromObjectRange:(NSRange)range
{
    if (range.location == NSNotFound) {
        return NSMakeRange(NSNotFound, 0);
    }
    NSRange headRange = NSRangeFromString(self.pmObjectRanges[range.location]);
    if (range.length == 0) {
        return NSMakeRange(headRange.location, 0);
    }
    NSRange tailRange = NSRangeFromString(self.pmObjectRanges[range.location + range.length - 1]);
    return NSUnionRange(headRange, tailRange);
}

@end

@interface PMMatcher ()

@property (strong,nonatomic) NSRegularExpression *regex;

@end

@implementation PMMatcher

- (instancetype)initWithPattern:(id<PMPattern>)pattern
{
    self = [super init];
    if (self) {
        NSError *error;
        _regex = [NSRegularExpression regularExpressionWithPattern:pattern.pm_patternString options:0 error:&error];
        if (!_regex) {
            return nil;
        }
    }
    return self;
}

- (NSRange)rangeOfFirstMatchInPMObjects:(NSArray *)pmObjects range:(NSRange)range
{
    PMObjectSource *os = [PMObjectSource objectSourceWithPMObjects:pmObjects];
    NSString *eventsString = [os stringForSource];
    NSRange stringMatchedRange = [self.regex rangeOfFirstMatchInString:eventsString options:0 range:[os stringRangeFromObjectRange:range]];
    NSRange objectMatchedRange = [os objectRangeFromStringRange:stringMatchedRange];
    NSLog(@"match events string %@",eventsString);
    NSLog(@"match pattern %@",self.regex.pattern);
    NSLog(@"match range for string %@",NSStringFromRange(stringMatchedRange));
    NSLog(@"match range for object %@",NSStringFromRange(objectMatchedRange));
    return objectMatchedRange;
}

@end
