// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import <Foundation/Foundation.h>

typedef void(^OCFResponseHandler)(id response);

@class OCFResponse;

@interface OCFRequest : NSObject

#pragma mark - Properties
@property (nonatomic, copy, readonly) NSString *method;
@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSDictionary *headers;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSDictionary *query;
@property (nonatomic, copy, readonly) NSString *contentType;
@property (nonatomic, assign, readonly) NSUInteger contentLength;
@property (nonatomic, copy, readonly) NSData *data; // not the raw contents of the request
@property (nonatomic, copy, readonly) NSDictionary *parameters; // union of GET, POST and Pattern-Parameters


#pragma mark - Responding
@property (nonatomic, copy) OCFResponseHandler respondWith;
- (void)respondWith:(id)response;
- (OCFResponse *)redirectedTo:(NSString *)path;

// This method is bad:
// 1. Is assumes that body contains JSON data
// 2. Its name is confusing
// Because of that this method will be replaced with something else soon. Don't use it.
- (void)respondBadRequestStatusWithBody:(NSData *)body; // TODO: make it better

@end
