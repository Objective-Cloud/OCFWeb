// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import "OCFResponse.h"

const struct OCFResponseAttributes OCFResponseAttributes = {
	.status = @"status",
	.headers = @"headers",
	.body = @"body",
};

@implementation NSDictionary (OCFResponseAdditions)

- (NSInteger)status_ocf {
    NSNumber *status = self[OCFResponseAttributes.status];
    if(status == nil) {
        return 0;
    }
    return status.integerValue;
}

- (NSDictionary *)headers_ocf {
    return self[OCFResponseAttributes.headers];
}

- (NSData *)body_ocf {
    return self[OCFResponseAttributes.body];
}

@end

@interface OCFResponse ()

#pragma mark - Properties
@property (nonatomic, assign, readwrite) NSInteger status;
@property (nonatomic, copy, readwrite) NSDictionary *headers;
@property (nonatomic, copy, readwrite) NSData *body;

@end

@implementation OCFResponse

#pragma mark - Creating
- (instancetype)initWithStatus:(NSInteger)status headers:(NSDictionary *)headers body:(NSData *)body {
    self = [super init];
    if(self) {
        self.status = status;
        self.headers = (headers == nil) ? @{} : headers;
        self.body = (body == nil) ? [NSData new] : body;
    }
    return self;
}

- (instancetype)initWithProperties:(NSDictionary *)properties {
    NSInteger status = [properties status_ocf];
    NSDictionary *headers = [properties headers_ocf];
    NSData *body = [properties body_ocf];
    return [self initWithStatus:status headers:headers body:body];
}

- (instancetype)init {
    return [self initWithStatus:0 headers:nil body:nil];
}

#pragma mark - Convenience
- (NSString *)contentType {
    return self.headers[@"Content-Type"];
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> Status: %li, Headers: %@", NSStringFromClass([self class]), self, (long)self.status, self.headers];
}
@end
