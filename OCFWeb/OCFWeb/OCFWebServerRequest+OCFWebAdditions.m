#import "OCFWebServerRequest+OCFWebAdditions.h"

@implementation OCFWebServerRequest (OCFWebAdditions)

#pragma mark - Additional Parameters
- (NSDictionary *)additionalParameters_ocf {
    return @{};
}

#pragma mark - Convenience
- (NSData *)data_ocf {
    return nil;
}

@end


@implementation OCFWebServerDataRequest (OCFAdditions)

#pragma mark - Convenience
- (NSData *)data_ocf {
    return self.data;
}

@end

@implementation OCFWebServerFileRequest (OCFAdditions)

#pragma mark - Convenience
- (NSData *)data_ocf {
    if(self.filePath == nil) {
        return nil;
    }
    NSError *error = nil;
    NSURL *fileURL = [NSURL fileURLWithPath:self.filePath];
    NSData *result = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingMappedIfSafe error:&error];
    if(result == nil) {
        NSLog(@"Failed to generated data from file path %@: %@", self.filePath, error);
        return nil;
    }
    return result;
}

@end

@implementation OCFWebServerMultiPartFormRequest (OCFAdditions)

#pragma mark - Additional Parameters
- (NSDictionary *)additionalParameters_ocf {
    NSMutableDictionary *result = [NSMutableDictionary new];
    [self.arguments enumerateKeysAndObjectsUsingBlock:^(NSString *name, OCFWebServerMultiPartArgument *argument, BOOL *stop) {
        if(argument.string != nil) {
            result[name] = argument.string;
        }
        // FIXME: Handle argument.data and self.files as well.
    }];
    return result;
}

@end