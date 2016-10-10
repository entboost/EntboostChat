//
//  MemberSeletedViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/20.
//  Copyright (c) 2015年 EB. All rights reserved.
//

// 选择成员界面Controller

#import <UIKit/UIKit.h>
#import "TableTree.h"

@class EBGroupInfo;
@class MemberSeletedViewController;

@protocol MemberSeletedViewControllerDelegate <NSObject>

@optional
//保存邀请部门或群组成员回调事件
- (void)memberSeletedViewController:(MemberSeletedViewController*)viewController saveInvitedMember:(EBMemberInfo*)memberInfo;

@end

@interface MemberSeletedViewController : UIViewController<TableTreeDelegate>

@property(nonatomic, weak) id <MemberSeletedViewControllerDelegate> delegate; //回调代理
@property(nonatomic) EBGroupInfo* targetGroupInfo; //目标群组

@end
