//
//  PublicUI.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/23.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "PublicUI.h"
#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "PopupMenu.h"
#import "ENTBoost+Utility.h"
#import "SearchPersonController.h"

@interface PublicUI ()
{
    PopupMenu* _navigationPopupMenu;     //导航栏下拉菜单实例
    NSMutableArray* _navigationMenuItems;//导航栏下拉菜单的子菜单项
    
    PopupMenu* _chatPopupMenu;  //聊天会话界面弹出菜单实例
//    NSMutableArray* _chatMenuItems;//聊天会话界面弹出菜单的子菜单项
}
@end

@implementation PublicUI

+ (PublicUI*)sharedInstance
{
    static PublicUI* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[PublicUI alloc] init];
    });
    return instance;
}

- (UINavigationController*)navigationControllerWithRootViewController:(UIViewController*)rootViewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [self configureNavigationController:navigationController];
//    //设置导航栏颜色
//    if (IOS7)
//        navigationController.navigationBar.barTintColor = NAVIGATION_BAR_TINT_COLOR;
//    else
//        navigationController.navigationBar.tintColor = NAVIGATION_BAR_TINT_COLOR;
//    
//    //    [navigationController.navigationBar setBarStyle:UIBarStyleDefault];
//    //半透明
//    navigationController.navigationBar.translucent = NO;
//    
//    //设置标题字体及颜色
//    NSDictionary* titleTextAttrs = @{UITextAttributeTextColor:[UIColor whiteColor], UITextAttributeFont:[UIFont boldSystemFontOfSize:18.0]};
//    [navigationController.navigationBar setTitleTextAttributes:titleTextAttrs];
    
    return navigationController;
}

- (void)searchMenuInViewController:(UIViewController*)viewController
{
    SearchPersonController* spvc = [[UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_OTHER bundle:nil] instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_SEARCH_PERSON_CONTROLLER];
//    SearchPersonController* spvc = [[SearchPersonController alloc] init];
    
    [viewController.navigationController pushViewController:spvc animated:YES];
//    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:spvc];
//    
//    [self configureNavigationController:navigationController];
//    
//    [viewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)popupNavigationMenuInView:(UIView*)view
{
    if (!_navigationPopupMenu) {
        _navigationPopupMenu = [[PopupMenu alloc] init];
        //设置弹出菜单基本参数
        [_navigationPopupMenu setTitleFont:[UIFont systemFontOfSize:20.f]];
        [_navigationPopupMenu setBackgroundColor:EBCHAT_DEFAULT_COLOR];
        [_navigationPopupMenu setCornerRadius:2.f];
        [_navigationPopupMenu setHiddenSeparator:YES];
        
        //生成菜单项
        _navigationMenuItems = [[NSMutableArray alloc] init];
        PopupMenuItem* item1 = [PopupMenuItem menuItem:@"邀请好友" image:[UIImage imageNamed:@"navigation_add_contact-m"] target:self action:@selector(addContact) tag:201];
        item1.foreColor = [UIColor whiteColor];
        item1.alignment = NSTextAlignmentLeft;
        [_navigationMenuItems addObject:item1];
        
        PopupMenuItem* item2 = [PopupMenuItem menuItem:@"创建群组" image:[UIImage imageNamed:@"navigation_create_group-m"] target:self action:@selector(createPersonalGroup) tag:202];
        item2.foreColor = [UIColor whiteColor];
        item2.alignment = NSTextAlignmentLeft;
        [_navigationMenuItems addObject:item2];
        
        PopupMenuItem* item3 = [PopupMenuItem menuItem:@"浏览文件" image:[UIImage imageNamed:@"navigation_browse_folder-m"] target:self action:@selector(browseFolder) tag:203];
        item3.foreColor = [UIColor whiteColor];
        item3.alignment = NSTextAlignmentLeft;
        [_navigationMenuItems addObject:item3];
    }
    
    //显示弹出菜单
    CGRect fromRect = CGRectMake(view.bounds.size.width - 24 - 20, 0, 24, 0);
    [_navigationPopupMenu showMenuInView:view fromRect:fromRect menuItems:_navigationMenuItems arrowSize:10.f target:nil cancelAction:nil];
}

- (void)popupChatTapMenuInView:(UIView *)view fromRect:(CGRect)fromRect target:(id)target selectedAction:(SEL)selectedAction cancelAction:(SEL)cancelAction canPerformActions:(NSArray*)canPerformActions
{
//    if (!_chatPopupMenu) {
    _chatPopupMenu = [[PopupMenu alloc] init];
    //设置弹出菜单基本参数
    [_chatPopupMenu setTitleFont:[UIFont boldSystemFontOfSize:14.f]];
    [_chatPopupMenu setBackgroundColor:[UIColor blackColor]];
    [_chatPopupMenu setCornerRadius:2.f]; //设置圆角
    [_chatPopupMenu setHiddenSeparator:NO]; //显示分隔线
    [_chatPopupMenu setHorizontalRank:YES]; //子菜单项水平排列
//    }
    
    //生成菜单项
    NSMutableArray* chatMenuItems = [[NSMutableArray alloc] init];
    
    for (NSNumber* tagNum in canPerformActions) {
        NSInteger tag = [tagNum integerValue];
        NSString* itemName;
        
        switch (tag) {
            case PopupChatTapMenuItemTagCopy:
                itemName = @"复制";
                break;
            case PopupChatTapMenuItemTagDelete:
                itemName = @"删除";
                break;
            case PopupChatTapMenuItemTagResend:
                itemName = @"重发";
                break;
        }
        PopupMenuItem* item = [PopupMenuItem menuItem:itemName image:nil target:target action:selectedAction tag:tag];
        item.foreColor = [UIColor whiteColor];
        item.alignment = NSTextAlignmentLeft;
        [chatMenuItems addObject:item];
    }
    
    //显示弹出菜单
    [_chatPopupMenu showMenuInView:view fromRect:fromRect menuItems:chatMenuItems arrowSize:6.f target:target cancelAction:cancelAction];
}

//"邀请好友"菜单处理
- (void)addContact
{
    //发送显示“找群找人”应用的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_SHOW_APPLICATION object:self userInfo:@{@"subId":@([ENTBoostKit sharedToolKit].contactFinderSubId)}];
}

//"创建个人群组"菜单处理
- (void)createPersonalGroup
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"创建个人群组" message:@"请输入群组名称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"创建", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

//输入群组名称确认处理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //确定添加新群组
    if (buttonIndex==1) {
        UITextField* textField = [alertView textFieldAtIndex:0];
        NSString* groupName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (groupName.length>0) {
            //发送创建个人群组的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_CREATE_PERSONAL_GROUP object:self userInfo:@{@"groupName":groupName}];
        }
    }
}

//浏览文件目录
- (void)browseFolder
{
    //发送文件目录浏览的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_BROWSE_FOLDER object:self userInfo:nil];
}

//显示提示(选择)框
- (UIAlertView*)showAlertViewWithTag:(NSInteger)tag title:(NSString*)title message:(NSString*)message delegate:(id)delegate cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    alertView.tag = tag;
    [alertView show];
    
    return alertView;
}

- (void)configureNavigationController:(UINavigationController*)navigationController
{
    //解决导航栏覆盖内容的问题
    navigationController.navigationBar.translucent = NO;
    //设置背景色
    UIColor* navBarTintColor = EBCHAT_DEFAULT_COLOR; //#3ec6f8
    if ([navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)])
        navigationController.navigationBar.barTintColor = navBarTintColor;
    else
        navigationController.navigationBar.tintColor = navBarTintColor;
    //设置标题字体及颜色
    NSDictionary* titleTextAttrs = @{UITextAttributeTextColor:[UIColor whiteColor], UITextAttributeFont:[UIFont boldSystemFontOfSize:17.0]};
    [navigationController.navigationBar setTitleTextAttributes:titleTextAttrs];
//    //去除导航栏周边黑线
//    [navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    [navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];

}

@end
