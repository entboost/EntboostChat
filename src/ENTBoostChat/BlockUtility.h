//
//  BlockUtility.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-5.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlockUtility : NSObject

///在主线程中异步执行block
+ (void)performBlockInMainQueue:(void(^)(void))block;

///在主线程中同步执行block
+ (void)syncPerformBlockInMainQueue:(void(^)(void))block;

///在并发线程中异步执行block
+ (void)performBlockInGlobalQueue:(void (^)(void))block;

/**避免串行队列产生死锁的情况下执行block任务
 * @param block 待执行任务
 * @param queue 串行队列
 * @param specificKey 串行队列特征值
 */
+ (void)performBlock:(void(^)(void))block queue:(dispatch_queue_t)queue specificKey:(void*)specificKey;

@end
