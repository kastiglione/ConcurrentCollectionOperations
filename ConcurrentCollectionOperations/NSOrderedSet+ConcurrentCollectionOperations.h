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

- (NSOrderedSet *)cco_concurrentMap:(CCOMapBlock)mapBlock;
- (NSOrderedSet *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock;

- (NSOrderedSet *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock;
- (NSOrderedSet *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock;

@end
