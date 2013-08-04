// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import <Foundation/Foundation.h>

@interface NSDictionary (OCFConfigurationAdditions)

#pragma mark - Accessing Values
- (NSInteger)defaultStatus_ocf;
- (NSDictionary *)defaultHeaders_ocf;
- (NSString *)defaultContentType_ocf;

@end
