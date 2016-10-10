//
//  MemberListViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 16/1/17.
//  Copyright © 2016年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EBGroupInfo;

@interface MemberListViewController : UITableViewController

@property(nonatomic, strong) EBGroupInfo* groupInfo; //部门或群组对象

@end
