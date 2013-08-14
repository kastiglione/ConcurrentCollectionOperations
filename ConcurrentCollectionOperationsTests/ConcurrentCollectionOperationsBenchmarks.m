//
//  ConcurrentCollectionOperationsBenchmarks.m
//  ConcurrentCollectionOperations
//
//  Created by Josh Ballanco on 6/9/13.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ConcurrentCollectionOperations.h"
#import <objc/runtime.h>

@interface ConcurrentCollectionOperationsBenchmarks : SenTestCase
    @property(strong, nonatomic) NSArray *numbersArray;
    @property(strong, nonatomic) NSDictionary *numbersDictionary;
    @property(strong, nonatomic) NSSet *numbersSet;
    @property(strong, nonatomic) NSOrderedSet *numbersOrderedSet;
@end

@implementation ConcurrentCollectionOperationsBenchmarks

static NSTimeInterval totalRuntime = (NSTimeInterval)0;

- (void)setUp {
    NSUInteger const SIZE = 1000;

    __unsafe_unretained id *tmp = (__unsafe_unretained id *)calloc(SIZE, sizeof(id));
    for (NSUInteger i = 0; i < SIZE; i++) {
        tmp[i] = [NSNumber numberWithUnsignedInteger:i];
    }

    self.numbersArray = [NSArray arrayWithObjects:tmp count:SIZE];
    self.numbersDictionary = [NSDictionary dictionaryWithObjects:self.numbersArray
                                                         forKeys:self.numbersArray];
    self.numbersSet = [NSSet setWithArray:self.numbersArray];
    self.numbersOrderedSet = [NSOrderedSet orderedSetWithArray:self.numbersArray];

    free(tmp);
}

- (void)runBenchmark:(NSString *)name withBlock:(void (^)(void))block {
    NSUInteger const LOOP_COUNT = 20000;
    NSDate *start = [NSDate date];
    NSTimeInterval runtime;

    for (uint64_t i = 0; i < LOOP_COUNT; i++) {
        block();
    }

    totalRuntime += runtime = -[start timeIntervalSinceNow];
    NSLog(@"%@ benchmark: %.3fs", name, runtime);
}

+ (NSArray *)testInvocations {
    unsigned int methodCount;
    Method *methods = class_copyMethodList(self, &methodCount);
    assert(methodCount);

    Method method;
    SEL methodName;
    NSMethodSignature *methodSig;

    NSMutableArray *invocations = [[NSMutableArray alloc] init];
    NSInvocation *invocation;

    do {
        method = methods[--methodCount];
        methodName = method_getName(method);
        if (!strncmp("benchmark", sel_getName(methodName), 9)) {
            methodSig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
            invocation = [NSInvocation invocationWithMethodSignature:methodSig];
            [invocation setSelector:methodName];
            [invocations addObject:invocation];
        }
    } while (methodCount);

    return invocations;
}

+ (void)tearDown {
    NSLog(@"\n*****\nTotal Benchmark Runtime: %.3fs\n*****", totalRuntime);
}

#pragma mark - NSArray

- (void)benchmarkArrayMap {
    [self runBenchmark:@"Array Map" withBlock:^{
        [self.numbersArray cco_concurrentMap:^(NSNumber *number) {
            return @(2 * number.unsignedIntegerValue);
        }];
    }];
}

- (void)benchmarkArrayFilter {
    [self runBenchmark:@"Array Filter" withBlock:^{
        [self.numbersArray cco_concurrentFilter:^BOOL (NSNumber *number) {
            return number.unsignedIntegerValue % 2 == 1;
        }];
    }];
}

#pragma mark - NSDictionary

- (void)benchmarkDictionaryMap {
    [self runBenchmark:@"Dictionary Map" withBlock:^{
        [self.numbersDictionary cco_concurrentMap:^(NSNumber *number) {
            return @(2 * number.unsignedIntegerValue);
        }];
    }];
}

- (void)benchmarkDictionaryFilter {
    [self runBenchmark:@"Dictionary Filter" withBlock:^{
        [self.numbersDictionary cco_concurrentFilter:^BOOL (NSNumber *number) {
            return number.unsignedIntegerValue % 2 == 1;
        }];
    }];
}

#pragma mark - NSSet

- (void)benchmarkSetMap {
    [self runBenchmark:@"Set Map" withBlock:^{
        [self.numbersSet cco_concurrentMap:^(NSNumber *number) {
            return @(2 * number.unsignedIntegerValue);
        }];
    }];
}

- (void)benchmarkSetFilter {
    [self runBenchmark:@"Set Filter" withBlock:^{
        [self.numbersSet cco_concurrentFilter:^BOOL (NSNumber *number) {
            return number.unsignedIntegerValue % 2 == 1;
        }];
    }];
}

#pragma mark - NSOrderedSet

- (void)benchmarkOrderedSetMap {
    [self runBenchmark:@"Ordered Set Map" withBlock:^{
        [self.numbersOrderedSet cco_concurrentMap:^(NSNumber *number) {
            return @(2 * number.unsignedIntegerValue);
        }];
    }];
}

- (void)benchmarkOrderedSetFilter {
    [self runBenchmark:@"Ordered Set Filter" withBlock:^{
        [self.numbersOrderedSet cco_concurrentFilter:^BOOL (NSNumber *number) {
            return number.unsignedIntegerValue % 2 == 1;
        }];
    }];
}

@end
