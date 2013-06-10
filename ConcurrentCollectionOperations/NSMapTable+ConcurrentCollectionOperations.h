//
//  NSMapTable+ConcurrentCollectionOperations.h
//  ConcurrentCollectionOperations
//
//  Created by Robert Widmann on 6/5/13.
//

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import "BlockTypedefs.h"

@interface NSMapTable (ConcurrentCollectionOperations)

/**
 * Returns an map table containing the results of calling the supplied block on
 * each value in the map table. The block calls are performed concurrently.
 *
 * The block calls are dispatched on the global concurrent dispatch queue with
 * default priority (`DISPATCH_QUEUE_PRIORITY_DEFAULT`).
 *
 * @see -cco_concurrentWithQueue:map:
 *
 * @param mapBlock Block that takes one object argument and another object.
 *
 * @result Map table containing the result of each block call.
 */
- (NSMapTable *)cco_concurrentMap:(CCOMapBlock)mapBlock;

/**
 * Returns an map table containing the results of calling the supplied block on
 * each value in the map table. The block calls are performed concurrently. The
 * block calls are dispatched on the supplied concurrent dispatch queue.
 *
 * @see -cco_concurrentMap:
 *
 * @param queue Concurrent dispatch queue for executing mapBlock.
 * @param mapBlock Block that takes one object argument and another object.
 *
 * @result Map table containing the result of each block call.
 */
- (NSMapTable *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock;

/**
 * Returns a subset of the map table, containing only the values for which the
 * predicate block returns true. The block calls are performed concurrently.
 *
 * The block calls are dispatched on the global concurrent dispatch queue with
 * default priority (`DISPATCH_QUEUE_PRIORITY_DEFAULT`).
 *
 * @see -cco_concurrentWithQueue:filter:
 *
 * @param predicateBlock Block that determines inclusion (YES) or exclusion (NO).
 *
 * @result Map table containing only the objects for which the predicate block returned true.
 */
- (NSMapTable *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock;

/**
 * Returns a subset of the map table, containing only the values for which the
 * predicate block returns true. The block calls are performed concurrently.
 * The block calls are dispatched on the supplied concurrent dispatch queue.
 *
 * @see -cco_concurrentFilter:
 *
 * @param queue Concurrent dispatch queue for executing predicateBlock.
 * @param predicateBlock Block that determines inclusion (YES) or exclusion (NO).
 *
 * @result Map table containing only the objects for which the predicate block returned true.
 */
- (NSMapTable *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock;

@end

#endif