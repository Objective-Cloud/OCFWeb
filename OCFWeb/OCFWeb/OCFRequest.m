#import "OCFRequest.h"
#import "OCFRequest_Extension.h"

// Sooner or later SinRequest should look exactly like Rack::Request:
// https://gist.github.com/ChristianKienle/35a35bb88bd4ba6f731b/raw/043d3ca47889523f501f3439dc8ceea9a04f042f/gistfile1.txt

@implementation OCFRequest

#pragma mark - Creating a Request
- (id)init {
    @throw [NSException exceptionWithName:@"OCFInvalidInitializer" reason:nil userInfo:nil];
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> %@ %@\nHeaders: %@\nQuery: %@", NSStringFromClass([self class]), self, self.method, self.path, self.headers, self.query];
}

@end
