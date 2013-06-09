//
//  NSDictionary+ConcurrentCollectionOperations.h
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 David Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockTypedefs.h"

@interface NSDictionary (ConcurrentCollectionOperations)

- (NSDictionary *)cco_concurrentMap:(CCOMapBlock)mapBlock;
- (NSDictionary *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock;

- (NSDictionary *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock;
- (NSDictionary *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock;

@end
