//
//  NSArray+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 David Lee. All rights reserved.
//

#import "NSArray+ConcurrentCollectionOperations.h"
#import <libkern/OSAtomic.h>

@implementation NSArray (ConcurrentCollectionOperations)

- (NSArray *)cco_concurrentMap:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue map:mapBlock];
}

- (NSArray *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    NSArray *snapshot = [self copy];

    void *pointers = calloc(snapshot.count, sizeof(id));
    __unsafe_unretained id *objects = (__unsafe_unretained id *)pointers;
    [snapshot getObjects:objects range:NSMakeRange(0, snapshot.count)];
    __strong id *mapped = (__strong id*)pointers;

    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        mapped[i] = mapBlock(objects[i]);
    });

    NSArray *result = [NSArray arrayWithObjects:mapped count:snapshot.count];

    free(mapped);
    return result;
}

- (NSArray *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue filter:predicateBlock];
}

- (NSArray *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    NSArray *snapshot = [self copy];

    __unsafe_unretained id *objects = (__unsafe_unretained id*)calloc(snapshot.count, sizeof(id));
    [snapshot getObjects:objects range:NSMakeRange(0, snapshot.count)];

    __block volatile int32_t filteredCount = 0;
    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        if (predicateBlock(objects[i])) {
            OSAtomicIncrement32(&filteredCount);
        } else {
            objects[i] = nil;
        }
    });

    __unsafe_unretained id *filteredObjects = (__unsafe_unretained id *)calloc(filteredCount, sizeof(id));
    for (NSUInteger i = 0, j = 0; i < snapshot.count; ++i) {
        if (objects[i] != nil) {
            filteredObjects[j] = objects[i];
            ++j;
        }
    }

    NSArray *result = [NSArray arrayWithObjects:filteredObjects count:filteredCount];

    free(filteredObjects);
    free(objects);

    return result;
}

@end
