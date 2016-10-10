//
//  SOTPCache.h
//  SOTP
//
//  Created by zhong zf on 13-7-26.
//  Copyright (c) 2013年 zhong zf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SOTPData;
@class SemaphoreWrap;

@interface SOTPCache : NSObject

////获取全局单实例
//+ (id)sharedInstance;

/*! 初始化方法
 @param label 标签
 @return
 */
- (id)initWithLabel:(NSString*)label;

////启动过期任务清理定时器
//- (void)startClearCallTimeOverTask;
//
////关闭过期任务清理定时器
//- (void)stopClearCallTimeOverTask;

///----------保存异步调用信号量的缓存
/** 保存信号量
 * @param semaphore
 * @param cid
 */
- (void)setSemaphore:(SemaphoreWrap*)semaphore withCid:(uint32_t) cid;

/** 取出信号量
 * @param cid
 */
- (SemaphoreWrap*)semaphoreWithCid:(uint32_t)cid;

/**发出信号
 * @param cid
 */
- (void)dispatchSemaphoreSignWithCid:(uint32_t)cid;

///更新信号量中的使用时间为当期时间
//- (void)updateSemaphoreUsedTimeWithCid:(uint32_t)cid;

/** 删除信号量
 * @param cid
 */
- (void)removeSemaphoreWithCid:(uint32_t)cid;

/// 删除所有信号量
- (void)removeAllSemaphore;


//---------保存/cid关联数据sotp data
/**保存sotp数据
 * @param data sotp数据
 * @param cid 
 */
- (void)setData:(SOTPData*)data WithCid:(uint32_t)cid;

///**发送次数加一
// * @param cid
// */
//- (void)increaseSentTimesInDataWithCid:(uint32_t)cid;

///**更新数据调用时间为当期时间
// * @param cid
// */
//- (void)updateCallTimeInDataWithCid:(uint32_t)cid;

/**读取sotp数据
 * @param cid
 * @return sotp数据
 */
- (SOTPData*)dataWithCid:(uint32_t)cid;

/////清理和回调过期的数据
//- (void)clearAndCallbackTimeoverData;

///**删除一条sotp数据
// * @param cid
// */
//- (void)removeDataWithCid:(uint32_t)cid;

/////删除map中所有数据
//- (void)removeAllCidDatas;

@end
