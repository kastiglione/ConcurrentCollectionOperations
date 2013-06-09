//
//  NSArray+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 David Lee. All rights reserved.
//

#import "NSArray+ConcurrentCollectionOperations.h"

@implementation NSArray (ConcurrentCollectionOperations)

- (instancetype)cco_concurrentMap:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue map:mapBlock];
}

- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock {
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

- (instancetype)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue filter:predicateBlock];
}

- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    NSArray *snapshot = [self copy];

    __unsafe_unretained id *filtered = (__unsafe_unretained id*)calloc(snapshot.count, sizeof(id));
    [snapshot getObjects:filtered range:NSMakeRange(0, snapshot.count)];

    __block NSUInteger filteredCount = 0;
    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        if (predicateBlock(filtered[i])) {
            ++filteredCount;
        } else {
            filtered[i] = nil;
        }
    });

    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:filteredCount];
    for (NSUInteger i = 0; i < snapshot.count; ++i) {
        if (filtered[i] != nil) {
            [temp addObject:filtered[i]];
        }
    }

    free(filtered);

    NSArray *result = [NSArray arrayWithArray:temp];
    return result;
}

@end
