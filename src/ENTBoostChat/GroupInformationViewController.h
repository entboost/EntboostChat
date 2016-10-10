//
//  GroupInformationViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/10.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENTBoost.h"

@class EBMemberInfo;

@interface GroupInformationViewController : UITableViewController

@property(weak, nonatomic) id delegate; //代理
@property(weak, nonatomic) id dataObject; //自定义数据对象

@property(strong, nonatomic) EBGroupInfo* groupInfo; //群组(部门)信息
@property(strong, nonatomic) EBEnterpriseInfo* enterpriseInfo; //所属公司

@property(strong, nonatomic) EBMemberInfo* myMemberInfo; //当前用户在该群组里的成员信息

//获取群组类型对应的名称
+ (NSString*)nameWithGroupType:(EB_GROUP_TYPE)groupType;

@end


@protocol GroupInformationViewControllerDelegate <NSObject>

@optional

///部门或群组资料变更事件
- (void)groupInformationViewController:(GroupInformationViewController*)viewController updateGroup:(EBGroupInfo*)groupInfo dataObject:(id)dataObject;

///通知上层controller退出界面
- (void)groupInformationViewController:(GroupInformationViewController*)groupInformationViewController needExitParentController:(BOOL)needExit;

@end