// SSRequest.m
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

#import "SSRequest.h"

@implementation SSConstructingBody

@end

@implementation SSRequest

- (void)requestWithURL:(NSURL *__nonnull)url
            HTTPMethod:(NSString *__nonnull)method
            parameters:(NSDictionary *__nullable)parameters
      constructingBody:(SSConstructingBody *(^)(void))constructingBody
{
    NSData *(^blockData)(NSString *) = ^(NSString *string) {
        return [string dataUsingEncoding:NSUTF8StringEncoding];
    };

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];

    NSString *boundary = @"ScreenShooterBoundary";
    NSString *kNewLine = @"\r\n";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    for (NSString *name in parameters.allKeys) {
        [body appendData:blockData([NSString stringWithFormat:@"--%@%@", boundary, kNewLine])];
        [body appendData:blockData([NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", name])];
        [body appendData:blockData([NSString stringWithFormat:@"%@%@", kNewLine, kNewLine])];
        [body appendData:blockData([NSString stringWithFormat:@"%@", parameters[name]])];
        [body appendData:blockData(kNewLine)];
    }
    if (constructingBody) {
        SSConstructingBody *cb = constructingBody();
        if (cb.imageData) {
            [body appendData:blockData([NSString stringWithFormat:@"--%@%@", boundary, kNewLine])];
            [body appendData:blockData([NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"%@", cb.name, cb.filename, kNewLine])];
            [body appendData:blockData([NSString stringWithFormat:@"Content-Type: %@", [[self class] contentTypeFromImageData:cb.imageData]])];
            [body appendData:blockData([NSString stringWithFormat:@"%@%@", kNewLine, kNewLine])];
            [body appendData:cb.imageData];
            [body appendData:blockData(kNewLine)];
        }
    }
    [body appendData:blockData([NSString stringWithFormat:@"--%@--", boundary])];
    [request setHTTPBody:body];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [uploadTask resume];
}

+ (NSString *)contentTypeFromImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];

    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

@end
