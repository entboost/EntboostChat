//
//  TextInputViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/7/18.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonTextInputViewController : UIViewController

@property(nonatomic, weak) id delegate; //代理
@property(nonatomic, strong) NSString* navigationTitle; //导航栏标题
@property(nonatomic, strong) NSString* defaultText; //默认文本内容

@property(nonatomic) CGFloat textInputViewHeight; //输入框高度
@property(nonatomic) UIKeyboardType keyboardType; //键盘类型
@property(nonatomic) UIReturnKeyType returnKeyType; //返回键的类型

@property(nonatomic) NSInteger customTag1;  //自定义标记1
@property(nonatomic) NSInteger customTag2; //自定义标记2

@end


@protocol CommonTextInputViewControllerDelgate <NSObject>

@optional
/*!文本输入完毕后点击保存事件
 @param commonTextInputViewController
 @param text 输入的文本内容
 */
- (void)commonTextInputViewController:(CommonTextInputViewController*)commonTextInputViewController wantToSaveInputText:(NSString*)text;

@end