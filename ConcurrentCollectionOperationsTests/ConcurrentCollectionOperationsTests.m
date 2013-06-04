//
//  ConcurrentCollectionOperationsTests.m
//  ConcurrentCollectionOperationsTests
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 David Lee. All rights reserved.
//

#import "ConcurrentCollectionOperationsTests.h"
#import "NSArray+ConcurrentCollectionOperations.h"
#import "NSDictionary+ConcurrentCollectionOperations.h"
#import "NSSet+ConcurrentCollectionOperations.h"

@interface ConcurrentCollectionOperationsTests ()
@property (strong, nonatomic) NSArray *numbersArray;
@property (strong, nonatomic) NSDictionary *numbersDictionary;
@property (strong, nonatomic) NSSet *numbersSet;

@property (strong, nonatomic) NSArray *doubledNumbers;
@property (strong, nonatomic) NSArray *oddNumbers;
@end

@implementation ConcurrentCollectionOperationsTests

- (void)setUp {
    self.numbersArray = @[ @0, @1, @2, @3, @4, @5, @6, @7, @8, @9 ];
    self.numbersDictionary = [NSDictionary dictionaryWithObjects:self.numbersArray forKeys:self.numbersArray];
    self.numbersSet = [NSSet setWithArray:self.numbersArray];

    self.doubledNumbers = @[ @0, @2, @4, @6, @8, @10, @12, @14, @16, @18 ];
    self.oddNumbers = @[ @1, @3, @5, @7, @9 ];
}

#pragma mark - NSArray

- (void)testArrayDoublingMap {
    NSArray *mapped = [self.numbersArray cco_concurrentMap:^(NSNumber *number) {
        return @(2 * number.unsignedIntegerValue);
    }];
    STAssertEqualObjects(mapped, self.doubledNumbers, @"Failed to perform array doubling map");
}

- (void)testArrayOddFilter {
    NSArray *filtered = [self.numbersArray cco_concurrentFilter:^BOOL (NSNumber *number) {
        return number.unsignedIntegerValue % 2 == 1;
    }];
    STAssertEqualObjects(filtered, self.oddNumbers, @"Failed for filter array for odds");
}

#pragma mark - NSDictionary

- (void)testDictionaryDoublingMap {
    NSDictionary *mapped = [self.numbersDictionary cco_concurrentMap:^(NSNumber *number) {
        return @(2 * number.unsignedIntegerValue);
    }];
    NSArray *mappedNumbers = [mapped.allValues sortedArrayUsingSelector:@selector(compare:)];
    STAssertEqualObjects(mappedNumbers, self.doubledNumbers, @"Failed to perform dictionary doubling map");
}

- (void)testDictionaryOddFilter {
    NSDictionary *filtered = [self.numbersDictionary cco_concurrentFilter:^BOOL (NSNumber *number) {
        return number.unsignedIntegerValue % 2 == 1;
    }];
    NSArray *filteredNumbers = [filtered.allValues sortedArrayUsingSelector:@selector(compare:)];
    STAssertEqualObjects(filteredNumbers, self.oddNumbers, @"Failed to filter dictionary for odds");
}

#pragma mark - NSSet

- (void)testSetDoublingMap {
    NSSet *mapped = [self.numbersSet cco_concurrentMap:^(NSNumber *number) {
        return @(2 * number.unsignedIntegerValue);
    }];
    STAssertEqualObjects(mapped, [NSSet setWithArray:self.doubledNumbers], @"Failed to perform set doubling map");
}

- (void)testSetOddFilter {
    NSSet *filtered = [self.numbersSet cco_concurrentFilter:^BOOL (NSNumber *number) {
        return number.unsignedIntegerValue % 2 == 1;
    }];
    STAssertEqualObjects(filtered, [NSSet setWithArray:self.oddNumbers], @"Failed for filter set for odds");
}

@end
