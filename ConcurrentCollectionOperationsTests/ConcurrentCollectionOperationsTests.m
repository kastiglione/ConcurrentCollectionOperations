//
//  ConcurrentCollectionOperationsTests.m
//  ConcurrentCollectionOperationsTests
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 Internet. All rights reserved.
//

#import "ConcurrentCollectionOperationsTests.h"
#import "NSArray+ConcurrentCollectionOperations.h"
#import "NSDictionary+ConcurrentCollectionOperations.h"

@interface ConcurrentCollectionOperationsTests ()
@property (strong, nonatomic) NSArray *numbers;
@property (strong, nonatomic) NSDictionary *letters;
@end

@implementation ConcurrentCollectionOperationsTests

- (void)setUp {
    self.numbers = @[ @0, @1, @2, @3, @4, @5, @6, @7, @8, @9 ];
    self.letters = @{ @0: @"A", @1: @"B", @2: @"C", @3: @"D", @4: @"E" };
}

#pragma mark - NSArray

- (void)testIdentityMap {
    NSArray *mapped = [self.numbers cco_concurrentMap:^(NSNumber *number) {
        return number;
    }];
    STAssertEqualObjects(mapped, self.numbers, @"Failed to perform identy map");
}

- (void)testDelaysMap {
    NSArray *mapped = [self.numbers cco_concurrentMap:^(NSNumber *number) {
        sleep(arc4random() % 2);
        return number;
    }];
    STAssertEqualObjects(mapped, self.numbers, @"Failed to perform map with delays");
}

- (void)testDoublingMap {
    NSArray *mapped = [self.numbers cco_concurrentMap:^(NSNumber *number) {
        return @(2 * number.unsignedIntegerValue);
    }];
    NSArray *doubled = @[ @0, @2, @4, @6, @8, @10, @12, @14, @16, @18 ];
    STAssertEqualObjects(mapped, doubled, @"Failed to perform doubling map");
}

- (void)testIdentityFilter {
    NSArray *filtered = [self.numbers cco_concurrentFilter:^BOOL (NSNumber *number) {
        return YES;
    }];
    STAssertEqualObjects(filtered, self.numbers, @"Failed to perform identy filter");
}

- (void)testDelaysFilter {
    NSArray *filtered = [self.numbers cco_concurrentFilter:^(NSNumber *number) {
        sleep(arc4random() % 2);
        return YES;
    }];
    STAssertEqualObjects(filtered, self.numbers, @"Failed to perform filter with delays");
}

- (void)testEvenFilter {
    NSArray *filtered = [self.numbers cco_concurrentFilter:^BOOL (NSNumber *number) {
        return number.unsignedIntegerValue % 2 == 0;
    }];
    NSArray *evens = @[ @0, @2, @4, @6, @8 ];
    STAssertEqualObjects(filtered, evens, @"Failed for filter for evens");
}

#pragma mark - NSDictionary

- (void)testDictionaryIdentityMap {
    NSDictionary *mapped = [self.letters cco_concurrentMap:^(NSString *letter) {
        return letter;
    }];
    STAssertEqualObjects(mapped, self.letters, @"Failed to perform dictionary identy map");
}

- (void)testDictionaryAppendingMap {
    NSDictionary *mapped = [self.letters cco_concurrentMap:^(NSString *letter) {
        return [letter stringByAppendingString:@"!"];
    }];
    NSDictionary *appended = @{ @0: @"A!", @1: @"B!", @2: @"C!", @3: @"D!", @4: @"E!" };
    STAssertEqualObjects(mapped, appended, @"Failed to perform dictionary appending map");
}

- (void)testDictionaryIdentityFilter {
    NSDictionary *filtered = [self.letters cco_concurrentFilter:^BOOL (NSString *letter) {
        return YES;
    }];
    STAssertEqualObjects(filtered, self.letters, @"Failed to perform dictionary identy filter");
}

- (void)testDictionaryVowelFilter {
    NSDictionary *filtered = [self.letters cco_concurrentFilter:^BOOL (NSString *letter) {
        return [@"AEIOU" rangeOfString:letter].location != NSNotFound;
    }];
    NSDictionary *vowels = @{ @0: @"A", @4: @"E" };
    STAssertEqualObjects(filtered, vowels, @"Failed to perform dictionary vowel filter");
}

@end
