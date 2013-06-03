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
#import "NSSet+ConcurrentCollectionOperations.h"

@interface ConcurrentCollectionOperationsTests ()
@property (strong, nonatomic) NSArray *numbers;
@property (strong, nonatomic) NSDictionary *letters;
@property (strong, nonatomic) NSSet *symbols;
@end

@implementation ConcurrentCollectionOperationsTests

- (void)setUp {
    self.numbers = @[ @0, @1, @2, @3, @4, @5, @6, @7, @8, @9 ];
    self.letters = @{ @0: @"A", @1: @"B", @2: @"C", @3: @"D", @4: @"E" };
    self.symbols = [NSSet setWithObjects:@".", @";", @",", @"=", @"*", nil];
}

#pragma mark - NSArray

- (void)testArrayDoublingMap {
    NSArray *mapped = [self.numbers cco_concurrentMap:^(NSNumber *number) {
        return @(2 * number.unsignedIntegerValue);
    }];
    NSArray *doubled = @[ @0, @2, @4, @6, @8, @10, @12, @14, @16, @18 ];
    STAssertEqualObjects(mapped, doubled, @"Failed to perform array doubling map");
}

- (void)testArrayEvenFilter {
    NSArray *filtered = [self.numbers cco_concurrentFilter:^BOOL (NSNumber *number) {
        return number.unsignedIntegerValue % 2 == 0;
    }];
    NSArray *evens = @[ @0, @2, @4, @6, @8 ];
    STAssertEqualObjects(filtered, evens, @"Failed for filter array for evens");
}

#pragma mark - NSDictionary

- (void)testDictionaryAppendingMap {
    NSDictionary *mapped = [self.letters cco_concurrentMap:^(NSString *letter) {
        return [letter stringByAppendingString:@"!"];
    }];
    NSDictionary *appended = @{ @0: @"A!", @1: @"B!", @2: @"C!", @3: @"D!", @4: @"E!" };
    STAssertEqualObjects(mapped, appended, @"Failed to perform dictionary appending map");
}

- (void)testDictionaryVowelFilter {
    NSDictionary *filtered = [self.letters cco_concurrentFilter:^BOOL (NSString *letter) {
        return [@"AEIOU" rangeOfString:letter].location != NSNotFound;
    }];
    NSDictionary *vowels = @{ @0: @"A", @4: @"E" };
    STAssertEqualObjects(filtered, vowels, @"Failed to perform dictionary vowel filter");
}

#pragma mark - NSArray

- (void)testSetExtendingMap {
    NSSet *mapped = [self.symbols cco_concurrentMap:^(NSString *symbol) {
        return [symbol stringByAppendingString:symbol];
    }];
    NSSet *extended = [NSSet setWithObjects:@"..", @";;", @",,", @"==", @"**", nil];
    STAssertEqualObjects(mapped, extended, @"Failed to perform set extending map");
}

- (void)testSetDotFilter {
    NSSet *filtered = [self.symbols cco_concurrentFilter:^BOOL (NSString *symbol) {
        return [symbol isEqualToString:@"."];
    }];
    NSSet *dot = [NSSet setWithObject:@"."];
    STAssertEqualObjects(filtered, dot, @"Failed for filter set for dot");
}

@end
