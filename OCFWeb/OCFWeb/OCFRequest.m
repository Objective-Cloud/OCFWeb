// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import "OCFRequest.h"
#import "OCFRequest_Extension.h"
#import "OCFResponse.h"

// Sooner or later OCFRequest should look exactly like Rack::Request:
// https://gist.github.com/ChristianKienle/35a35bb88bd4ba6f731b/raw/043d3ca47889523f501f3439dc8ceea9a04f042f/gistfile1.txt

@implementation OCFRequest

#pragma mark - Creating a Request
- (instancetype)init {
    @throw [NSException exceptionWithName:@"OCFInvalidInitializer" reason:nil userInfo:nil];
}

#pragma mark - Creating Response Objects from Request Objects
- (OCFResponse *)redirectedTo:(NSString *)path {
    NSString *resultingPath = (path != nil ? path : @"/");
    NSString *location = [[NSURL URLWithString:resultingPath relativeToURL:self.URL] absoluteString];
    return [[OCFResponse alloc] initWithStatus:303
                                       headers:@{ @"Location" : location,
                                                  @"Content-Length" : @"0" }
                                          body:nil];
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> %@ %@\nHeaders: %@\nQuery: %@", NSStringFromClass([self class]), self, self.method, self.path, self.headers, self.query];
}

@end
