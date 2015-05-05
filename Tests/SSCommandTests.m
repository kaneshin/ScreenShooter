// SSCommandTests.m
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

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "SSCommand.h"

@interface SSCommandTests : XCTestCase

@end

@implementation SSCommandTests

- (void)testWhich {
    XCTAssertEqualObjects([SSCommand which:@""], nil, @"Should be empty.");
    XCTAssertNotEqual([SSCommand lastTerminationStatus], 0, @"Shouldn't be succeeded.");
    XCTAssertEqualObjects([SSCommand which:@"nothingcommand"], nil, @"Should be empty because of not exists.");
    XCTAssertNotEqual([SSCommand lastTerminationStatus], 0, @"Shouldn't be succeeded.");
    XCTAssertEqualObjects([SSCommand which:@"clang"], @"/usr/bin/clang", @"clang compiler must be installed.");
    XCTAssertEqual([SSCommand lastTerminationStatus], 0, @"Should be succeeded.");
}

- (void)testLaunch {
    XCTAssertEqual([SSCommand launch:@"echo" withArguments:@[@"Hello world!"]], 0, @"Pass");
    XCTAssertNotEqual([SSCommand launch:@"ehco" withArguments:@[@"Hello world!"]], 0, @"Pass");
}

@end
