//
//  NSSet+ConcurrentCollectionOperations.h
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 David Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockTypedefs.h"

@interface NSSet (ConcurrentCollectionOperations)

- (NSSet *)cco_concurrentMap:(CCOMapBlock)mapBlock;
- (NSSet *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock;

- (NSSet *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock;
- (NSSet *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock;

@end
