//
//  NSDictionary+ConcurrentCollectionOperations.h
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
//

#import <Foundation/Foundation.h>
#import "BlockTypedefs.h"

@interface NSDictionary (ConcurrentCollectionOperations)

/**
 * Returns a dictionary containing the results of calling the supplied block on
 * each object in the dictionary. The block calls are performed concurrently.
 *
 * The block calls are dispatched on the global concurrent dispatch queue with
 * default priority (`DISPATCH_QUEUE_PRIORITY_DEFAULT`).
 *
 * @see -cco_concurrentWithQueue:map:
 *
 * @param mapBlock Block that takes one object argument and another object.
 *
 * @result Dictionary containing the result of each block call.
 */
- (NSDictionary *)cco_concurrentMap:(CCOMapBlock)mapBlock;

/**
 * Returns a dictionary containing the results of calling the supplied block on
 * each object in the dictionary. The block calls are performed concurrently.
 * The block calls are dispatched on the supplied concurrent dispatch queue.
 *
 * @see -cco_concurrentMap:
 *
 * @param queue Concurrent dispatch queue for executing mapBlock.
 * @param mapBlock Block that takes one object argument and another object.
 *
 * @result Dictionary containing the result of each block call.
 */
- (NSDictionary *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock;

/**
 * Returns a subset of the dictionary, containing only the objects for which the
 * predicate block returns true. The block calls are performed concurrently.
 *
 * The block calls are dispatched on the global concurrent dispatch queue with
 * default priority (`DISPATCH_QUEUE_PRIORITY_DEFAULT`).
 *
 * @see -cco_concurrentWithQueue:filter:
 *
 * @param predicateBlock Block that determines inclusion (YES) or exclusion (NO).
 *
 * @result Dictionary containing only the objects for which the predicate block returned true.
 */
- (NSDictionary *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock;

/**
 * Returns a subset of the dictionary, containing only the objects for which the
 * predicate block returns true. The block calls are performed concurrently. The
 * block calls are dispatched on the supplied concurrent dispatch queue.
 *
 * @see -cco_concurrentFilter:
 *
 * @param queue Concurrent dispatch queue for executing predicateBlock.
 * @param predicateBlock Block that determines inclusion (YES) or exclusion (NO).
 *
 * @result Dictionary containing only the objects for which the predicate block returned true.
 */
- (NSDictionary *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock;

@end
