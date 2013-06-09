//
//  ConcurrentCollectionOperationsTests.m
//  ConcurrentCollectionOperationsTests
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 David Lee. All rights reserved.
//

#import "ConcurrentCollectionOperationsTests.h"
#import "ConcurrentCollectionOperations.h"

static const NSUInteger kMutableCollectionCount = 10;

@interface ConcurrentCollectionOperationsTests ()
@property (strong, nonatomic) NSArray *numbersArray;
@property (strong, nonatomic) NSDictionary *numbersDictionary;
@property (strong, nonatomic) NSSet *numbersSet;

@property (strong, nonatomic) NSArray *doubledNumbers;
@property (strong, nonatomic) NSArray *oddNumbers;

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
@property (strong, nonatomic) NSMapTable *numbersMapTable;
#endif

@property (strong, nonatomic) NSMutableArray *mutableObjectsArray;

@end

@implementation ConcurrentCollectionOperationsTests

- (void)setUp {
    self.numbersArray = @[ @0, @1, @2, @3, @4, @5, @6, @7, @8, @9 ];
    self.numbersDictionary = [NSDictionary dictionaryWithObjects:self.numbersArray forKeys:self.numbersArray];

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
	NSPointerFunctionsOptions mapTableOptions = (NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality);
	self.numbersMapTable = [NSMapTable mapTableWithKeyOptions:mapTableOptions valueOptions:mapTableOptions];
	for (NSNumber *number in self.numbersArray) {
		[self.numbersMapTable setObject:number forKey:number];
	}
#endif

    self.numbersSet = [NSSet setWithArray:self.numbersArray];

    self.doubledNumbers = @[ @0, @2, @4, @6, @8, @10, @12, @14, @16, @18 ];
    self.oddNumbers = @[ @1, @3, @5, @7, @9 ];

    self.mutableObjectsArray = [NSMutableArray arrayWithCapacity:kMutableCollectionCount];
    for (NSUInteger i = 0; i < kMutableCollectionCount; ++i) {
        [self.mutableObjectsArray addObject:[NSObject new]];
    }
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

#pragma mark - NSMapTable

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

- (void)testMapTableDoublingMap {
    NSMapTable *mapped = [self.numbersMapTable cco_concurrentMap:^(NSNumber *number) {
        return @(2 * number.unsignedIntegerValue);
    }];
    NSArray *mappedNumbers = [mapped.dictionaryRepresentation.allValues sortedArrayUsingSelector:@selector(compare:)];
    STAssertEqualObjects(mappedNumbers, self.doubledNumbers, @"Failed to perform map table doubling map");
}

- (void)testMapTableOddFilter {
    NSMapTable *filtered = [self.numbersMapTable cco_concurrentFilter:^BOOL (NSNumber *number) {
        return number.unsignedIntegerValue % 2 == 1;
    }];
    NSArray *filteredNumbers = [filtered.dictionaryRepresentation.allValues sortedArrayUsingSelector:@selector(compare:)];
    STAssertEqualObjects(filteredNumbers, self.oddNumbers, @"Failed to filter map table for odds");
}

#endif

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

#pragma mark - NSSet

- (void)testOrderedSetDoublingMap {
    NSOrderedSet *numbersOrderedSet = [NSOrderedSet orderedSetWithArray:self.numbersArray];
    NSOrderedSet *mapped = [numbersOrderedSet cco_concurrentMap:^(NSNumber *number) {
        return @(2 * number.unsignedIntegerValue);
    }];
    STAssertEqualObjects(mapped.array, self.doubledNumbers, @"Failed to perform ordered set doubling map");
}

- (void)testOrderedSetOddFilter {
    NSOrderedSet *numbersOrderedSet = [NSOrderedSet orderedSetWithArray:self.numbersArray];
    NSOrderedSet *filtered = [numbersOrderedSet cco_concurrentFilter:^BOOL (NSNumber *number) {
        return number.unsignedIntegerValue % 2 == 1;
    }];
    STAssertEqualObjects(filtered.array, self.oddNumbers, @"Failed for filter ordered set for odds");
}

#pragma mark - Concurrent with Mutation

- (void)testArrayMapConcurrentWithMutation {
    NSArray *mapped = [self.mutableObjectsArray cco_concurrentMap:^(id object) {
        @synchronized (self.mutableObjectsArray) { [self.mutableObjectsArray removeAllObjects]; }
        return object;
    }];
    STAssertEquals(mapped.count, kMutableCollectionCount, @"Failed to perform array map concurrent with mutation");
}

- (void)testArrayFilterConcurrentWithMutation {
    NSArray *filtered = [self.mutableObjectsArray cco_concurrentFilter:^(id object) {
        @synchronized (self.mutableObjectsArray) { [self.mutableObjectsArray removeAllObjects]; }
        return YES;
    }];
    STAssertEquals(filtered.count, kMutableCollectionCount, @"Failed to perform array filter concurrent with mutation");
}

- (void)testDictionaryMapConcurrentWithMutation {
    NSMutableDictionary *mutableObjectsDictionary = [NSMutableDictionary dictionaryWithObjects:self.mutableObjectsArray forKeys:[self.mutableObjectsArray valueForKey:@"description"]];
    NSDictionary *mapped = [mutableObjectsDictionary cco_concurrentMap:^(id object) {
        @synchronized (mutableObjectsDictionary) { [mutableObjectsDictionary removeAllObjects]; }
        return object;
    }];
    STAssertEquals(mapped.count, kMutableCollectionCount, @"Failed to perform dictionary map concurrent with mutation");
}

- (void)testDictionaryFilterConcurrentWithMutation {
    NSMutableDictionary *mutableObjectsDictionary = [NSMutableDictionary dictionaryWithObjects:self.mutableObjectsArray forKeys:[self.mutableObjectsArray valueForKey:@"description"]];
    NSDictionary *filtered = [mutableObjectsDictionary cco_concurrentFilter:^(id object) {
        @synchronized (mutableObjectsDictionary) { [mutableObjectsDictionary removeAllObjects]; }
        return YES;
    }];
    STAssertEquals(filtered.count, kMutableCollectionCount, @"Failed to perform dictionary filter concurrent with mutation");
}

- (void)testSetMapConcurrentWithMutation {
    NSMutableSet *mutableObjectsSet = [NSMutableSet setWithArray:self.mutableObjectsArray];
    NSSet *mapped = [mutableObjectsSet cco_concurrentMap:^(id object) {
        @synchronized (mutableObjectsSet) { [mutableObjectsSet removeAllObjects]; }
        return object;
    }];
    STAssertEquals(mapped.count, kMutableCollectionCount, @"Failed to perform set map concurrent with mutation");
}

- (void)testSetFilterConcurrentWithMutation {
    NSMutableSet *mutableObjectsSet = [NSMutableSet setWithArray:self.mutableObjectsArray];
    NSSet *filtered = [mutableObjectsSet cco_concurrentFilter:^(id object) {
        @synchronized (mutableObjectsSet) { [mutableObjectsSet removeAllObjects]; }
        return YES;
    }];
    STAssertEquals(filtered.count, kMutableCollectionCount, @"Failed to perform set filter concurrent with mutation");
}

- (void)testOrderedSetMapConcurrentWithMutation {
    NSMutableOrderedSet *mutableObjectsOrderedSet = [NSMutableOrderedSet orderedSetWithArray:self.mutableObjectsArray];
    NSOrderedSet *mapped = [mutableObjectsOrderedSet cco_concurrentMap:^(id object) {
        @synchronized (mutableObjectsOrderedSet) { [mutableObjectsOrderedSet removeAllObjects]; }
        return object;
    }];
    STAssertEquals(mapped.count, kMutableCollectionCount, @"Failed to perform set map concurrent with mutation");
}

- (void)testOrderedSetFilterConcurrentWithMutation {
    NSMutableOrderedSet *mutableObjectsOrderedSet = [NSMutableOrderedSet orderedSetWithArray:self.mutableObjectsArray];
    NSOrderedSet *filtered = [mutableObjectsOrderedSet cco_concurrentFilter:^(id object) {
        @synchronized (mutableObjectsOrderedSet) { [mutableObjectsOrderedSet removeAllObjects]; }
        return YES;
    }];
    STAssertEquals(filtered.count, kMutableCollectionCount, @"Failed to perform set filter concurrent with mutation");
}

@end
