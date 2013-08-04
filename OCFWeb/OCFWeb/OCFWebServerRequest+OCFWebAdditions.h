#import "OCFWebServerRequest.h"

@interface OCFWebServerRequest (OCFWebAdditions)

#pragma mark - Additional Parameters
@property (nonatomic, readonly) NSDictionary *additionalParameters_ocf;

#pragma mark - Convenience
@property (nonatomic, readonly) NSData *data_ocf;

@end
