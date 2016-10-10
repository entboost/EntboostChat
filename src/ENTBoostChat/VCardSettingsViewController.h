//
//  VCardSettingsViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/12/21.
//  Copyright © 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCardSettingsViewController : UITableViewController

@property(nonatomic, weak) id delegate; //回调代理

@end


@protocol VCardSettingsViewControllerDelegate <NSObject>

@optional

///当前用户默认电子名片变更事件
- (void)vCardSettingsViewController:(VCardSettingsViewController*)viewController updateDefaultEmp:(uint64_t)defaultEmp dataObject:(id)dataObject;

@end