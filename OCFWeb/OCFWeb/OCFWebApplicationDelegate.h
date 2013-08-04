// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import <Foundation/Foundation.h>

@class OCFWebApplication;
@class OCFResponse;
@class OCFRequest;
@protocol OCFWebApplicationDelegate <NSObject>

@optional
- (OCFResponse *)application:(OCFWebApplication *)application willDeliverResponse:(OCFResponse *)response;
- (OCFResponse *)application:(OCFWebApplication *)application responseForRequestWithNoAssociatedHandler:(OCFRequest *)request;

@end
