// SSAppDelegate.m
//
// Copyright (c) 2015 Shintaro Kaneko
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SSAppDelegate.h"

#import "SSCommand.h"
#import "SSRequest.h"

@interface SSAppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation SSAppDelegate

- (NSURL *)infoFileURL {
    NSString *filename = @".sshooter.json";
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:filename];
    return [[NSURL alloc] initFileURLWithPath:path];
}

- (NSURL *)temporaryFileURL {
    NSString *filename = [NSString stringWithFormat:@"%d.png", (int)[NSDate date].timeIntervalSince1970];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    return [[NSURL alloc] initFileURLWithPath:path];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSURL *fileURL = [self temporaryFileURL];
    [SSCommand launch:@"screencapture" withArguments:@[@"-i", [NSString stringWithFormat:@"\"%@\"", fileURL.path]]];

    NSURL *infoURL = [self infoFileURL];
    if ([[NSFileManager defaultManager] fileExistsAtPath:infoURL.path]) {
        NSString *string = [NSString stringWithContentsOfURL:infoURL encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        for (NSDictionary *d in json[@"data"]) {
            SSRequest *req = [[SSRequest alloc] init];
            [req requestWithURL:[NSURL URLWithString:d[@"url"]]
                     HTTPMethod:d[@"method"]
                     parameters:d[@"data"]
               constructingBody:^SSConstructingBody *{
                   SSConstructingBody *cb = [SSConstructingBody new];
                   cb.imageData = [NSData dataWithContentsOfURL:fileURL];
                   cb.name = d[@"name"];
                   cb.filename = @"Screenshot.png";
                   return cb;
               }];
        }
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
