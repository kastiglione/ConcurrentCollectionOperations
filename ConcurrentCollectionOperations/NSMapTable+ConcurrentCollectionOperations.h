//
//  NSMapTable+ConcurrentCollectionOperations.h
//  ConcurrentCollectionOperations
//
//  Created by Robert Widmann on 6/5/13.
//  Copyright (c) 2013 Internet. All rights reserved.
//

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import "BlockTypedefs.h"

@interface NSMapTable (ConcurrentCollectionOperations)

- (NSMapTable *)cco_concurrentMap:(CCOMapBlock)mapBlock;
- (NSMapTable *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock;

- (NSMapTable *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock;
- (NSMapTable *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock;

@end

#endif