//
//  NSManagedObject+tools.h
//  ENTBoostLib
//
//  Created by zhong zf on 14/11/12.
//  Copyright (c) 2014年 entboost. All rights reserved.
//

typedef void(^ListResult)(NSArray* result, NSError *error);
typedef void(^ObjectResult)(id result, NSError *error);
typedef id(^AsyncProcess)(NSManagedObjectContext *ctx, NSString *className);

#import <CoreData/CoreData.h>
#import "EBDao.h"


@interface NSManagedObject (tools)

/**保存变更(同步阻塞模式)
 * @param ctx 上下文，如果使用主线程context，可传入nil
 * @return 错误信息实例
 */
+ (NSError*)saveContext:(NSManagedObjectContext*)ctx;

/**保存变更(异步非阻塞模式)
 * @param ctx 上下文，如果使用主线程context，可传入nil
 * @param completionBlock 结束后回调
 */
+ (void)asyncSaveContext:(NSManagedObjectContext *)ctx onCompletion:(void(^)(NSError* error))completionBlock;

/**插入新记录
 * @param ctx 上下文，如果使用主线程context，可传入nil
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block
 */
+ (void)create:(NSManagedObjectContext*)ctx atomicityBlock:(void(^)(id object))atomicityBlock;

/**查询(同步阻塞模式)
 * @param ctx 上下文，如果使用主线程context，可传入nil
 * @param predicate 查询条件谓词
 * @param orderby 排序
 * @param offset 偏移量
 * @param limit 查询结果记录数最大限制
 * @param 查询结果集
 */
+ (NSArray*)filter:(NSManagedObjectContext*)ctx predicate:(NSPredicate *)predicate orderby:(NSArray *)orders offset:(NSUInteger)offset limit:(NSUInteger)limit;

/**查询(同步阻塞模式)，可指定抓取字段
 * @param ctx 上下文，如果使用主线程context，可传入nil
 * @param predicate 查询条件谓词
 * @param orderby 排序
 * @param offset 偏移量
 * @param limit 查询结果记录数最大限制
 * @param propertyNamesToFetch 指定结果集抓取字段
 * @param includesSubentities 是否抓取关联对象(非基础类型对象)
 * @param includesPropertyValues 是否抓取属性值(只抓取ObjectID)
 * @param resultType 结果集类型
 * @param 查询结果集
 */
+ (NSArray*)filter:(NSManagedObjectContext*)ctx predicate:(NSPredicate *)predicate orderby:(NSArray *)orders offset:(NSUInteger)offset limit:(NSUInteger)limit propertyNamesToFetch:(NSArray*)propertyNamesToFetch includesSubentities:(BOOL)includesSubentities includesPropertyValues:(BOOL)includesPropertyValues resultType:(NSFetchRequestResultType)resultType;

/**查询(异步非阻塞模式)
* @param handleCtx 执行回调的上下文，如果使用主线程context，可传入nil
* @param predicate 查询条件谓词
* @param orderby 排序
* @param offset 偏移量
* @param limit 查询结果记录数最大限制
* @param handler 结果回调
 */
+ (void)filter:(NSManagedObjectContext*)handleCtx predicate:(NSPredicate *)predicate orderby:(NSArray *)orders offset:(NSUInteger)offset limit:(NSUInteger)limit on:(ListResult)handler;

/**group by 聚合函数查询(同步阻塞模式)
 * @param ctx 上下文，如果使用主线程context，可传入nil
 * @param groupbyNames group by字段
 * @param functionName 聚合函数名
 * @param funArguments 聚合函数参数列表
 * @param funResultType 聚合函数运算后数据类型
 * @param onlyFetchFunResult 是否只抓取有聚合函数运算的结果字段
 * @param predicate 查询条件谓词
 * @param orders 排序字段，nil等于忽略
 * @param offset 偏移量，通常用于分页
 * @param limit 返回结果集最大记录数，通常表示每页大小
 * @param 查询结果集
 */
+ (NSArray*)functionGroupby:(NSManagedObjectContext*)ctx groupbyNames:(NSArray*)groupbyNames functionName:(NSString*)functionName funArguments:(NSArray*)funArguments funResultType:(NSAttributeType)funResultType onlyFetchFunResult:(BOOL)onlyFetchFunResult predicate:(NSPredicate*)predicate orderby:(NSArray*)orders offset:(int)offset limit:(int)limit;

/**获取一个记录(同步阻塞模式)
 * @param ctx 上下文，如果使用主线程context，可传入nil
 * @param predicate 查询条件谓词
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 * @return 查询结果，单个对象
 */
+ (id)one:(NSManagedObjectContext*)ctx predicate:(NSPredicate*)predicate createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**获取一个记录(异步非阻塞模式)
 * @param handleCtx 执行回调的上下文，如果使用主线程context，可传入nil
 * @param predicate 查询条件谓词
 * @param handler 结果集回调
 * @param handler 结果回调
 */
+ (void)one:(NSManagedObjectContext*)handleCtx predicate:(NSPredicate*)predicate on:(ObjectResult)handler;

/**获取记录数量(同步阻塞模式)
 * @param ctx 上下文，如果使用主线程context，可传入nil
 * @param predicate 查询条件谓词
 * @return 记录数量
 */
+ (NSUInteger)count:(NSManagedObjectContext *)ctx predicate:(NSPredicate*)predicate;

/**删除一个记录(同步阻塞模式)
 * @param object 待删除的对象
 * @param ctx 上下文，如果使用主线程context，可传入nil
 */
+ (void)delObject:(id)object context:(NSManagedObjectContext *)ctx;

/**复杂操作(异步非阻塞模式)
 * @param processBlock 待执行的查询任务回调
 * @param resultBlock 结果回调
 * @param handleCtx 执行回调的上下文，如果使用主线程context，可传入nil
 */
+ (void)async:(AsyncProcess)processBlock result:(ListResult)resultBlock handleCtx:(NSManagedObjectContext*)handleCtx;

@end
