#import "OCFRoute.h"
#import "SOCKit.h"

@interface OCFRoute ()

#pragma mark - Properties
@property (nonatomic, copy, readwrite) NSString *pattern;
@property (nonatomic, copy, readwrite) OCFWebApplicationRequestHandler requestHandler;

@end

@implementation OCFRoute

#pragma mark - Creating
- (instancetype)initWithPattern:(NSString *)pattern requestHandler:(OCFWebApplicationRequestHandler)requestHandler {
    NSParameterAssert(pattern);
    NSParameterAssert(requestHandler);
    self = [super init];
    if(self) {
        self.pattern = pattern;
        self.requestHandler = requestHandler;
    }
    return self;
}

- (instancetype)init {
    return [self initWithPattern:nil requestHandler:nil];
}

#pragma mark - Working with the Route
- (NSDictionary *)parametersWithRequestPath:(NSString *)path {
    NSParameterAssert(path);
    SOCPattern *patternMatcher = [SOCPattern patternWithString:self.pattern];
    return [patternMatcher parameterDictionaryFromSourceString:path];
}

#pragma mark - Getting parameters from a Path
+ (NSDictionary *)parametersWithRequestPath:(NSString *)path byUsingPattern:(NSString *)pattern {
    if(pattern == nil || path == nil) {
        NSLog(@"WARNING: %@ has been called with nil arguments. Returning empty dictionary.", NSStringFromSelector(_cmd));
        return @{};
    }
    SOCPattern *patternMatcher = [SOCPattern patternWithString:pattern];
    return [patternMatcher parameterDictionaryFromSourceString:path];
}


#pragma mark - NSObject
- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" pattern: '%@'", self.pattern];
}

@end
