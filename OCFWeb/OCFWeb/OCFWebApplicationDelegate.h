#import <Foundation/Foundation.h>

@class OCFWebApplication;
@class OCFResponse;
@class OCFRequest;
@protocol OCFWebApplicationDelegate <NSObject>

@optional
- (OCFResponse *)application:(OCFWebApplication *)application willDeliverResponse:(OCFResponse *)response;
- (OCFResponse *)application:(OCFWebApplication *)application responseForRequestWithNoAssociatedHandler:(OCFRequest *)request;

@end
