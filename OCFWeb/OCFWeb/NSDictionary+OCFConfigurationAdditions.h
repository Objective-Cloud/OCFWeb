#import <Foundation/Foundation.h>

@interface NSDictionary (OCFConfigurationAdditions)

#pragma mark - Accessing Values
- (NSInteger)defaultStatus_ocf;
- (NSDictionary *)defaultHeaders_ocf;
- (NSString *)defaultContentType_ocf;

@end
