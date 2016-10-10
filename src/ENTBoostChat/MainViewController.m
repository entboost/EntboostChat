//
//  MainViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-7.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "ENTBoost+Utility.h"
#import "MainViewController.h"
#import "TalksTableViewController.h"
#import "RelationshipsViewController.h"
#import "ApplicationsViewController.h"
#import "SettingsViewController.h"
#import "BlockUtility.h"
#import "AppDelegate.h"

@interface MainViewController () <UITabBarControllerDelegate>
{
    UIStoryboard*   _mainStoryboard;
    NSArray*        _tabBarItems;
}

@end

@implementation MainViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _mainStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_MAIN bundle:nil];
        self.delegate = self;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)abc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    //状态栏不透明
    self.navigationController.navigationBar.translucent = NO;
    
    //设置tabbar图标及标题
    _tabBarItems = @[@{@"title":@"聊天", @"image":@"tabbar_talks", @"selectedImage":@"tabbar_talks_selected"},
                     @{@"title":@"联系人", @"image":@"tabbar_relationships", @"selectedImage":@"tabbar_relationships_selected"},
                     @{@"title":@"应用", @"image":@"tabbar_applications", @"selectedImage":@"tabbar_applications_selected"},
                     @{@"title":@"设置", @"image":@"tabbar_other", @"selectedImage":@"tabbar_other_selected"}];
    
    //创建多个controller
    [self createViewControllers];
    //配置tabBar标签
    [self configureTabBar];
    //配置第一个Tab的导航栏和标题
    [self.talksController configureNavigationBar:self.navigationItem];
    self.navigationItem.title = (_tabBarItems[0])[@"title"];
    
}

//==========自定义了TabBarController 之后必须实现以下四个方法，否则容易出现动画报错日志
-(void)viewWillAppear:(BOOL)animated
{
//    [super viewWillAppear:animated];
    [self.selectedViewController beginAppearanceTransition:YES animated: animated];
}

-(void)viewDidAppear:(BOOL)animated
{
//    [super viewDidAppear:animated];
    [self.selectedViewController endAppearanceTransition];
}

-(void)viewWillDisappear:(BOOL)animated
{
//    [super viewWillDisappear:animated];
    [self.selectedViewController beginAppearanceTransition:NO animated: animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
//    [super viewDidDisappear:animated];
    [self.selectedViewController endAppearanceTransition];
}
//==========

- (void)createViewControllers
{
    self.talksController        = [_mainStoryboard instantiateViewControllerWithIdentifier:EBCHAT_MAIN_STORYBOARD_ID_TALKS_CONTROLLER];
    self.relationshipController = [_mainStoryboard instantiateViewControllerWithIdentifier:EBCHAT_MAIN_STORYBOARD_ID_RELATIONSHIP_CONTROLLER];
    self.applicationsController = [_mainStoryboard instantiateViewControllerWithIdentifier:EBCHAT_MAIN_STORYBOARD_ID_APPLICATIONS_CONTROLLER];
    self.settingsViewController = [_mainStoryboard instantiateViewControllerWithIdentifier:EBCHAT_MAIN_STORYBOARD_ID_SETTINGS_CONTROLLER];
    
    self.viewControllers = @[self.talksController, self.relationshipController, self.applicationsController, self.settingsViewController];
    
    //获取tarbar里各个控制器
    self.talksController.tabBarController           = self;
    self.relationshipController.tabBarController    = self;
    self.applicationsController.tabBarController    = self;
    self.settingsViewController.tabBarController    = self;
}

//设置导航栏属性
//- (void)initNavigationControllers
//{
//    NSArray* controllers = self.childViewControllers;
//    UINavigationController* navController0 = controllers[0];
//    UINavigationController* navController1 = controllers[1];
//    UINavigationController* navController2 = controllers[2];
//    UINavigationController* navController3 = controllers[3];
//    
//    //解决导航栏覆盖内容的问题
//    navController0.navigationBar.translucent = NO;
//    navController1.navigationBar.translucent = NO;
//    navController2.navigationBar.translucent = NO;
//    navController3.navigationBar.translucent = NO;
//    
//    //设置背景色
//    UIColor* navBarTintColor = NAVIGATION_BAR_TINT_COLOR;//[UIColor colorWithHexString:@"#3ec6f8"];
//    if ([navController0.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
//        navController0.navigationBar.barTintColor = navBarTintColor;
//        navController1.navigationBar.barTintColor = navBarTintColor;
//        navController2.navigationBar.barTintColor = navBarTintColor;
//        navController3.navigationBar.barTintColor = navBarTintColor;
//    } else {
//        navController0.navigationBar.tintColor = navBarTintColor;
//        navController1.navigationBar.tintColor = navBarTintColor;
//        navController2.navigationBar.tintColor = navBarTintColor;
//        navController3.navigationBar.tintColor = navBarTintColor;
//    }
//    
//    //设置标题字体及颜色
//    NSDictionary* titleTextAttrs = @{UITextAttributeTextColor:[UIColor whiteColor], UITextAttributeFont:[UIFont boldSystemFontOfSize:18.0]};
//    [navController0.navigationBar setTitleTextAttributes:titleTextAttrs];
//    [navController1.navigationBar setTitleTextAttributes:titleTextAttrs];
//    [navController2.navigationBar setTitleTextAttributes:titleTextAttrs];
//    [navController3.navigationBar setTitleTextAttributes:titleTextAttrs];
//    
////    //去除导航栏周边黑线
////    [navController0.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
////    [navController0.navigationBar setShadowImage:[[UIImage alloc] init]];
////    [navController1.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
////    [navController1.navigationBar setShadowImage:[[UIImage alloc] init]];
////    [navController2.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
////    [navController2.navigationBar setShadowImage:[[UIImage alloc] init]];
////    [navController3.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
////    [navController3.navigationBar setShadowImage:[[UIImage alloc] init]];
//    
//    //获取tarbar里各个控制器
//    self.talksController = navController0.viewControllers[0];
//    self.talksController.tabBarController = self;
//    
//    self.relationshipController = navController1.viewControllers[0];
//    self.relationshipController.tabBarController = self;
//    
//    self.applicationsController = navController2.viewControllers[0];
//    self.applicationsController.tabBarController = self;
//    
//    self.settingsViewController = navController3.viewControllers[0];
//    self.settingsViewController.tabBarController = self;
//}

//设置tabBar属性
- (void)configureTabBar
{
    UITabBar *tabBar = self.tabBar;
    
    //设置tabBar上边框颜色
    CGFloat borderHeight = 1.0;
    if (!IOS7)
        borderHeight = 0.4;
    
    //设置tabBar背景颜色
    if (IOS7) { //IOS7以上版本
        UIView *bgView = [[UIView alloc] initWithFrame:tabBar.bounds];
        bgView.backgroundColor = [UIColor whiteColor];
        [tabBar insertSubview:bgView atIndex:0];
        tabBar.opaque = YES;
    } else {
        [tabBar setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor] size:tabBar.bounds.size]];
//        [tabBar setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHexString:@"#e2f6fd"] size:tabBar.bounds.size]];
    }
    
//    [tabBar setShadowImage:[UIImage imageFromColor:EBCHAT_DEFAULT_BACKGROUND_COLOR/*[UIColor colorWithHexString:@"#83c5db"]*/ size:CGSizeMake(tabBar.bounds.size.width, borderHeight)]];
    
    for (int i=0; i<_tabBarItems.count; i++) {
        NSDictionary* data = _tabBarItems[i];
        UITabBarItem *tabBarItem  = [tabBar.items objectAtIndex:i];
        
        //设置文字内容
        [tabBarItem setTitle:data[@"title"]];
        //设置文字颜色
        [tabBarItem setTitleTextAttributes:@{UITextAttributeFont:[UIFont italicSystemFontOfSize:13.0], UITextAttributeTextColor:[UIColor lightGrayColor/*colorWithHexString:@"#7cafc1"*/]} forState:UIControlStateNormal];
        [tabBarItem setTitleTextAttributes:@{UITextAttributeTextColor:EBCHAT_TABBAR_SELECTED_FONT_COLOR} forState:UIControlStateSelected];
        //设置图标
        if (IOS7) {
            [tabBarItem setImage:[[UIImage imageNamed:data[@"image"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [tabBarItem setSelectedImage:[[UIImage imageNamed:data[@"selectedImage"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        } else {
            [tabBarItem setFinishedSelectedImage:[UIImage imageNamed:data[@"selectedImage"]] withFinishedUnselectedImage:[UIImage imageNamed:data[@"image"]]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateTabBarItemBadgeValue:(NSString*)badgeValue atIndex:(NSUInteger)index
{
    UITabBarItem *item = [self.tabBar.items objectAtIndex:index];
    if (item)
        item.badgeValue = badgeValue;
}

#pragma mark - UITabBarControllerDelegate

//实现协议方法，用于切换Tab时，更改页面的标题
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSInteger index = tabBarController.selectedIndex;
    //设置标题
    self.title = (_tabBarItems[index])[@"title"];
    //设置导航栏
    switch (index) {
        case 0:
        {
            [self.talksController configureNavigationBar:self.navigationItem];
        }
            break;
        case 1:
        {
            [self.relationshipController configureNavigationBar:self.navigationItem];
        }
            break;
        default:
        {
            self.navigationItem.rightBarButtonItems = @[];
        }
            break;
    }
}

@end
