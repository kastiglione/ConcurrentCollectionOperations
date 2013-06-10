//
//  NSOrderedSet+ConcurrentCollectionOperations.h
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-09.
//
//

#import <Foundation/Foundation.h>
#import "BlockTypedefs.h"

@interface NSOrderedSet (ConcurrentCollectionOperations)

/**
 * Returns an ordered set containing the results of calling the supplied block
 * on each object in the ordered set. The block calls are performed
 * concurrently, but the order is preserved.
 *
 * The block calls are dispatched on the global concurrent dispatch queue with
 * default priority (`DISPATCH_QUEUE_PRIORITY_DEFAULT`).
 *
 * @see -cco_concurrentWithQueue:map:
 *
 * @param mapBlock Block that takes one object argument and another object.
 *
 * @result Ordered set containing the ordered result of each block call.
 */
- (NSOrderedSet *)cco_concurrentMap:(CCOMapBlock)mapBlock;

/**
 * Returns an ordered set containing the results of calling the supplied block
 * on each object in the ordered set. The block calls are performed
 * concurrently, but the order is preserved. The block calls are dispatched on
 * the supplied concurrent dispatch queue.
 *
 * @see -cco_concurrentMap:
 *
 * @param queue Concurrent dispatch queue for executing mapBlock.
 * @param mapBlock Block that takes one object argument and another object.
 *
 * @result Ordered set containing the ordered result of each block call.
 */
- (NSOrderedSet *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock;

/**
 * Returns a subsequence of the ordered set, containing only the objects for
 * which the predicate block returns true. The block calls are performed
 * concurrently, but the order is preserved.
 *
 * The block calls are dispatched on the global concurrent dispatch queue with
 * default priority (`DISPATCH_QUEUE_PRIORITY_DEFAULT`).
 *
 * @see -cco_concurrentWithQueue:filter:
 *
 * @param predicateBlock Block that determines inclusion (YES) or exclusion (NO).
 *
 * @result Ordered set containing only the objects for which the predicate block returned true.
 */
- (NSOrderedSet *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock;

/**
 * Returns a subsequence of the ordered set, containing only the objects for
 * which the predicate block returns true. The block calls are performed
 * concurrently, but the order is preserved. The block calls are dispatched on
 * the supplied concurrent dispatch queue.
 *
 * @see -cco_concurrentFilter:
 *
 * @param queue Concurrent dispatch queue for executing predicateBlock.
 * @param predicateBlock Block that determines inclusion (YES) or exclusion (NO).
 *
 * @result Ordered set containing only the objects for which the predicate block returned true.
 */
- (NSOrderedSet *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock;

@end
