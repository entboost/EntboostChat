//
//  ChangePasswordViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/11/14.
//  Copyright © 2015年 EB. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "ButtonKit.h"
#import "BlockUtility.h"
#import "ENTBoost+Utility.h"
#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "FVCustomAlertView.h"

@interface ChangePasswordViewController () <UITextFieldDelegate>

@property(nonatomic, strong) IBOutlet UITextField* oldPasswordTextField;    //旧密码输入框
@property(nonatomic, strong) IBOutlet UITextField* passwordTextField;       //新密码输入框
@property(nonatomic, strong) IBOutlet UITextField* confirmPasswordTextField;//新密码确认输入框

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)]; //导航栏左边按钮1
    self.navigationItem.rightBarButtonItem = [ButtonKit saveBarButtonItemWithTarget:self action:@selector(saveConfig:)]; //导航栏右边保存按钮1
    
    //设置编辑框事件代理
    self.oldPasswordTextField.delegate      = self;
    self.passwordTextField.delegate         = self;
    self.confirmPasswordTextField.delegate  = self;
    
    //设置边框
    EBCHAT_UI_SET_DEFAULT_BORDER(self.oldPasswordTextField);
    EBCHAT_UI_SET_DEFAULT_BORDER(self.passwordTextField);
    EBCHAT_UI_SET_DEFAULT_BORDER(self.confirmPasswordTextField);
    
    //设置缩进
    self.oldPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.oldPasswordTextField.leftView = [[UIView alloc] initWithFrame:(CGRect){0,0,8,1}];
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.leftView = [[UIView alloc] initWithFrame:(CGRect){0,0,8,1}];
    self.confirmPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.confirmPasswordTextField.leftView = [[UIView alloc] initWithFrame:(CGRect){0,0,8,1}];
    
    //设置输入框焦点
    [self.oldPasswordTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

//返回上一级
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//点击界面背景事件
- (IBAction)backgroundTap:(id)sender
{
    //隐藏键盘
    [self.oldPasswordTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
}

//保存
- (IBAction)saveConfig:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"输入错误" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alertView.tag = 101;
    
    //检查输入的旧密码
    NSString* oldPassword = self.oldPasswordTextField.text;
    if (!oldPassword.length) {
        [alertView setMessage:@"请旧密码"];
        [alertView show];
        [self.oldPasswordTextField becomeFirstResponder];
        return;
    }
    
    //检查输入的新密码
    NSString* password = self.passwordTextField.text;
    if (!password.length) {
        [alertView setMessage:@"请新密码"];
        [alertView show];
        [self.passwordTextField becomeFirstResponder];
        return;
    }
    
    //检查新旧密码合法性
    if ([oldPassword isEqualToString:password]) {
        [alertView setMessage:@"新旧密码不允许相同"];
        [alertView show];
        return;
    }
    
    //检查确认密码
    NSString* confirmPassword = self.confirmPasswordTextField.text;
    if (confirmPassword.length==0 || ![password isEqualToString:confirmPassword]) {
        [alertView setMessage:@"两次输入密码不相同"];
        [alertView show];
        [self.confirmPasswordTextField becomeFirstResponder];
        return;
    }
    
    ShowAlertView(); //显示进度提示框
    __weak typeof(self) safeSelf = self;
    [[ENTBoostKit sharedToolKit] changePassword:password oldPassword:oldPassword onCompletion:^{
        typeof(self) strongSelf = safeSelf;
        [BlockUtility performBlockInMainQueue:^{
            CloseAlertView();
            [strongSelf performSelector:@selector(showSuccess) withObject:nil afterDelay:1.0]; //延迟显示成功提示框
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"changePassword error, code = %@, msg = %@", @(error.code), error.localizedDescription);
        [BlockUtility performBlockInMainQueue:^{
            CloseAlertView();
            if (error.code==EB_STATE_ACC_PWD_ERROR)
                alertView.title = @"旧密码错误，修改密码失败";
            else
                alertView.title = @"修改密码失败";
            
            [alertView show];
        }];
    }];
}

//显示成功提示
- (void)showSuccess
{
    ShowCommonAlertView(@"修改密码成功");
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInGlobalQueue:^{
        [NSThread sleepForTimeInterval:1.0];
        [BlockUtility performBlockInMainQueue:^{
            CloseAlertView();
            [safeSelf.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==self.oldPasswordTextField) {
        [self.oldPasswordTextField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    } else if (textField==self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
        [self.confirmPasswordTextField becomeFirstResponder];
    } else if (textField==self.confirmPasswordTextField) {
        [self.confirmPasswordTextField resignFirstResponder];
        //执行保存
        [self saveConfig:nil];
    }
    
    return YES;
}
@end
