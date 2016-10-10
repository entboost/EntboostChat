//
//  ButtonKit.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/30.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ButtonKit : NSObject

/**生成自定义导航栏按钮
 * @param target 执行对象
 * @param action 执行动作句柄
 * @param imgaeName 图标引用名称
 * @param title 标题
 */
+ (UIBarButtonItem*)barButtonItemWithTarget:(id)target action:(SEL)action imageName:(NSString*)imageName title:(NSString*)title;

/**生成“返回”按钮(通常在导航栏-左边)
 * @param target 执行对象
 * @param action 执行动作句柄
 */
+ (UIBarButtonItem*)goBackBarButtonItemWithTarget:(id)target action:(SEL)action;

/**生成“保存”按钮(通常在导航栏-右边)
 * @param target 执行对象
 * @param action 执行动作句柄
 */
+ (UIBarButtonItem*)saveBarButtonItemWithTarget:(id)target action:(SEL)action;

/**生成“刷新”按钮(通常在导航栏-右边)
 * @param target 执行对象
 * @param action 执行动作句柄
 */
+ (UIBarButtonItem*)refreshBarButtonWithTarget:(id)target action:(SEL)action;

/**生成“搜索”按钮(通常在导航栏-右边)
 * @param target 执行对象
 * @param action 执行动作句柄
 */
+ (UIBarButtonItem*)searchBarButtonWithTarget:(id)target action:(SEL)action;

/**生成下拉菜单按钮(通常在导航栏-右边)
 * @param target 执行对象
 * @param action 执行动作句柄
 */
+ (UIBarButtonItem*)popMenuBarButtonWithTarget:(id)target action:(SEL)action;

@end
