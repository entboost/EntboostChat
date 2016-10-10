//
//  ContactInformationViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/22.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EBContactInfo;
@class EBContactGroup;

@interface ContactInformationViewController : UITableViewController

@property(weak, nonatomic) id delegate; //代理
@property(weak, nonatomic) id dataObject; //自定义数据对象

@property(strong, nonatomic) EBContactInfo* contactInfo; //联系人信息
@property(strong, nonatomic) EBContactGroup* contactGroup; //联系人分组

@end

@protocol ContactInformationViewControllerDelegate <NSObject>

@optional

///联系人资料变更事件
- (void)contactInformationViewController:(ContactInformationViewController*)viewController updateContactInfo:(EBContactInfo*)contactInfo dataObject:(id)dataObject;

///通知上层controller退出界面
- (void)contactInformationViewController:(ContactInformationViewController*)contactInformationViewController needExitParentController:(BOOL)needExit;

@end
