//
//  RelationshipDeepInViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/25.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableTree.h"

@class EBMemberInfo;
@class EBGroupInfo;
@class EBVCard;

@interface RelationshipDeepInViewController : UIViewController<TableTreeDelegate>

@property(nonatomic, strong) EBGroupInfo* parentGroupInfo; //上层部门(群组)

/**处理登录完成的事件
 * @param accountInfo 当前登录用户的信息
 */
- (void)handleLogonCompletion:(EBAccountInfo *)accountInfo;

///响应成员增加事件
- (void)handleAddMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo onlineCountOfMembers:(NSInteger)onlineCountOfMembers fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

///响应成员退出事件
- (void)handleExitMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo  onlineCountOfMembers:(NSInteger)onlineCountOfMembers fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount passive:(BOOL)passive;

///响应新增或修改部门(群组)资料事件
- (void)handleUpdateGroup:(EBGroupInfo *)groupInfo onlineCountOfMembers:(NSInteger)onlineCountOfMembers fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

///响应删除部门(群组)事件
- (void)handleDeleteGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**处理用户在线状态通知事件
 * @param userLineState 在线状态
 * @param fromUid 状态变更的用户编号
 * @param fromAccount 状态变更的用户账号
 * @param entGroupIds 该用户所属的部门列表(depCode列表)
 */
- (void)handleUserChangeLineState:(EB_USER_LINE_STATE)userLineState fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount inEntGroups:(NSArray *)entGroupIds;

@end
