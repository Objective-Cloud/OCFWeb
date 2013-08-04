// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import "OCFRouter.h"
#import "OCFMethodRoutesPair.h"
#import "OCFRoute.h"

#import <SOCKit/SOCKit.h>

@interface OCFRouter ()

#pragma mark - Properties
@property (nonatomic, copy, readwrite) NSOrderedSet *routesByMethodExpression; // contains OCFMethodRoutesPair

@end

@implementation OCFRouter {
    NSMutableOrderedSet *_routesByMethodExpression;
}

#pragma mark - Creating
- (instancetype)init {
    self = [super init];
    if(self) {
        self.routesByMethodExpression = [NSOrderedSet orderedSet];
    }
    return self;
}

#pragma mark - Properties
- (void)setRoutesByMethodExpression:(NSOrderedSet *)routesByMethodExpression {
    _routesByMethodExpression = [routesByMethodExpression mutableCopy];
}

- (NSOrderedSet *)routesByMethodExpression {
    return [_routesByMethodExpression copy];
}

#pragma mark - Working with the Router
- (BOOL)addRouteWithPathPattern:(NSString *)pathPattern methodPattern:(NSString *)methodPattern withBlock:(OCFWebApplicationRequestHandler)requestHandler {
    NSParameterAssert(pathPattern);
    NSParameterAssert(methodPattern);
    NSParameterAssert(requestHandler);
    
    // Find the routes pair for the method pattern
    NSError *error = nil;
    NSRegularExpression *methodExpression = [NSRegularExpression regularExpressionWithPattern:methodPattern options:0 error:&error];
    if(methodExpression == nil) {
        NSLog(@"[Router] Failed to add handler because method pattern is malformed: %@", error);
        return NO;
    }
    
    OCFMethodRoutesPair *routesPairToUse = nil;
    for(OCFMethodRoutesPair *routesPair in _routesByMethodExpression) {
        if(![routesPair.methodRegularExpression isEqual:methodExpression]) {
            continue;
        }
        routesPairToUse = routesPair;
        break;
    }
    if(routesPairToUse == nil) {
        // No routes pair found: create one
        routesPairToUse = [[OCFMethodRoutesPair alloc] initWithMethodRegularExpression:methodExpression];
        [_routesByMethodExpression addObject:routesPairToUse];
    }
    
    OCFRoute *route = [[OCFRoute alloc] initWithPattern:pathPattern requestHandler:requestHandler];
    [routesPairToUse addRoute:route];
    return YES;
}

- (OCFRoute *)routeForRequestWithMethod:(NSString *)method requestPath:(NSString *)requestPath {
    NSParameterAssert(method);
    NSParameterAssert(requestPath);
    for(OCFMethodRoutesPair *routesPair in self.routesByMethodExpression) {
        NSRegularExpression *methodExpression = routesPair.methodRegularExpression;
        NSUInteger numberOfMatches = [methodExpression numberOfMatchesInString:method options:0 range:NSMakeRange(0, [method length])];
        if(numberOfMatches == 0) {
            continue;
        }
        // We found a route pair. Now we have to find a specific route
        for(OCFRoute *route in routesPair.routes) {
            NSString *routePattern = route.pattern;
            SOCPattern *pattern = [SOCPattern patternWithString:routePattern];
            if(![pattern stringMatches:requestPath]) {
                continue;
            }
            // We found a route!
            return route;
        }
    }
    return nil;
}

- (OCFMethodRoutesPair *)methodRoutesPairForRequestWithMethodPattern:(NSString *)methodPattern {
    // Find the routes pair for the method pattern
    NSError *error = nil;
    NSRegularExpression *methodExpression = [NSRegularExpression regularExpressionWithPattern:methodPattern options:0 error:&error];
    if(methodExpression == nil) {
        NSLog(@"[Router] Failed to add handler because method pattern is malformed: %@", error);
        return NO;
    }
    
    OCFMethodRoutesPair *routesPairToUse = nil;
    for(OCFMethodRoutesPair *routesPair in _routesByMethodExpression) {
        if(![routesPair.methodRegularExpression isEqual:methodExpression]) {
            continue;
        }
        routesPairToUse = routesPair;
        break;
    }
    if(routesPairToUse == nil) {
        // No routes pair found: create one
        routesPairToUse = [[OCFMethodRoutesPair alloc] initWithMethodRegularExpression:methodExpression];
        [_routesByMethodExpression addObject:routesPairToUse];
    }
    return routesPairToUse;
}

@end
