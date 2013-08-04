// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import "NSDictionary+OCFConfigurationAdditions.h"

@implementation NSDictionary (OCFConfigurationAdditions)

#pragma mark - Accessing Values
- (NSInteger)defaultStatus_ocf {
    return [self[@"status"] integerValue];
}

- (NSDictionary *)defaultHeaders_ocf {
    return self[@"headers"];
}

- (NSString *)defaultContentType_ocf {
    return self[@"contentType"];
}

@end
