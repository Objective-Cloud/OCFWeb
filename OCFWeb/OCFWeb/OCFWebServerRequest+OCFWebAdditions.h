// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import <OCFWebServer/OCFWebServerRequest.h>

@interface OCFWebServerRequest (OCFWebAdditions)

#pragma mark - Additional Parameters
@property (nonatomic, readonly) NSDictionary *additionalParameters_ocf;

#pragma mark - Convenience
@property (nonatomic, readonly) NSData *data_ocf;

@end
