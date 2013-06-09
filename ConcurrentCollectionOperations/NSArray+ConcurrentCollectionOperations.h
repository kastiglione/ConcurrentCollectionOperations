//
//  NSArray+ConcurrentCollectionOperations.h
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 David Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockTypedefs.h"

@interface NSArray (ConcurrentCollectionOperations)

- (NSArray *)cco_concurrentMap:(CCOMapBlock)mapBlock;
- (NSArray *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock;

- (NSArray *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock;
- (NSArray *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock;

@end
