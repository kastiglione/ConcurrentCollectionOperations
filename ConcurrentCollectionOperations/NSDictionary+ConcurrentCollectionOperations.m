//
//  NSDictionary+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
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

    free(mapped);
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

    __block volatile int32_t filteredCount = 0;
    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        if (predicateBlock(objects[i])) {
            OSAtomicIncrement32(&filteredCount);
        } else {
            objects[i] = nil;
        }
    });

    __unsafe_unretained id *filteredKeys = (__unsafe_unretained id *)calloc(filteredCount, sizeof(id));
    __unsafe_unretained id *filteredObjects = (__unsafe_unretained id *)calloc(filteredCount, sizeof(id));
    for (NSUInteger i = 0, j = 0; i < snapshot.count; ++i) {
        if (objects[i] != nil) {
            filteredKeys[j] = keys[i];
            filteredObjects[j] = objects[i];
            ++j;
        }
    }

    NSDictionary *result = [NSDictionary dictionaryWithObjects:filteredObjects forKeys:filteredKeys count:filteredCount];

    free(filteredKeys);
    free(filteredObjects);
    free(objects);
    free(keys);

    return result;
}

@end
