#import <Foundation/Foundation.h>

@interface OCFRequest : NSObject

#pragma mark - Properties
@property (nonatomic, copy, readonly) NSString *method;
@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSDictionary *headers;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSDictionary *query;
@property (nonatomic, copy, readonly) NSString *contentType;
@property (nonatomic, assign, readonly) NSUInteger contentLength;
@property (nonatomic, copy, readonly) NSData *data; // not the raw contents of the request
@property (nonatomic, copy, readonly) NSDictionary *parameters; // union of GET, POST and Pattern-Parameters 

@end
