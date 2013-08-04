// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import "OCFRequest.h"

@class OCFWebServerRequest;

@interface OCFRequest (Private)

#pragma mark - Creating a Request
- (instancetype)initWithMethod:(NSString *)method
                           URL:(NSURL *)URL
                       headers:(NSDictionary *)headers
                          path:(NSString *)path
                         query:(NSDictionary *)query
                   contentType:(NSString *)contentType
                 contentLength:(NSUInteger)contentLength
                          data:(NSData *)data
                    parameters:(NSDictionary *)parameters;

- (instancetype)initWithWebServerRequest:(OCFWebServerRequest *)request parameters:(NSDictionary *)parameters;

@end
