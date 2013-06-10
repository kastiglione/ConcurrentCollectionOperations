//
//  NSSet+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 David Lee, Joshua Ballanco. All rights reserved.
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

    free(pointers);
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


    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        if (!predicateBlock(objects[i])) {
            objects[i] = nil;
        }
    });

    NSUInteger cursor = 0, nextFree = 0;
    while(cursor < snapshot.count) {
        if(objects[cursor]) {
            objects[nextFree++] = objects[cursor++];
        } else {
            cursor++;
        }
    }

    NSSet *result = [NSSet setWithObjects:objects count:nextFree];

    free(pointers);
    return result;
}

@end
