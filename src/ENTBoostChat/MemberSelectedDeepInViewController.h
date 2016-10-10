//
//  MemberSelectedDeepInViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/20.
//  Copyright (c) 2015年 EB. All rights reserved.
//

// 选择成员深层界面Controller

#import <UIKit/UIKit.h>
#import "TableTree.h"

@class EBGroupInfo;

@interface MemberSelectedDeepInViewController : UIViewController<TableTreeDelegate>

@property(nonatomic, strong) EBGroupInfo* parentGroupInfo; //上层部门(群组)
@property(nonatomic) EBGroupInfo* targetGroupInfo; //目标群组

/**获取勾选中的节点
 * @return TableTreeNode列表
 */
- (NSArray*)tickCheckedNodes;

@end
