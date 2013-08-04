#import <Foundation/Foundation.h>

@interface OCFMustache : NSObject

#pragma mark - Creating a Mustache "Response"
+ (instancetype)newMustacheWithName:(NSString *)name object:(id)object;

#pragma mark - Properties
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) id object;

@end
