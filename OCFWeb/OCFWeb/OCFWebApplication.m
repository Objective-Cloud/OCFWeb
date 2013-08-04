#import "OCFWebApplication.h"
#import "OCFWebApplicationDelegate.h"
#import "OCFRouter.h"
#import "OCFRoute.h"
#import "OCFResponse.h"
#import "OCFMustache.h"
#import "OCFRequest+Private.h"

#import "NSDictionary+OCFConfigurationAdditions.h"
#import "OCFWebServerRequest+OCFWebAdditions.h"

// 3rd. Party =>
#import <GRMustache/GRMustache.h>
#import <OCFWebServer/OCFWebServer.h>

@interface OCFWebApplication ()

#pragma mark - Properties
@property (nonatomic, strong) OCFWebServer *server;
@property (nonatomic, strong) OCFRouter *router;
@property (nonatomic, copy) NSDictionary *configuration;
@property (nonatomic, strong) GRMustacheTemplateRepository *templateRepository;

@end

@implementation OCFWebApplication 
//+ (void)initialize
//{
//    if(self == [SinApplication class])
//    {
//#if !defined(NS_BLOCK_ASSERTIONS)
//        // Debug configuration: keep GRMustache quiet
//        [GRMustache preventNSUndefinedKeyExceptionAttack];
//#endif
//        
//    }
//}

#pragma mark - Creating an Application

// This initializer is meant to be for testing purposes only.
// The reason is that OCFWebApplication needs to know the bundle of the enclosing
// application to that it can find the templates for the Mustache template engine.
// You should have no need to use this initializer at all. Using -init is good enough.
- (instancetype)initWithBundle:(NSBundle *)bundle {
    self = [super init];
    if(self) {
        self.router = [OCFRouter new];
        self.templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:(bundle != nil ? bundle : [NSBundle mainBundle])];
        [self _setupDefaultConfiguration];
    }
    return self;

}

- (instancetype)init {
    return [self initWithBundle:nil];
}

- (void)_setupDefaultConfiguration {
    NSDictionary *staticHeaders = @{ @"X-XSS-Protection" : @"1; mode=block",
                                     @"X-Content-Type-Options" : @"nosniff",
                                     @"X-Frame-Options" : @"SAMEORIGIN"
                                   };
    self.configuration = @{ @"status" : @200, @"headers" : staticHeaders, @"contentType" : @"text/html;charset=utf-8" };
}

#pragma mark - Adding Handlers
- (void)handle:(NSString *)methodPattern requestsMatching:(NSString *)pathPattern withBlock:(OCFWebApplicationRequestHandler)requestHandler {
    NSParameterAssert(methodPattern);
    NSParameterAssert(pathPattern);
    NSParameterAssert(requestHandler);
    self[methodPattern][pathPattern] = requestHandler;
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key {
    NSParameterAssert(key);
    NSParameterAssert([object_getClass(key) isSubclassOfClass:[NSString class]]); // make sure key is a string
    
    // key is a HTTP method regular expression
    // -methodRoutesPairForRequestWithMethodPattern: creates the pair object if it does not already exist.
    return [self.router methodRoutesPairForRequestWithMethodPattern:(NSString *)key];
}

#pragma mark - Controlling the Application
- (void)run {
    [self runOnPort:0];
}

- (void)runOnPort:(NSUInteger)port {
    self.server = [OCFWebServer new];
    __typeof__(self) __weak weakSelf = self;
    [self.server addHandlerWithMatchBlock:^OCFWebServerRequest *(NSString *requestMethod, NSURL *requestURL, NSDictionary *requestHeaders, NSString *urlPath, NSDictionary *urlQuery) {
        Class requestClass = Nil;
        NSString *contentType = requestHeaders[@"Content-Type"];
        
        if(contentType != nil) {
            if([contentType isEqualToString:[OCFWebServerURLEncodedFormRequest mimeType]]) {
                requestClass = [OCFWebServerURLEncodedFormRequest class];
            }
            if([contentType hasPrefix:[OCFWebServerMultiPartFormRequest mimeType]]) {
                requestClass = [OCFWebServerMultiPartFormRequest class];
            }
        }
        
        if(requestClass == Nil) {
            requestClass = [OCFWebServerRequest class];
            NSString *contentLengthAsString = requestHeaders[@"Content-Length"];
            NSInteger contentLength = [contentLengthAsString integerValue];
            if(contentLengthAsString != nil && contentLength > 0) {
                requestClass = [OCFWebServerDataRequest class];
            }
        }
        
        OCFWebServerRequest *result = [[requestClass alloc] initWithMethod:requestMethod URL:requestURL headers:requestHeaders path:urlPath query:urlQuery];
        return result;
    } processBlock:^void(OCFWebServerRequest *request, OCFWebServerResponseBlock responseBlock) {
        NSString *requestMethod = request.method;

        
        // Method Overriding
        NSDictionary *requestParameters = [request additionalParameters_ocf];
        if(requestParameters[@"_method"] != nil) {
            requestMethod = requestParameters[@"_method"];
        }
        
        OCFRoute *route = [weakSelf.router routeForRequestWithMethod:requestMethod requestPath:request.path];
        
        if(route == nil) {
            NSLog(@"[WebApplication] No route found for %@ %@.", request.method, request.path);
            OCFResponse *response = nil;
            if(weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(application:responseForRequestWithNoAssociatedHandler:)]) {
                OCFRequest *webRequest = [[OCFRequest alloc] initWithWebServerRequest:request parameters:nil];
                response = [weakSelf.delegate application:weakSelf responseForRequestWithNoAssociatedHandler:webRequest];
            } else {
                // The delegate did not return anything useful so we have to generate a 404 response
                response = [[OCFResponse alloc] initWithStatus:404 headers:nil body:nil];
            }
            
            responseBlock([weakSelf makeValidWebServerResponseWithResponse:response]);
            return;
        }
        
        NSDictionary *parameters = [weakSelf parametersFromRequest:request withRoute:route];

        OCFRequest *webRequest = [[OCFRequest alloc] initWithWebServerRequest:request parameters:parameters];
        route.requestHandler(webRequest, ^(id response) {
            if([response isKindOfClass:[OCFResponse class]]) {
                responseBlock([weakSelf makeValidWebServerResponseWithResponse:response]);
                return;
            }
            
            if([response isKindOfClass:[NSString class]]) {
                OCFResponse *webRequest = [[OCFResponse alloc] initWithStatus:0 headers:nil body:[response dataUsingEncoding:NSUTF8StringEncoding]];
                responseBlock([weakSelf makeValidWebServerResponseWithResponse:webRequest]);
                return;
            }
            
            if([response isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dictionaryResponse = response;
                OCFResponse *webResponse = [[OCFResponse alloc] initWithProperties:dictionaryResponse];
                responseBlock([weakSelf makeValidWebServerResponseWithResponse:webResponse]);
                return;
            }
            
            if([response isKindOfClass:[OCFMustache class]]) {
                OCFMustache *mustache = response;
                
                // Evaluate
                NSError *repositoryError = nil;
                GRMustacheTemplate *template = [weakSelf.templateRepository templateNamed:mustache.name error:&repositoryError];
                if(template == nil) {
                    NSLog(@"Failed to load templace: %@", repositoryError);
                    responseBlock(nil);
                    return;
                }
                
                NSError *renderError = nil;
                NSString *renderedObject = [template renderObject:mustache.object error:&renderError];
                if(renderedObject == nil) {
                    NSLog(@"Failed to render object (%@): %@", mustache.object, renderError);
                    responseBlock(nil);
                    return;
                }
                
                OCFResponse *webResponse = [[OCFResponse alloc] initWithStatus:200 headers:nil body:[renderedObject dataUsingEncoding:NSUTF8StringEncoding]];
                responseBlock([weakSelf makeValidWebServerResponseWithResponse:webResponse]);
                return;
            }
            responseBlock(nil); // FIXME: Terrasphere crashes
            return;
        });
    }];
    [self.server startWithPort:port bonjourName:nil];
}

- (void)stop {
    NSAssert(self.server != nil, @"Called -stop with no running server.");
    [self.server stop];
}

#pragma mark - Properties
- (NSUInteger)port {
    if(self.server == nil) {
        return 0;
    }
    return self.server.port;
}

#pragma mark - Aspects
// Imporant: The response passed to this method is valid according to the configuration.
//           This method SHOULD return a respons which is valid according to the configuration.
- (OCFResponse *)willDeliverResponse:(OCFResponse *)response {
    OCFResponse *result = response;

    // Ask the Delegate first
    if([self.delegate respondsToSelector:@selector(application:willDeliverResponse:)]) {
        OCFResponse *responseFromDelegate = [self.delegate application:self willDeliverResponse:response];
        if(responseFromDelegate != nil) {
            result = responseFromDelegate;
        }
    }
    
    // Last chance for SinApplication to modify the response
    return result;
}

#pragma mark - Private Helper Methods
- (NSDictionary *)parametersFromRequest:(OCFWebServerRequest *)request withRoute:(OCFRoute *)route {
    NSDictionary *patternParameters = [route parametersWithRequestPath:request.URL.path];
    
    NSMutableDictionary *result = [NSMutableDictionary new];
    [result addEntriesFromDictionary:patternParameters];
    
    NSDictionary *requestParameters = [request additionalParameters_ocf];
    [result addEntriesFromDictionary:requestParameters];
    
    if(request.query != nil) {
        [result addEntriesFromDictionary:request.query];
    }
    return result;
}

// Pass a potential invalid response to this method.
- (OCFResponse *)makeResponseValidAccordingToConfiguration:(OCFResponse *)response {
    NSParameterAssert(response);
    
    // Check the status
    NSInteger status = response.status;
    if(status == 0) {
        status = self.configuration.defaultStatus_ocf;
    }
    
    // Headers and Content-Type
    NSMutableDictionary *mutableHeaders = [response.headers mutableCopy];
    
    if(response.contentType == nil) {
        mutableHeaders[@"Content-Type"] = self.configuration.defaultContentType_ocf;
    }
    
    [mutableHeaders addEntriesFromDictionary:self.configuration.defaultHeaders_ocf];
        
    OCFResponse *validResponse = [[OCFResponse alloc] initWithStatus:status headers:mutableHeaders body:response.body];
    return validResponse;
}

- (OCFWebServerResponse *)makeValidWebServerResponseWithResponse:(OCFResponse *)response {
    NSParameterAssert(response);
    OCFResponse *validResponse = [self makeResponseValidAccordingToConfiguration:response];
    OCFResponse *modifiedResponse = [self willDeliverResponse:validResponse];
    validResponse = [self makeResponseValidAccordingToConfiguration:modifiedResponse];
    return [self _makeWebServerResponseWithResponse:validResponse];
}

- (OCFWebServerResponse *)_makeWebServerResponseWithResponse:(OCFResponse *)response {
    NSParameterAssert(response);
    
    OCFWebServerResponse *result = [OCFWebServerDataResponse responseWithData:response.body contentType:response.contentType];
    [response.headers enumerateKeysAndObjectsUsingBlock:^(NSString *headerName, NSString *headerValue, BOOL *stop) {
        [result setValue:headerValue forAdditionalHeader:headerName];
    }];
    result.statusCode = response.status;
    
    return result;
}

@end
