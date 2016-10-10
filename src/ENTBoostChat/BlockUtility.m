//
//  BlockUtility.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-5.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "BlockUtility.h"

@implementation BlockUtility

+ (void)performBlockInMainQueue:(void(^)(void))block
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (void)syncPerformBlockInMainQueue:(void(^)(void))block
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

+ (void)performBlockInGlobalQueue:(void (^)(void))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

+ (void)performBlock:(void(^)(void))block queue:(dispatch_queue_t)queue specificKey:(void*)specificKey
{
    if (!queue)
        NSLog(@"performBlock queue is nil");
    
    if(dispatch_get_specific(specificKey))
        block();
    else
        dispatch_sync(queue, block);
}

@end
