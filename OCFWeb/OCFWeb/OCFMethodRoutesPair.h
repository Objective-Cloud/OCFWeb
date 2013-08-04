// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import <Foundation/Foundation.h>

@class OCFRoute;
@interface OCFMethodRoutesPair : NSObject

#pragma mark - Creating
- (instancetype)initWithMethodRegularExpression:(NSRegularExpression *)methodRegularExpression;

#pragma mark - Properties
@property (nonatomic, copy, readonly) NSRegularExpression *methodRegularExpression;
@property (nonatomic, copy, readonly) NSOrderedSet *routes;

#pragma mark - Working with the Routes
- (void)addRoute:(OCFRoute *)route;
- (OCFRoute *)routeForRequestsMatchingPath:(NSString *)requestPath;
- (void)setObject:(id)object forKeyedSubscript:(id <NSCopying>)key;

@end
