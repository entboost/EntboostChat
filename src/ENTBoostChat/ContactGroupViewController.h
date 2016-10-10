//
//  ContactGroupViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/30.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EBContactInfo;
@class ContactInformationViewController;

@interface ContactGroupViewController : UITableViewController

@property(nonatomic) uint64_t selectedContactGroupId; //选中的分组编号
@property(nonatomic, strong) EBContactInfo* contactInfo; //关联的联系人实例

@property(nonatomic, weak) ContactInformationViewController* contactInformationViewController; //联系人信息的controller

@end
