//
//  NSMapTable+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Robert Widmann on 6/5/13.
//

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

#import "NSMapTable+ConcurrentCollectionOperations.h"
#import <libkern/OSAtomic.h>

@implementation NSMapTable (ConcurrentCollectionOperations)

- (NSMapTable *)cco_concurrentMap:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);
	
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue map:mapBlock];
}

- (NSMapTable *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);
	
    __block OSSpinLock spinlock = OS_SPINLOCK_INIT;

    NSMapTable *result = NSCopyMapTableWithZone(self, NULL);
    NSResetMapTable(result);
	
    NSArray *keys = NSAllMapTableKeys(self);
    NSArray *objects = NSAllMapTableValues(self);
	
    dispatch_apply(self.count, queue, ^(size_t i) {
        OSSpinLockLock(&spinlock);
        [result setObject:mapBlock(objects[i]) forKey:keys[i]];
        OSSpinLockUnlock(&spinlock);
    });
	
    return [result autorelease];
}

- (NSMapTable *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);
	
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue filter:predicateBlock];
}

- (NSMapTable *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);
	
    __block OSSpinLock spinlock = OS_SPINLOCK_INIT;

    NSMapTable *result = NSCopyMapTableWithZone(self, NULL);
    NSResetMapTable(result);

    NSArray *keys = NSAllMapTableKeys(self);
    NSMutableArray *objects = NSAllMapTableValues(self).mutableCopy;

    dispatch_apply(self.count, queue, ^(size_t i) {
        if (predicateBlock(objects[i])) {
            OSSpinLockLock(&spinlock);
            [result setObject:objects[i] forKey:keys[i]];
            OSSpinLockUnlock(&spinlock);
        }
    });

    return [result autorelease];
}

@end

#endif
