//
//  UserInformationViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/8.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EBVCard;
@class EBGroupInfo;
@class EBMemberInfo;

@interface UserInformationViewController : UITableViewController

@property(weak, nonatomic) id delegate; //回调代理
@property(weak, nonatomic) id dataObject; //自定义数据对象

@property(nonatomic) BOOL isReadonly; //是否只读

@property(nonatomic) uint64_t uid; //用户编号
@property(strong, nonatomic) NSString* account; //用户账号
@property(strong, nonatomic) EBVCard* vCard; //电子名片

//查看群组或部门成员使用属性
@property(nonatomic) EBMemberInfo* targetMemberInfo; //目标用户在所属群组或部门的成员信息实例
@property(nonatomic) EBGroupInfo* targetGroupInfo; //目标用户所属的群组或部门信息实例
@property(nonatomic) EBMemberInfo* myMemberInfo; //当前用户在所属群组的成员信息实例

@end


@protocol UserInformationViewControllerDelegate <NSObject>

@optional
///通知上层controller退出界面
- (void)userInformationViewController:(UserInformationViewController*)userInformationViewController needExitParentController:(BOOL)needExit;

///成员资料变更事件
- (void)userInformationViewController:(UserInformationViewController*)viewController updateMemberInfo:(EBMemberInfo*)memberInfo dataObject:(id)dataObject;

///通知上层controller更新界面
- (void)userInformationViewController:(UserInformationViewController *)userInformationViewController needUpdateParentController:(BOOL)needUpdate;

@end