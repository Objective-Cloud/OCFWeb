// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import "OCFRoute.h"
#import <SOCKit/SOCKit.h>

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

#pragma mark - NSObject
- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" pattern: '%@'", self.pattern];
}

@end
