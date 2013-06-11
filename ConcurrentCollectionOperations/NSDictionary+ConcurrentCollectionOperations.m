//
//  NSDictionary+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 David Lee, Joshua Ballanco. All rights reserved.
//

#import "NSDictionary+ConcurrentCollectionOperations.h"
#import <libkern/OSAtomic.h>

@implementation NSDictionary (ConcurrentCollectionOperations)

- (NSDictionary *)cco_concurrentMap:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue map:mapBlock];
}

- (NSDictionary *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock {
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

    free(pointers);
    free(keys);
    return result;
}

- (NSDictionary *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue filter:predicateBlock];
}

- (NSDictionary *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    NSDictionary *snapshot = [self copy];

    __unsafe_unretained id *keys = (__unsafe_unretained id *)calloc(snapshot.count, sizeof(id));
    __unsafe_unretained id *objects = (__unsafe_unretained id *)calloc(snapshot.count, sizeof(id));
    [snapshot getObjects:objects andKeys:keys];

    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        if (!predicateBlock(objects[i])) {
            objects[i] = nil;
        }
    });

    NSUInteger cursor = 0, nextFree = 0;
    while(cursor < snapshot.count) {
        if(objects[cursor]) {
            keys[nextFree] = keys[cursor];
            objects[nextFree++] = objects[cursor++];
        } else {
            cursor++;
        }
    }

    NSDictionary *result = [NSDictionary dictionaryWithObjects:objects forKeys:keys count:nextFree];

    free(objects);
    free(keys);

    return result;
}

@end
