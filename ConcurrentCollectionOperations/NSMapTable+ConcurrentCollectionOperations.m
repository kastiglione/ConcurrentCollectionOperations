//
//  NSMapTable+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Robert Widmann on 6/5/13.
//  Copyright (c) 2013 Internet. All rights reserved.
//

#import "NSMapTable+ConcurrentCollectionOperations.h"
#import <libkern/OSAtomic.h>

@implementation NSMapTable (ConcurrentCollectionOperations)

- (instancetype)cco_concurrentMap:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);
	
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue map:mapBlock];
}

- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);
	
    NSMapTable *result = NSCopyMapTableWithZone(self, NULL);
    NSResetMapTable(result);
	
    NSArray *keys = NSAllMapTableKeys(self);
    NSArray *objects = NSAllMapTableValues(self);
	
    dispatch_apply(self.count, queue, ^(size_t i) {
		OSSpinLock spinlock = OS_SPINLOCK_INIT;
		OSSpinLockLock(&spinlock);
		[result setObject:mapBlock(objects[i]) forKey:keys[i]];
		OSSpinLockUnlock(&spinlock);
    });
	
    return result;
}

- (instancetype)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);
	
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue filter:predicateBlock];
}

- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);
	
    NSMapTable *result = NSCopyMapTableWithZone(self, NULL);
    NSResetMapTable(result);

    NSArray *keys = NSAllMapTableKeys(self);
    NSMutableArray *objects = NSAllMapTableValues(self).mutableCopy;

    dispatch_apply(self.count, queue, ^(size_t i) {
        if (predicateBlock(objects[i])) {
            OSSpinLock spinlock = OS_SPINLOCK_INIT;
            OSSpinLockLock(&spinlock);
            [result setObject:objects[i] forKey:keys[i]];
            OSSpinLockUnlock(&spinlock);
        }
    });

    return result;
}

@end
