#import "OCFAppDelegate.h"
#import <OCFWeb/OCFWeb.h>

@interface OCFAppDelegate ()

@property (nonatomic, strong) OCFWebApplication *app;
@property (nonatomic, strong) NSMutableArray *persons; // contains NSDictionary instances

@end

@implementation OCFAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.persons = [@[ [@{ @"id" : @1, @"firstName" : @"Christian", @"lastName" : @"Kienle" } mutableCopy],
                       [@{ @"id" : @2, @"firstName" : @"Amin", @"lastName" : @"Negm-awad" } mutableCopy],
                       [@{ @"id" : @3, @"firstName" : @"Bill", @"lastName" : @"Gates" } mutableCopy] ] mutableCopy];

    self.app = [OCFWebApplication new];
    
    self.app[@"GET"][@"/persons"]  = ^(OCFRequest *request, OCFResponseHandler respondWith) {
        respondWith([OCFMustache newMustacheWithName:@"Persons" object:@{@"persons" : self.persons}]);
    };
    
    self.app[@"GET"][@"/persons/:id"]  = ^(OCFRequest *request, OCFResponseHandler respondWith) {
        NSNumber *personID = @([request.parameters[@"id"] integerValue]);
        
        // Find the person
        for(NSDictionary *person in self.persons) {
            if([person[@"id"] isEqualToNumber:personID]) {
                respondWith([OCFMustache newMustacheWithName:@"PersonDetail" object:person]);
                return; // person found
            }
        }
        respondWith(@"Error: No Person found");
    };
    
    self.app[@"POST"][@"/persons"]  = ^(OCFRequest *request, OCFResponseHandler respondWith) {
        NSMutableDictionary *person = [NSMutableDictionary dictionaryWithDictionary:request.parameters];
        person[@"id"] = @(self.persons.count + 1);
        [self.persons addObject:person];
        
        respondWith([request redirectedTo:@"/persons"]);
    };

    self.app[@"PUT"][@"/persons/:id"]  = ^(OCFRequest *request, OCFResponseHandler respondWith) {
        NSNumber *personID = @([request.parameters[@"id"] integerValue]);
        for(NSMutableDictionary *person in self.persons) {
            if([person[@"id"] isEqualToNumber:personID]) {
                [person setValuesForKeysWithDictionary:request.parameters];
                respondWith([request redirectedTo:@"/persons"]);
                return; // person updated
            }
        }
        respondWith(@"Error: No Person found");
    };
    
        [self.app run];
    
    NSString *address = [NSString stringWithFormat:@"http://127.0.0.1:%lu/persons", self.app.port];
    NSURL *result = [NSURL URLWithString:address];
    [[NSWorkspace sharedWorkspace] openURL:result];
}

@end
