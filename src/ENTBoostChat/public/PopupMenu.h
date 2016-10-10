//
//  PopupMenu.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//
//  弹出菜单


#import <Foundation/Foundation.h>

@interface PopupMenuItem : NSObject

@property (readwrite, nonatomic, strong) UIImage *image;
@property (readwrite, nonatomic, strong) NSString *title;
@property (readwrite, nonatomic, weak) id target;
@property (readwrite, nonatomic) SEL action; //选中子菜单时调用的函数
@property (readwrite, nonatomic) uint64_t tag;
@property (readwrite, nonatomic, strong) UIColor *foreColor;
@property (readwrite, nonatomic) NSTextAlignment alignment;

+ (instancetype)menuItem:(NSString *) title image:(UIImage *) image target:(id)target action:(SEL) action tag:(uint64_t)tag;

@end

@interface PopupMenu : NSObject

//背景颜色
@property(nonatomic, strong) UIColor *backgroundColor;
//标题字体
@property(nonatomic, strong) UIFont *titleFont;
//圆角弧度
@property(nonatomic) CGFloat cornerRadius;
//是否隐藏分隔线
@property(nonatomic) BOOL hiddenSeparator;
//子菜单项是否水平排列
@property(nonatomic) BOOL horizontalRank;

/**显示弹出菜单
 * @param view 父视图，菜单的显示容器
 * @param rect 菜单位置与大小
 * @param menuItem 菜单项
 * @param arrowSize 小三角大小
 * @param target 回调目标对象
 * @param cancelAction 菜单关闭时调用的方法
 */
- (void)showMenuInView:(UIView *)view fromRect:(CGRect)rect menuItems:(NSArray *)menuItems arrowSize:(CGFloat)arrowSize target:(id)target cancelAction:(SEL)cancelAction;

///关闭菜单
- (void)dismissMenu;

@end
