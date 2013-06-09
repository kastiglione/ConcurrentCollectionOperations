//
//  NSDictionary+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 David Lee. All rights reserved.
//

#import "NSDictionary+ConcurrentCollectionOperations.h"

@implementation NSDictionary (ConcurrentCollectionOperations)

- (instancetype)cco_concurrentMap:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue map:mapBlock];
}

- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    NSDictionary *snapshot = [self copy];

    void *pointers = calloc(snapshot.count, sizeof(id));
    __unsafe_unretained id *keys = (__unsafe_unretained id *)calloc(snapshot.count, sizeof(id));
    __unsafe_unretained id *objects = (__unsafe_unretained id *)pointers;
    [snapshot getObjects:objects andKeys:keys];

    __strong id *mapped = (__strong id *)pointers;
    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        mapped[i] = mapBlock(objects[i]);
    });

    NSDictionary *result = [NSDictionary dictionaryWithObjects:mapped forKeys:keys count:snapshot.count];

    free(mapped);
    free(keys);
    return result;
}

- (instancetype)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue filter:predicateBlock];
}

- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    NSDictionary *snapshot = [self copy];

    __unsafe_unretained id *keys = (__unsafe_unretained id *)calloc(snapshot.count, sizeof(id));
    __unsafe_unretained id *objects = (__unsafe_unretained id *)calloc(snapshot.count, sizeof(id));
    [snapshot getObjects:objects andKeys:keys];

    __block NSUInteger filteredCount = 0;
    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        if (predicateBlock(objects[i])) {
            ++filteredCount;
        } else {
            objects[i] = nil;
        }
    });

    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < snapshot.count; ++i) {
        if (objects[i] != nil) {
            temp[keys[i]] = objects[i];
        }
    }

    free(objects);
    free(keys);

    NSDictionary *result = [NSDictionary dictionaryWithDictionary:temp];
    return result;
}

@end
