#import "OCFMustache.h"

@interface OCFMustache ()

#pragma mark - Properties
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) id object;

@end

@implementation OCFMustache

#pragma mark - Creating a Mustache "Response"
- (id)initWithName:(NSString *)name object:(id)object {
    self = [super init];
    if(self) {
        self.name = name;
        self.object = object;
    }
    return self;
}

- (id)init {
    @throw [NSException exceptionWithName:@"OCFInvalidInitializer" reason:nil userInfo:nil];
}

+ (OCFMustache *)newMustacheWithName:(NSString *)name object:(id)object {
    return [[[self class] alloc] initWithName:name object:object];
}


@end
