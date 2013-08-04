// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import "OCFRequest.h"

@interface OCFRequest ()

#pragma mark - Properties
@property (nonatomic, copy, readwrite) NSString *method;
@property (nonatomic, copy, readwrite) NSURL *URL;
@property (nonatomic, copy, readwrite) NSDictionary *headers;
@property (nonatomic, copy, readwrite) NSString *path;
@property (nonatomic, copy, readwrite) NSDictionary *query;
@property (nonatomic, copy, readwrite) NSString *contentType;
@property (nonatomic, assign, readwrite) NSUInteger contentLength;
@property (nonatomic, copy, readwrite) NSData *data; // not the raw contents of the request
@property (nonatomic, copy, readwrite) NSDictionary *parameters; // union of GET, POST and Pattern-Parameters

@end