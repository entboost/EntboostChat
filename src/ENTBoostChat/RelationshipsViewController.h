//
//  RelationshipsViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-2.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENTBoost.h"
#import "TableTree.h"

@class MainViewController;
@class EBMemberInfo;
@class EBGroupInfo;
@class EBVCard;

@interface RelationshipsViewController : UIViewController<TableTreeDelegate>

@property(weak, nonatomic) MainViewController* tabBarController; //tabBar控制器

//@property(nonatomic, strong) NSMutableArray* relationshipArray; //通讯簿顶层

//设置导航栏
- (void)configureNavigationBar:(UINavigationItem*)navigationItem;

/**处理登录完成的事件
 * @param accountInfo 当前登录用户的信息
 */
- (void)handleLogonCompletion:(EBAccountInfo *)accountInfo;

/**处理新成员加入到部门或群组的通知事件
 * @param memberInfo 成员信息
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)handleAddMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**处理成员退出(主动或被动)部门或群组的通知事件
 * @param memberInfo 成员信息
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 * @param passive 是否被动
 * @param targetIsMe 被操作的对象是否当前用户
 */
- (void)handleExitMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount passive:(BOOL)passive targetIsMe:(BOOL)targetIsMe;

/**处理成员资料变更的通知事件
 * @param memberInfo 成员信息
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)handleUpdateMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**处理新增或修改部门或群组资料的通知事件
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)handleUpdateGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**处理删除部门或群组的通知事件
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)handleDeleteGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**处理新增讨论组的通知事件
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)handleAddTempGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**处理好友邀请被接受的通知事件
 * @param contactInfo 联系人信息
 * @param fromUid 对方的用户编号
 * @param fromAccount 对方的用户账号
 * @param vCard 对方的电子名片
 */
- (void)handleAddContactAccept:(EBContactInfo *)conactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard;

/**处理删除好友的通知事件
 * @param contactInfo 联系人信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的用户账号
 * @param isBothDeleted 双方删除
 */
- (void)handleDeleteContact:(EBContactInfo *)contactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount isBothDeleted:(BOOL)isBothDeleted;

/**处理被对方删除好友的通知事件
 * @param contactInfo 联系人信息
 * @param fromUid 对方的用户编号
 * @param fromAccount 对方的用户账号
 * @param vCard 对方的电子名片
 * @param isBothDeleted 是否双方删除
 */
- (void)handleBeDeletedContact:(EBContactInfo *)contactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard isBothDeleted:(BOOL)isBothDeleted;

/**处理用户在线状态通知事件
 * @param userLineState 在线状态
 * @param fromUid 状态变更的用户编号
 * @param fromAccount 状态变更的用户账号
 * @param entGroupIds 该用户所属的部门列表(depCode列表)
 * @param personalGroupIds 该用户所属的个人群组列表(depCode列表)
 */
- (void)handleUserChangeLineState:(EB_USER_LINE_STATE)userLineState fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount inEntGroups:(NSArray *)entGroupIds inPersonalGroups:(NSArray *)personalGroupIds;

@end
