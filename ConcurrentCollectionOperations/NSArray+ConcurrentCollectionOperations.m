//
//  NSArray+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
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

    id *objects = calloc(snapshot.count, sizeof(id));
    [snapshot getObjects:objects range:NSMakeRange(0, snapshot.count)];

    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        objects[i] = [mapBlock(objects[i]) retain];
    });

    NSArray *result = [NSArray arrayWithObjects:objects count:snapshot.count];

    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        [objects[i] release];
    });
    free(objects);
    [snapshot release];

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

    id *objects = calloc(snapshot.count, sizeof(id));
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

    NSArray *result = [NSArray arrayWithObjects:objects count:nextFree];

    free(objects);
    [snapshot release];

    return result;
}

@end
