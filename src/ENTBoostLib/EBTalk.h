//
//  EBTalk.h
//  ENTBoostLib
//
//  Created by zhong zf on 14-9-4.
//  Copyright (c) 2014年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOTP_defines.h"

@class TBTalk;
@class EBCallInfo;

@interface EBTalk : NSObject

@property (nonatomic, strong) NSString * talkId; //编号
@property (nonatomic, strong) NSString * talkName; //名称
@property (nonatomic) uint64_t currentCallId; //当前会话编号
@property (nonatomic) uint64_t depCode; //部门或群组编号
@property (nonatomic, strong) NSString * depName; //部门或群组名称
@property (nonatomic, strong) NSString * otherAccount; //对方用户账号(只用于一对一会话)
@property (nonatomic) uint64_t otherUid; //对方用户编号(只用于一对一会话)
@property (nonatomic, strong) NSString * otherUserName; //对方用户名(只用于一对一会话)
@property (nonatomic) uint64_t otherEmpCode; //对方成员编号(只用于一对一会话)
@property (nonatomic, strong) NSString * iconFile; //头像文件路径
@property (nonatomic, strong) NSDate * updatedTime; //更新时间

@property (nonatomic) EB_TALK_TYPE type; //类型
@property (nonatomic) BOOL invisible; //隐藏(不可见)
@property (nonatomic, strong) id customData; //自定义数据

- (id)initWithTBTalk:(TBTalk*)tbTalk;

/**可对话状态是否已就绪
 * @param pCallInfo 如果是ready状态，本参数将返回与本EBTalk所关联的EBCallInfo实例
 * @return 是否ready状态(会话已经准备好)
 */
- (BOOL)isReady:(EBCallInfo**)pCallInfo;

///是否群组对话
- (BOOL)isGroup;

@end
