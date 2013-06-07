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

    void *values = calloc(self.count, sizeof(id));
    CFSetGetValues((__bridge CFSetRef)self, values);
    __unsafe_unretained id *objects = (__unsafe_unretained id *)values;
    __strong id *mapped = (__strong id*)values;

    dispatch_apply(self.count, queue, ^(size_t i) {
        mapped[i] = mapBlock(objects[i]);
    });

    NSSet *result = [NSSet setWithObjects:mapped count:self.count];

    free(values);
    return result;
}

- (instancetype)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue filter:predicateBlock];
}

- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    void *values = calloc(self.count, sizeof(id));
    CFSetGetValues((__bridge CFSetRef)self, values);
    __unsafe_unretained id *filtered = (__unsafe_unretained id *)values;

    __block NSUInteger filteredCount = 0;
    dispatch_apply(self.count, queue, ^(size_t i) {
        if (predicateBlock(filtered[i])) {
            ++filteredCount;
        } else {
            filtered[i] = nil;
        }
    });

    NSMutableSet *temp = [NSMutableSet setWithCapacity:filteredCount];
    for (NSUInteger i = 0; i < self.count; ++i) {
        if (filtered[i] != nil) {
            [temp addObject:filtered[i]];
        }
    }

    free(values);
    
    NSSet *result = [NSSet setWithSet:temp];
    return result;
}

@end
