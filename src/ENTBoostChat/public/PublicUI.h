//
//  PublicUI.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/23.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

//聊天会话界面弹出菜单子菜单执行命令
typedef enum {
    PopupChatTapMenuItemTagCopy = 201,  //复制
    PopupChatTapMenuItemTagDelete,      //删除
    PopupChatTapMenuItemTagResend       //重发消息
} PopupChatTapMenuItemTag;


@interface PublicUI : NSObject

///获取全局单例
+ (PublicUI*)sharedInstance;

///使用默认条件创建一个导航栏Controller
- (UINavigationController*)navigationControllerWithRootViewController:(UIViewController*)rootViewController;

///切换至搜索聊天目标界面
- (void)searchMenuInViewController:(UIViewController*)viewController;

/**导航栏弹出菜单
 * @param view 视图容器
 */
- (void)popupNavigationMenuInView:(UIView*)view;

/*点击聊天记录弹出菜单
 * @param view 视图容器
 * @param fromRect 菜单位置与大小
 * @param target 回调对象
 * @param selectedAction 选中子菜单时执行的方法
 * @param cancelAction 关闭菜单时执行的方法
 * @param canPerformActions 判断显示哪些菜单项，value= @(PopupChatTapMenuItemTag)
 */
- (void)popupChatTapMenuInView:(UIView *)view fromRect:(CGRect)fromRect target:(id)target selectedAction:(SEL)selectedAction cancelAction:(SEL)cancelAction canPerformActions:(NSArray*)canPerformActions;

///显示提示(选择)框
- (UIAlertView*)showAlertViewWithTag:(NSInteger)tag title:(NSString*)title message:(NSString*)message delegate:(id)delegate cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles;

///执行默认配置导航栏
- (void)configureNavigationController:(UINavigationController*)navigationController;

@end
