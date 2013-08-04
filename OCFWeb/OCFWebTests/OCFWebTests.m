#import "OCFWebTests.h"
#import <OCFWeb/OCFWeb.h>

@interface OCFWebTests ()

#pragma mark - Properties
@property (nonatomic, strong) OCFWebApplication *application;
@property (nonatomic) NSURL *applicationURL;

@end

@implementation OCFWebTests

- (void)testParameters {
    self.application[@"GET"][@"/houses/:house/persons/:person"] = ^(OCFRequest *request) {
        NSDictionary *parameters = request.parameters;
        STAssertNotNil(parameters, @"Parameters cannot be nil here.");
        NSString *house = parameters[@"house"];
        STAssertNotNil(house, @"Invalid Parameters.");
        STAssertTrue([@"Kienle" isEqualToString:house], @"Invalid Parameter value.");
        
        NSString *person = parameters[@"person"];
        STAssertNotNil(person, @"Invalid Parameters.");
        STAssertTrue([@"Christian" isEqualToString:person], @"Invalid Parameter value.");
        
        NSString *urlParameterA = parameters[@"urlParameterA"];
        STAssertNotNil(urlParameterA, @"Invalid Parameters.");
        STAssertTrue([@"urlValueB" isEqualToString:urlParameterA], @"Invalid Parameter value.");
        
        request.respondWith(@"OK");
    };
    
    self.application[@"GET"][@"/houses/:house/persons/:person"] = ^(OCFRequest *request) {
        NSDictionary *parameters = request.parameters;
        STAssertNotNil(parameters, @"Parameters cannot be nil here.");
        NSString *house = parameters[@"house"];
        STAssertNotNil(house, @"Invalid Parameters.");
        STAssertTrue([@"Kienle" isEqualToString:house], @"Invalid Parameter value.");
        
        NSString *person = parameters[@"person"];
        STAssertNotNil(person, @"Invalid Parameters.");
        STAssertTrue([@"Christian" isEqualToString:person], @"Invalid Parameter value.");
        
        NSString *urlParameterA = parameters[@"urlParameterA"];
        STAssertNotNil(urlParameterA, @"Invalid Parameters.");
        STAssertTrue([@"urlValueB" isEqualToString:urlParameterA], @"Invalid Parameter value.");
        
        request.respondWith(@"OK");
    };
    [self.application run];
    
    NSURL *requestURL = [self.applicationURL URLByAppendingPathComponent:@"houses" isDirectory:YES];
    requestURL = [requestURL URLByAppendingPathComponent:@"Kienle" isDirectory:YES];
    requestURL = [requestURL URLByAppendingPathComponent:@"persons" isDirectory:YES];
    requestURL = [requestURL URLByAppendingPathComponent:@"Christian" isDirectory:YES];
    NSString *queryString = @"?urlParameterA=urlValueB";
    NSString *fullURLString = [requestURL.absoluteString stringByAppendingString:queryString];
    requestURL = [NSURL URLWithString:fullURLString];
    //    requestURL = [requestURL URLByAppendingPathComponent:@"Christian" isDirectory:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.HTTPMethod = @"GET";
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *responseBody = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    STAssertNotNil(responseBody, @"Error: %@", error);
    NSString *responseString = [[NSString alloc] initWithData:responseBody encoding:NSUTF8StringEncoding];
    STAssertTrue([responseString isEqualToString:@"OK"], @"FAIL");
}

- (void)testNoMatchingRoute {
    // Register a few routes
    self.application[@"GET"][@"/"] = ^(OCFRequest *request) {
        request.respondWith(@"OK");
    };
    self.application[@"GET"][@"/persons"] = ^(OCFRequest *request) {
        request.respondWith(@"OK");
    };
    self.application[@"GET"][@"/persons/:person"] = ^(OCFRequest *request) {
        request.respondWith(@"OK");
    };
    self.application[@"POST"][@"/"] = ^(OCFRequest *request) {
        request.respondWith(@"OK");
    };
    self.application[@"POST"][@"/persons" ] = ^(OCFRequest *request) {
        request.respondWith(@"OK");
    };
    self.application[@"POST"][@"/persons/:person" ] = ^(OCFRequest *request) {
        request.respondWith(@"OK");
    };
    self.application[@"PUT"][@"/" ] = ^(OCFRequest *request) {
        request.respondWith(@"OK");
    };
    self.application[@"PUT"][@"/persons" ] = ^(OCFRequest *request) {
        request.respondWith(@"OK");
    };
    self.application[@"PUT"][@"/persons/:person" ] = ^(OCFRequest *request) {
        request.respondWith(@"OK");
    };
    [self.application run];
    
    // Make a request to a non-existing resource
    NSURL *URL = self.applicationURL;
    URL = [URL URLByAppendingPathComponent:@"HelloWorld"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *responseBody = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    STAssertNotNil(responseBody, @"Error: %@", error);
    STAssertTrue(response.statusCode == 404, @"Wrong status code");
}

- (void)testRoutesWithMethodExpression {
    self.application[@"\\b(GET|PUT)\\b"][@"/houses"] = ^(OCFRequest *request) {
        request.respondWith([@"houses: " stringByAppendingString:request.method]);
    };
    [self.application run];
    
    NSString *PUTHouses = [self responseStringForPath:@"/houses" method:@"PUT" returningResponse:NULL];
    STAssertTrue([PUTHouses isEqualToString:@"houses: PUT"], @"Fail");
    NSString *GETHouses = [self responseStringForPath:@"/houses" method:@"GET" returningResponse:NULL];
    STAssertTrue([GETHouses isEqualToString:@"houses: GET"], @"Fail");
    
}

- (void)testRoutes {
    self.application[@"GET"][@"/"]  = ^(OCFRequest *request) {
        request.respondWith(@"OK");
    };
    [self.application run];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.applicationURL];
    request.HTTPMethod = @"GET";
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *responseBody = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    STAssertNotNil(responseBody, @"Error: %@", error);
    NSString *responseString = [[NSString alloc] initWithData:responseBody encoding:NSUTF8StringEncoding];
    STAssertTrue([responseString isEqualToString:@"OK"], @"FAIL");
}

- (void)testTemplateEngine {
    NSArray *persons = @[ @{ @"firstName" : @"christian", @"lastName" : @"kienle" },
                          @{ @"firstName" : @"amin", @"lastName" : @"negm-awad" },
                          @{ @"firstName" : @"bill", @"lastName" : @"gates" } ];
    
    self.application[@"GET"][@"/persons"] = ^(OCFRequest *request) {
        request.respondWith([OCFMustache newMustacheWithName:@"Persons" object:@{@"persons" : persons}]);
    };
    
    [self.application run];
    
    NSURL *URL = [NSURL URLWithString:@"/persons" relativeToURL:self.applicationURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *responseBody = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    STAssertNotNil(responseBody, @"Error: %@", error);
    NSString *responseString = [[NSString alloc] initWithData:responseBody encoding:NSUTF8StringEncoding];
    
    // Build the string that we expect to see
    NSMutableString *expectedResponseString = [NSMutableString new];
    for(NSDictionary *person in persons) {
        [expectedResponseString appendFormat:@"fn: %@ ln: %@", person[@"firstName"], person[@"lastName"]];
    }
    
    STAssertTrue([responseString isEqualToString:expectedResponseString], @"FAIL");
}

#pragma mark - Properties
- (NSURL *)applicationURL {
    NSAssert(self.application != nil, @"Invalid State");
    NSString *address = [NSString stringWithFormat:@"http://localhost:%lu", self.application.port];
    NSURL *result = [NSURL URLWithString:address];
    return result;
}

#pragma mark - Helper
- (NSData *)responseDataForRequestWithURL:(NSURL *)URL method:(NSString *)method returningResponse:(NSHTTPURLResponse **)response {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = method;
    NSError *error = nil;
    NSData *responseBody = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:&error];
    return responseBody;
}

- (NSString *)responseStringForRequestWithURL:(NSURL *)URL method:(NSString *)method returningResponse:(NSHTTPURLResponse **)response {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = method;
    NSError *error = nil;
    NSData *responseBody = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:&error];
    if(responseBody == nil) {
        return nil;
    }
    NSString *responseString = [[NSString alloc] initWithData:responseBody encoding:NSUTF8StringEncoding];
    return responseString;
}

- (NSString *)responseStringForPath:(NSString *)path method:(NSString *)method returningResponse:(NSHTTPURLResponse **)response {
    NSURL *URL = [self.applicationURL URLByAppendingPathComponent:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = method;
    NSError *error = nil;
    NSData *responseBody = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:&error];
    if(responseBody == nil) {
        return nil;
    }
    NSString *responseString = [[NSString alloc] initWithData:responseBody encoding:NSUTF8StringEncoding];
    return responseString;
}

#pragma mark - Setup + Tear Down
- (void)setUp {
    [super setUp];
    self.application = [[OCFWebApplication alloc] initWithBundle:[NSBundle bundleForClass:[self class]]];
}

- (void)tearDown{
    [self.application stop];
    self.application.delegate = nil;
    self.application = nil;
    [super tearDown];
}


@end
