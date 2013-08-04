#import "OCFMethodRoutesPair.h"
#import "OCFRoute.h"

#import "SOCKit.h"
#import <objc/runtime.h>

@interface OCFMethodRoutesPair ()

#pragma mark - Properties
@property (nonatomic, copy, readwrite) NSRegularExpression *methodRegularExpression;
@property (nonatomic, copy, readwrite) NSOrderedSet *routes;

@end

@implementation OCFMethodRoutesPair {
    NSMutableOrderedSet *_routes;
}

#pragma mark - Creating
- (instancetype)initWithMethodRegularExpression:(NSRegularExpression *)methodRegularExpression {
    NSParameterAssert(methodRegularExpression);
    self = [super init];
    if(self) {
        self.methodRegularExpression = methodRegularExpression;
        self.routes = [NSOrderedSet orderedSet];
    }
    return self;
}

#pragma mark - Properties
- (NSOrderedSet *)routes {
    return [_routes copy];
}

- (void)setRoutes:(NSOrderedSet *)routes {
    _routes = [routes mutableCopy];
}

#pragma mark - Working with the Routes
- (void)addRoute:(OCFRoute *)route {
    NSParameterAssert(route);
    [_routes addObject:route];
}

- (OCFRoute *)routeForRequestsMatchingPath:(NSString *)requestPath {
    NSParameterAssert(requestPath);
    
    for(OCFRoute *route in _routes) {
        NSString *routePattern = route.pattern;
        SOCPattern *pattern = [SOCPattern patternWithString:routePattern];
        if(![pattern stringMatches:requestPath]) {
            continue;
        }
        // We found a route!
        return route;
    }
    return nil;
}

- (void)setObject:(id)object forKeyedSubscript:(id <NSCopying>)key {
    // key = path pattern
    // object = handler
    NSParameterAssert(key);
    NSParameterAssert(object);
    NSParameterAssert([object_getClass(key) isSubclassOfClass:[NSString class]]); // make sure key is a string
    
    OCFRoute *route = [[OCFRoute alloc] initWithPattern:(NSString *)key requestHandler:object];
    [self addRoute:route];
}

#pragma mark - NSObject
- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" method pattern: '%@', routes: %@", self.methodRegularExpression.pattern, self.routes];
}

@end
