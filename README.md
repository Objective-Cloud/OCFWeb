# Overview

OCFWeb is a web application framework written in Objective-C. You can use OCFWeb to create web applications with just a few lines of code. Although OCFWeb is developed and used by [Objective-Cloud.com](http://objective-cloud.com) it does not depend on [Objective-Cloud.com](http://objective-cloud.com). You can use OCFWeb on your own servers (although we prefer you to use [Objective-Cloud.com](http://objective-cloud.com) for that :)) and/or in your own OS X/iOS apps. In fact OCFWeb was designed to be embedded in an existing application written in Objective-C. [Sinatra](http://www.sinatrarb.com/), a web application framework/DSL written in Ruby, has inspired the development of OCFWeb.


# Example: Hello World
The following code snippet shows you how to create a web application that responds to GET requests made to `/`.

```objective-c
    @interface AppDelegate ()
    @property (nonatomic, strong) OCFWebApplication *app;
    @end

    @implementation AppDelegate 

    - (void)applicationDidFinishLaunching:(NSNotification *)n {
      // Create a instance of OCFWebApplication
      self.app = [OCFWebApplication new];
      
      // Add a handler for GET requests
      self.app[@"GET"][@"/"]  = ^(OCFRequest *request) {
        // request contains a lot of properties which describe the incoming request.
        
        // Respond to the request:
        request.respondWith(@"Hello World");
      };
      
      // Run your app on port 8080
      [self.app runOnPort:8080];
    }
    @end
```

Opening [http://127.0.0.1:8080/](http://127.0.0.1:8080/) in your browser should show a web site with the words "Hello World" on it. Nice isn't it? Let's examine the code a little bit more:

* First you create an instance of `OCFWebApplication` by using the `+new` class method. This creates a blank web application for you that does nothing useful.
* Now you can add request handlers to your instance of `OCFWebApplication`. Each handler consists of three parts (HTTP method, path, handler block). The individual parts of the handler added in the example are as follows: 
    1. HTTP method: The method ("GET") is specified in the first pair of square brackets (`[@"GET"]`). This associates your handler with GET-HTTP requests and nothing else.
    2. Path: The path ("/") is specified in the second pair of square brackets (`[@"/"]`). This associates your handler with HTTP requests made to `http://127.0.0.1/` (no additional characters behind the trailing `/`).
    3. Handler block: The handler block comes after the `=` and is a simple C block with the following prototype: `void^(OCFRequest *request)` (no return type and only a single parameter which is the request object).
* Once the handlers have been added the web application is started by sending it `+runOnPort:`. This creates a HTTP server on localhost automatically. Implementation detail: The used HTTP server is called [OCFWebServer](https://github.com/Objective-Cloud/OCFWebServer). Basically OCFWebApplication is just a nice wrapper around [OCFWebServer](https://github.com/Objective-Cloud/OCFWebServer).

A couple of notes: 
Once `+runOnPort:` is called incoming requests are inspected by `OCFWebApplication`. If it finds a handler that is matching the HTTP method and path of the request your handler block is called. `OCFWebApplication` is passing the actual request to your handler block. Then it is your turn: You have to create a response. This can be done synchronously or asynchronously. No matter how you create your response, once you have it your should let `OCFWebApplication` know about your response so that it can be delivered to the client. In the example above the response is just `@"Hello World"`. The request object has a property called `respondWith`. `respondWith` is a block that takes a single argument (of type `id`). You execute this block and pass it the response. The moment this happens `OCFWebApplication` knows about your response and delivers it to the client.

# Getting Started
OCFWeb is using [CocoaPods](http://cocoapods.org/). You can install CocoaPods by running the following commands:

    $ [sudo] gem install cocoapods
    $ pod setup

Then clone or download OCFWeb from GitHub and `cd` into the OCFWeb directory. The directory contains a file called `Podfile`. Now execute the following command:

    $ pod install

This downloads all of the dependencies. Now open the OCFWeb workspace and select the scheme "OCFWeb Mac Example". Click build and run. The example application automatically opens the web app in your default browser.  

# Goals
Developing a web application framework is hard. There are a lot of things that have to be considered and taken care of. This is our first attempt of a web application framework so we tried to concentrate on only a handful of things:

* Be embeddable: Embedding a web application in a native iOS or OS X application should be easy. Imagine you are writing a small iOS app that manages a few photos. Wouldn't it be cool if your app could have an embedded web application that allows the user to add new photos to your app via a browser on his desktop computer? Things like that should be easy to do.
* Be simple: The API of OCFWeb is very simple. If you know two-three OCFWeb specific classes you are good to go. We have also tried to reduce the boilerplate code you have to write to a minimum.
* Be lightweight: OCFWeb itself is a relatively small collection of classes. Last time I counted it had under 1K lines of code. To be honest: Being so compact is only possible by having a couple of dependencies which are also discussed later on.
* Be asynchronous: It should be easy to respond to requests asynchronously.
* Be open for compromises: Let's face it: A web application framework with under 1K lines of code can't handle everything. In fact, such a small framework can only handle a couple of well chosen scenarios. At the moment there is no built in support for HTTP sessions, cookies, authentication, encryption, HTTPS, persistence and security. OCFWeb was not designed to be exposed to the internet. At [Objective-Cloud.com](http://objective-cloud.com) we have proxies in front of every (OCF) web application to eliminate the critical missing bits and pieces. If you are embedding OCFWeb in your own app it is a good idea to let the user control the lifetime of your web app.

# Response Types
The first example shows how easy it is to create a response for an incoming request. As you can see the handler block assigned to the `GET /` route. The moment the handler block has created/computed a response object it is passed to your instance of `OCFWebApplication` by executing the respondWith-block: `request.respondWith(response)`. It has already been mentioned that the only parameter of the respondWith-block is typed with `id`. This allows you to pass different kinds of response objects: In some situations a simple string is a good response and in some other situations you might need something more sophisticated. These are the different kind of response objects you can return:

* A simple string: This will create a HTTP response with a status code of 201, content type will be plain/text and the body will be the unicode representation of the string you returned.
* A dictionary: This allows you to specify a custom status code, body and custom headers. The returned dictionary should look something like this: `@{@"status" : @201, @"headers": @{"Content-type" : @"image/tiff" }, @"body" : [image TIFFRepresentation]}`
* A `OCFResponse` object: `OCFResponse` is a class which represents a response. You can create and pass a `OCFResponse` which gives you full control.
* A `OCFMustache` object: `OCFMustache` is a class that represents a Mustache template response. At the moment [Mustache](http://mustache.github.io/) is the only template engine supported by OCFWeb. You can have template files in your application bundle and then create a `OCFMustache` object by using `+newMustacheWithName:object:` which renders the template so that it is ready to be delivered to the client.

## Example: String Response
The following example shows how to create a response by returning a simple string.

    self.app = [OCFWebApplication new];    
    self.app[@"GET"][@"/"] = ^(OCFRequest *request) {
      request.respondWith(@{ @"Hello World. I am a string." });
    };
    [self.application runOnPort:8080];

This creates a `plain/text` response with a status code of 201. If you don't like the content type or status code for string responses you can change it on a per application basis.

## Example: Dictionary Response
The following example shows how to create a response by returning a dictionary. If you run this example you should be able to use your browser to access the web application which should display your application icon.

    self.app = [OCFWebApplication new];    
    self.app[@"GET"][@"/"] = ^(OCFRequest *request) {
      NSImage *image = [NSImage imageNamed:@"NSApplicationIcon"];
      request.respondWith(@{ @"status" : @201,
                             @"body" : [image TIFFRepresentation],
                             @"headers" : @{ @"Content-Type" : @"image/tiff" }});
    };
    [self.application runOnPort:8080];

## Example: Mustache Response
For the following example to work there must be a file called `Detail.mustache` in the resources of your application. Before using a mustache response you should read the [documentation of the mustache library used by OCFWeb](https://github.com/groue/GRMustache#grmustache). A mustache file basically contains text with placeholders and the underlying mustache engine can automatically fill in the details for you.

    self.app = [OCFWebApplication new];
    self.app[@"GET"][@"/"]  = ^(OCFRequest *request) {
      NSDictionary *person = @{ @"id" : @1,
                                @"firstName" : @"Christian",
                                @"lastName" : @"Kienle" };
      OCFMustache *response = [OCFMustache newMustacheWithName:@"Detail"
                                                        object:person];
      request.respondWith(response);
    };
    [self.app runOnPort:8080];

# Routing and Parameters
When adding a request handler you have to specify a HTTP method and a path. In the examples above we used `GET` as the HTTP method and `/` as the path. OCFWeb let's you do more sophisticated things though.

The HTTP method you specify can be a regular expression. For example: This allows you to route all requests - no matter the request method - to a single handler (by using `@"^.+$"`) as the method. It should be mentioned that doing this is considered bad practice. If you have the exact same handler for different HTTP methods you should rethink your architecture.

The path can be a pattern with placeholders. A placeholder begins with a `:`. This is useful if you have hierarchical URLs/paths like this:

* `GET /countries/`: Lists all countries.
* `GET /countries/Germany/`: Lists only the country called Germany.
* `GET /countries/Germany/states/Berlin/`: Lists only the german state Berlin.

Let's assume you want to add and implement a handler that displays a specific state. You would do that by using the path pattern `/countries/:country/states/:state/`.

## Example: A Route with Placeholders
The following example shows you how to register a handler that is only executed if the request path is matching a specific pattern.

    self.app = [OCFWebApplication new];
    self.app[@"GET"][@"/countries/:country/states/:state/"] = ^(OCFRequest *request) {
      request.respondWith([request.parameters description]);
    };
    [self.application run];

The pattern used (`/countries/:country/states/:state/`) has two placeholders:

1. country and
2. state

If a request with a matching path comes in (`GET /countries/Germany/states/Berlin`) then the specified handler is executed. The `parameters` property of the request passed to the handler is a dictionary which contains two key/value-pairs:

1. `country = Germany`
2. `state = Berlin`

The request handler simply returns a description of the dictionary in this case. So you don't have to parse the path of the request yourself.

## Finding a handler
There is no limit regarding the number of handlers you add. If a request comes in then one out of many handlers has to be picked and executed. OCFWebApplication finds a handler for an incoming request in two steps:

1. Within the first step OCFWebApplication is only using the HTTP method of the request to find handlers which can handle requests of that type: If a GET request comes is all handlers which handle GET requests are determined. Let's call those handlers **handler candidates**. The remaining handlers are ignored from now on.
2. For each **handler candidate** the path pattern is evaluated against the path of the HTTP request. The first handler whose path matches the pattern will be executed. 

# Requirements and Dependencies
OCFWeb runs on

* OS X 10.8+
* iOS 6+

At the moment OCFWeb has the following dependencies (also listed in it's Podfile):

* [OCFWebServer](https://github.com/Objective-Cloud/OCFWebServer): Used to create an HTTP server.
* [SOCKit](https://github.com/jverkoey/sockit): Used for path pattern (matching).
* [GRMustache](https://github.com/groue/GRMustache): Used for mustache responses.

# Who is using OCFWeb?
OCFWeb is used by [Objective-Cloud.com](http://objective-cloud.com). We plan to expose parts of OCFWeb to developers who are running applications hosted on [Objective-Cloud.com](http://objective-cloud.com). 

# How to contribute
Development of OCFWebServer takes place on GitHub. If you find a bug, suspect a bug or have a question feel free to open an issue. Pull requests are very welcome and will be accepted as fast as possible.

# License

OCFWeb is licensed under the MIT license (MIT).