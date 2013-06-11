//
//  NSOrderedSet+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-09.
//

#import "NSOrderedSet+ConcurrentCollectionOperations.h"
#import <libkern/OSAtomic.h>

@implementation NSOrderedSet (ConcurrentCollectionOperations)

- (NSOrderedSet *)cco_concurrentMap:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue map:mapBlock];
}

- (NSOrderedSet *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    NSOrderedSet *snapshot = [self copy];

    __unsafe_unretained id *objects = (__unsafe_unretained id *)calloc(snapshot.count, sizeof(id));
    [snapshot getObjects:objects range:NSMakeRange(0, snapshot.count)];

    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        objects[i] = (__bridge id)CFBridgingRetain(mapBlock(objects[i]));
    });

    NSOrderedSet *result = [NSOrderedSet orderedSetWithObjects:objects count:snapshot.count];

    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        CFBridgingRelease((__bridge CFTypeRef)objects[i]);
    });
    free(objects);

    return result;
}

- (NSOrderedSet *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue filter:predicateBlock];
}

- (NSOrderedSet *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    NSOrderedSet *snapshot = [self copy];

    __unsafe_unretained id *objects = (__unsafe_unretained id*)calloc(snapshot.count, sizeof(id));
    [snapshot getObjects:objects range:NSMakeRange(0, snapshot.count)];

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

    NSOrderedSet *result = [NSOrderedSet orderedSetWithObjects:objects count:nextFree];

    free(objects);

    return result;
}

@end
