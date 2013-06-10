//
//  NSSet+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
//

#import "NSSet+ConcurrentCollectionOperations.h"
#import <libkern/OSAtomic.h>

@implementation NSSet (ConcurrentCollectionOperations)

- (NSSet *)cco_concurrentMap:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue map:mapBlock];
}

- (NSSet *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock {
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

- (NSSet *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue filter:predicateBlock];
}

- (NSSet *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    NSSet *snapshot = [self copy];

    void *pointers = calloc(snapshot.count, sizeof(id));
    CFSetGetValues((__bridge CFSetRef)snapshot, pointers);
    __unsafe_unretained id *objects = (__unsafe_unretained id *)pointers;

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

    NSSet *result = [NSSet setWithObjects:filteredObjects count:filteredCount];

    free(filteredObjects);
    free(objects);

    return result;
}

@end
