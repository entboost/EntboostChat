//
//  LogonViewController.h
//  EntBoostChat
//
//  Created by zhong zf on 14-8-2.
//  Copyright (c) 2014年 entboost. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class DropDownList;

@interface LogonViewController : UIViewController

@property(nonatomic, strong) IBOutlet UIImageView   *logoImageView; //LOGO视图
@property(nonatomic, strong) IBOutlet UIButton      *loginButton; //登录按钮

@property(nonatomic, strong) IBOutlet UIButton      *visitorButton; //游客登录按钮
@property(nonatomic, strong) IBOutlet UIButton      *registerButton; //用户注册按钮
@property(nonatomic, strong) IBOutlet UIButton      *resetPasswordButton; //忘记密码按钮
@property(nonatomic, strong) IBOutlet UIButton      *serverConfigButton; //服务器配置按钮

@property(nonatomic, strong) IBOutlet UILabel       *versionLabel; //版本显示框

@property(nonatomic, strong) IBOutlet UITextField   *accountTextField; //账号输入框
//@property(nonatomic, strong) IBOutlet DropDownList  *accountField; //输入账号框
@property(nonatomic, strong) IBOutlet UITextField   *passwordTextField; //密码输入框

/////点击登录按钮事件
//- (IBAction)loginButtonPressed:(id)sender;
//
/////点击背景事件处理
//- (IBAction)backgroundTap:(id)sender;
//
/////输入完账号并按return按钮事件处理
//- (IBAction)accountDidEndOnExit:(id)sender;

//点击修改服务器配置按钮事件
- (IBAction)serverConfigButtonTap:(id)sender;

/*! 异步加载和显示Logo
 @param urlString 企业Logo链接
 */
- (void)asyncLoadAndShowLogo:(NSString*)urlString;

///更新产品显示信息
- (void)updateProductInformation;

@end
