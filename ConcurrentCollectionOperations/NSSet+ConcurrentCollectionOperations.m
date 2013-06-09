//
//  NSSet+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 David Lee. All rights reserved.
//

#import "NSSet+ConcurrentCollectionOperations.h"

@implementation NSSet (ConcurrentCollectionOperations)

- (instancetype)cco_concurrentMap:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue map:mapBlock];
}

- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    NSSet *snapshot = [self copy];

    void *pointers = calloc(snapshot.count, sizeof(id));
    CFSetGetValues((__bridge CFSetRef)snapshot, pointers);
    __unsafe_unretained id *objects = (__unsafe_unretained id *)pointers;
    __strong id *mapped = (__strong id*)pointers;

    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        mapped[i] = mapBlock(objects[i]);
    });

    NSSet *result = [NSSet setWithObjects:mapped count:snapshot.count];

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

    NSSet *snapshot = [self copy];

    void *pointers = calloc(snapshot.count, sizeof(id));
    CFSetGetValues((__bridge CFSetRef)snapshot, pointers);
    __unsafe_unretained id *filtered = (__unsafe_unretained id *)pointers;

    __block NSUInteger filteredCount = 0;
    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        if (predicateBlock(filtered[i])) {
            ++filteredCount;
        } else {
            filtered[i] = nil;
        }
    });

    NSMutableSet *temp = [NSMutableSet setWithCapacity:filteredCount];
    for (NSUInteger i = 0; i < snapshot.count; ++i) {
        if (filtered[i] != nil) {
            [temp addObject:filtered[i]];
        }
    }

    free(pointers);

    NSSet *result = [NSSet setWithSet:temp];
    return result;
}

@end
