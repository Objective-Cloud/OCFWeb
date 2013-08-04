#import "OCFRequest+Private.h"
#import "OCFRequest_Extension.h"

#import "OCFWebServerRequest+OCFWebAdditions.h"

@implementation OCFRequest (Private)

#pragma mark - Creating a Request
- (instancetype)initWithMethod:(NSString *)method
                           URL:(NSURL *)URL
                       headers:(NSDictionary *)headers
                          path:(NSString *)path
                         query:(NSDictionary *)query
                   contentType:(NSString *)contentType
                 contentLength:(NSUInteger)contentLength
                          data:(NSData *)data
                    parameters:(NSDictionary *)parameters {
    self = [super init];
    if(self) {
        self.method = method;
        self.URL = URL;
        self.headers = headers;
        self.path = path;
        self.query = query;
        self.contentType = contentType;
        self.contentLength = contentLength;
        self.data = data;
        self.parameters = parameters;
    }
    return self;
}

- (instancetype)initWithWebServerRequest:(OCFWebServerRequest *)request parameters:(NSDictionary *)parameters {
    return [self initWithMethod:request.method
                            URL:request.URL
                        headers:request.headers
                           path:request.path
                          query:request.query
                    contentType:request.contentType
                  contentLength:request.contentLength
                           data:request.data_ocf
                     parameters:parameters];
}

@end


