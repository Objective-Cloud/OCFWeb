#import <Foundation/Foundation.h>

#import "OCFWebApplication.h"

@interface OCFRoute : NSObject

#pragma mark - Creating
- (instancetype)initWithPattern:(NSString *)pattern requestHandler:(OCFWebApplicationRequestHandler)requestHandler;

#pragma mark - Properties
@property (nonatomic, copy, readonly) NSString *pattern;
@property (nonatomic, copy, readonly) OCFWebApplicationRequestHandler requestHandler;

#pragma mark - Working with the Route
- (NSDictionary *)parametersWithRequestPath:(NSString *)path;

#pragma mark - Getting parameters from a Path
// This method can be used to get the parameters of a path/pattern pair without having a route.
+ (NSDictionary *)parametersWithRequestPath:(NSString *)path byUsingPattern:(NSString *)pattern;

@end
