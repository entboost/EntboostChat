//
//  Semaphore.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-6-16.
//
//

#import <Foundation/Foundation.h>

@interface SemaphoreWrap : NSObject

@property(strong, nonatomic) NSDate* usedTime;
@property(strong, nonatomic) dispatch_semaphore_t sem;

/** 初始化
 * @param sem 信号量
 */
- (id)initWithSemaphore:semaphore;

///用当前时间更新使用时间(usedTime)
- (void)updateUsedTime;

///使用dispath_release内部的semaphore
- (void)releaseSemaphore;

//dispatch_semaphore_sign发出信号
- (void)dispatchSemaphoreSign;

@end
