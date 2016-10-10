//
//  MainViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-7.
//  Copyright (c) 2014年 EB. All rights reserved.
//
//  登录成功后的根控制器

#import <UIKit/UIKit.h>

@class TalksTableViewController;
@class RelationshipsViewController;
@class ApplicationsViewController;
@class SettingsViewController;

@interface MainViewController : UITabBarController

@property(strong, nonatomic) TalksTableViewController* talksController;
@property(strong, nonatomic) RelationshipsViewController* relationshipController;
@property(strong, nonatomic) ApplicationsViewController* applicationsController;
@property(strong, nonatomic) SettingsViewController* settingsViewController;

/**更新TabBar右上角数字提示
 * @param badgeValue 提示内容(通常是数字)；填nil将隐藏提示
 * @param index 第N个图标
 */
- (void)updateTabBarItemBadgeValue:(NSString*)badgeValue atIndex:(NSUInteger)index;

@end
