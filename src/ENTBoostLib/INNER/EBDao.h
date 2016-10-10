//
//  EBDao.h
//  ENTBoostLib
//
//  Created by zhong zf on 14/11/12.
//  Copyright (c) 2014年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBDao : NSObject
//@property (readonly, strong, nonatomic) NSOperationQueue *queue;
@property (readonly ,strong, nonatomic) NSManagedObjectContext *bgObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *manageObjectContext;

//数据库访问环境是否准备好
+ (BOOL)isReady;

///获取全局单例
+ (EBDao*)instance;

///设置参数
- (void)setupEnvModel:(NSString *)model DBFile:(NSString*)fileName;

///创建一个新的上下文
- (NSManagedObjectContext *)createPrivateObjectContext;

/**保存变化的数据(同步阻塞模式)
 * @return 错误信息对象
 */
- (NSError*)saveContext;

/**保存变化的数据(异步非阻塞模式)
 * @param completionBlock 完成后回调
 */
- (void)asyncSaveContext:(void(^)(NSError* error))completionBlock;

///复位实例状态
- (void)reset;

@end
