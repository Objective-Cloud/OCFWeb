#import "OCFAppDelegate.h"
#import <OCFWeb/OCFWeb.h>

@interface OCFAppDelegate ()

@property (nonatomic, strong) OCFWebApplication *app;
@property (nonatomic, strong) NSMutableArray *persons; // contains NSDictionary instances

@end

@implementation OCFAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.persons = [@[ @{ @"firstName" : @"christian", @"lastName" : @"kienle" },
                          @{ @"firstName" : @"amin", @"lastName" : @"negm-awad" },
                          @{ @"firstName" : @"bill", @"lastName" : @"gates" } ] mutableCopy];

    self.app = [OCFWebApplication new];
    
    self.app[@"GET"][@"/persons"]  = ^(OCFRequest *request, OCFResponseHandler respondWith) {
        respondWith([OCFMustache newMustacheWithName:@"Persons" object:@{@"persons" : self.persons}]);
    };
    
    self.app[@"POST"][@"/persons"]  = ^(OCFRequest *request, OCFResponseHandler respondWith) {
        [self.persons addObject:request.parameters];
        respondWith(@"Added!");
    };
    
    [self.app run];
    
    NSString *address = [NSString stringWithFormat:@"http://127.0.0.1:%lu/persons", self.app.port];
    NSURL *result = [NSURL URLWithString:address];
    [[NSWorkspace sharedWorkspace] openURL:result];
}

@end
