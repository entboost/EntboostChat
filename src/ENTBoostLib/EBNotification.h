//
//  EBNotification.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/2/3.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBNotification;
@interface EBNotification : NSObject

@property (nonatomic) uint64_t notiId; //通知流水号
@property (nonatomic, strong) NSString * talkId; //聊天编号
@property (nonatomic) BOOL isReaded; //已读状态
@property (nonatomic) uint64_t value; //通知内容
@property (nonatomic) uint64_t value1;//通知内容(备用)
@property (nonatomic, strong) NSString * content; //通知内容
@property (nonatomic, strong) NSString * content1; //通知内容(备用)
@property (nonatomic, strong) NSDate * updatedTime; //更新时间

///初始化方法
- (id)initWithTBNotificationInfo:(TBNotification*)tbNotification;

///使用本实例字段值填充到一个TBMemberInfo实例字段值
- (void)parseToTBNotification:(TBNotification*)tbNotification;

@end
