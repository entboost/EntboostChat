//
//  RegistUserViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/8/28.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "RegistUserViewController.h"
#import "ButtonKit.h"
#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "BlockUtility.h"
#import "ENTBoost+Utility.h"
#import "FVCustomAlertView.h"

@interface RegistUserViewController() <UITextFieldDelegate>

@property(nonatomic, strong) IBOutlet UILabel       *ebTermsLabel;  //条款控件
@property(nonatomic, strong) IBOutlet UITextField   *accountField;  //账号输入控件
@property(nonatomic, strong) IBOutlet UITextField   *userNameField; //用户名称
@property(nonatomic, strong) IBOutlet UITextField   *passwordField; //密码输入控件
@property(nonatomic, strong) IBOutlet UITextField   *confirmPasswordField;  //确认密码输入控件
@property(nonatomic, strong) IBOutlet UITextField   *companyField;  //公司名称输入控件

@property(nonatomic, strong) IBOutlet UIButton      *registBtn;     //注册按钮

@end

@implementation RegistUserViewController


- (void)viewDidLoad
{
    self.title = @"注册新用户";
    
    //导航栏左边按钮1
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    
    //设置协议文档标题样式(加下划线)
    NSMutableAttributedString* content = [[NSMutableAttributedString alloc] initWithAttributedString:self.ebTermsLabel.attributedText];
    NSRange contentRange = {0,[content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:contentRange];
    self.ebTermsLabel.attributedText = content;
    
//    //设置注册按钮圆角边框
//    EBCHAT_UI_SET_CORNER_BUTTON_2(self.registBtn);
    
    //设置编辑框事件代理
    self.accountField.delegate          = self;
    self.userNameField.delegate         = self;
    self.passwordField.delegate         = self;
    self.confirmPasswordField.delegate  = self;
    self.companyField.delegate          = self;
    
    //设置边框
    EBCHAT_UI_SET_DEFAULT_BORDER(self.accountField);
    EBCHAT_UI_SET_DEFAULT_BORDER(self.userNameField);
    EBCHAT_UI_SET_DEFAULT_BORDER(self.passwordField);
    EBCHAT_UI_SET_DEFAULT_BORDER(self.confirmPasswordField);
    EBCHAT_UI_SET_DEFAULT_BORDER(self.companyField);
    
    //设置缩进
    CGFloat indent = 8.0;
    self.accountField.leftViewMode = UITextFieldViewModeAlways;
    self.accountField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, indent, 1)];
    self.userNameField.leftViewMode = UITextFieldViewModeAlways;
    self.userNameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, indent, 1)];
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, indent, 1)];
    self.confirmPasswordField.leftViewMode = UITextFieldViewModeAlways;
    self.confirmPasswordField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, indent, 1)];
    self.companyField.leftViewMode = UITextFieldViewModeAlways;
    self.companyField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, indent, 1)];
    
    //设置输入框为焦点
    [self.accountField becomeFirstResponder];
}

//返回上一级
- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//点击界面背景事件
- (IBAction)backgroundTap:(id)sender
{
    //隐藏键盘
    [self.accountField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.confirmPasswordField resignFirstResponder];
    [self.companyField resignFirstResponder];
}

//点击注册按钮
- (IBAction)registUser:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"输入错误" message:nil delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:nil, nil];
    alertView.tag = 101;
    
    //检查输入账号
    NSString* account = self.accountField.text;
    if (!account || [account stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
        [alertView setMessage:@"请输入账号"];
        [alertView show];
        [self.accountField becomeFirstResponder];
        return;
    }
//    if (![account validatedEmail] && ![account validatedCellPhone]) {
//        [alertView setMessage:@"账号必须是邮箱或手机号码"];
//        [alertView show];
//        [self.accountField becomeFirstResponder];
//        return;
//    }
    
    //检查用户名称
    NSString* userName = self.userNameField.text;
    if (!userName || [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
        [alertView setMessage:@"请输入用户名称"];
        [alertView show];
        [self.userNameField becomeFirstResponder];
        return;
    }
    
    //检查输入密码
    NSString* password = self.passwordField.text;
    if (!password || password.length==0) {
        [alertView setMessage:@"请输入密码"];
        [alertView show];
        [self.passwordField becomeFirstResponder];
        return;
    }
    
    //检查确认密码
    NSString* confirmPassword = self.confirmPasswordField.text;
    if (!confirmPassword || confirmPassword.length==0 || ![password isEqualToString:confirmPassword]) {
        [alertView setMessage:@"两次输入密码不相同"];
        [alertView show];
        return;
    }
    
    //公司名称
    NSString* companyName = self.companyField.text ;
    if (companyName)
        companyName = [companyName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (companyName.length==0)
        companyName = nil;
    
    //显示加载等待界面
    ShowAlertView();
    
    //执行注册
    [[ENTBoostKit sharedToolKit] registUserWithAccount:account userName:userName gender:EB_GENDER_UNKNOWN birthday:nil address:nil entName:companyName isNoNeedRegEmail:YES pwd:password onCompletion:^(uint64_t uid) {
        [BlockUtility performBlockInMainQueue:^{
            CloseAlertView();
            UIAlertView* alertView1 = [[UIAlertView alloc] initWithTitle:@"注册新用户成功" message:nil delegate:self cancelButtonTitle:@"继续注册下一个" otherButtonTitles:@"返回登录界面", nil];
            alertView1.tag = 102;
            [alertView1 show];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"注册新用户失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
        __weak typeof(self) safeSelf = self;
        [BlockUtility performBlockInMainQueue:^{
            CloseAlertView();
            NSString* message;
            if (error.code == EB_STATE_NOT_AUTH_ERROR) {
                if ([ENTBoostKit sharedToolKit].isLicenseUser) {
                    message = @"没有权限";
                } else {
                    message = @"注册新用户失败，服务器授权限制";
                }
            } else if (error.code == EB_STATE_ENTERPRISE_ALREADY_EXIST) {
                message = @"公司名称已存在";
                [safeSelf.companyField becomeFirstResponder];
            } else if (error.code == EB_STATE_ACCOUNT_ALREADY_EXIST) {
                message = @"账号已存在";
                [safeSelf.accountField becomeFirstResponder];
            } else if (error.code == EB_STATE_TIMEOUT_ERROR)
                message = @"操作超时";
            else if (error.code == EB_STATE_DISABLE_REGISTER_USER)
                message = @"注册普通用户失败，未开放普通用户注册功能";
            else if (error.code == EB_STATE_DISABLE_REGISTER_ENT)
                message = @"注册企业用户失败，未开放企业用户注册功能";
            else
                message = [NSString stringWithFormat:@"错误代码%@", @(error.code)];
            
            [alertView setMessage:[NSString stringWithFormat:@"注册新用户失败，%@", message]];
            [alertView show];
        }];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==102) {
        if (buttonIndex==0) {
            self.accountField.text = nil;
            self.passwordField.text = nil;
            self.confirmPasswordField.text = nil;
            self.companyField.text = nil;
        } else {
            [self goBack];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==self.accountField) {
        [self.accountField resignFirstResponder];
        [self.userNameField becomeFirstResponder];
    } else if (textField==self.userNameField) {
        [self.userNameField resignFirstResponder];
        [self.passwordField becomeFirstResponder];
    } else if (textField==self.passwordField) {
        [self.passwordField resignFirstResponder];
        [self.confirmPasswordField becomeFirstResponder];
    } else if (textField==self.confirmPasswordField) {
        [self.confirmPasswordField resignFirstResponder];
        [self.companyField becomeFirstResponder];
    } else if (textField==self.companyField) {
        [self.companyField resignFirstResponder];
    }
    
    return YES;
}

@end
