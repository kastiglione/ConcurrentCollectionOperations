//
//  NSMapTable+ConcurrentCollectionOperations.h
//  ConcurrentCollectionOperations
//
//  Created by Robert Widmann on 6/5/13.
//  Copyright (c) 2013 Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockTypedefs.h"

@interface NSMapTable (ConcurrentCollectionOperations)

- (instancetype)cco_concurrentMap:(CCOMapBlock)mapBlock;
- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock;

- (instancetype)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock;
- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock;

@end
