//
//  ServerConfigViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 14/10/31.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "ENTBoostChat.h"
#import "ServerConfigViewController.h"
#import "ENTBoostKit.h"
#import "AppDelegate.h"
#import "ENTBoost+Utility.h"
#import "FileUtility.h"
#import "ButtonKit.h"
#import "DropDownList.h"

@interface ServerConfigViewController () <DropDownListDelegate, UITextFieldDelegate>

@property(nonatomic, strong) DropDownList* serverDDList;
@property(nonatomic, strong) NSMutableArray* serverList;

@end

@implementation ServerConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* serverAddress = [ENTBoostKit serverAddress];
    if (serverAddress.length>0)
        self.serverAddressTextField.text = serverAddress;
    
    EBCHAT_UI_SET_DEFAULT_BORDER(self.serverAddressTextField); //设置边框
    self.serverAddressTextField.delegate = self;
    self.serverAddressTextField.leftViewMode = UITextFieldViewModeAlways;
    self.serverAddressTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 1)];
    
    self.title = @"配置服务端地址";
    
    //导航栏左边按钮1
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    //右边按钮1
    self.navigationItem.rightBarButtonItem = [ButtonKit saveBarButtonItemWithTarget:self action:@selector(saveConfig:)];
    
//    //设置返回按钮圆角边框
//    EBCHAT_UI_SET_CORNER_BUTTON_2(self.saveBtn);
    
    //读取服务器地址历史列表
    NSArray* arry = [self readServerList];
    self.serverList = arry?[arry mutableCopy]:[[NSMutableArray alloc] init];
    
//    //设置输入框为焦点
//    [self.serverAddressTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    _accountList = [[CHKeychain userNamePasswords] mutableCopy];
    if (!self.serverDDList) {
        self.serverDDList = [[DropDownList alloc] initWithInputView:self.serverAddressTextField rootView:self.view delegate:self];
    }
    self.serverDDList.data = [self.serverList mutableCopy];
    [self.serverDDList refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)clearInputField:(id)sender
//{
//    self.serverAddressTextField.text = nil;
//}

//返回上一级
- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveConfig:(id)sender
{
    NSString* serverAddress = self.serverAddressTextField.text;
    serverAddress = [serverAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去两边空格
    if (serverAddress.length == 0)
        serverAddress = @"entboost.entboost.com:18012";
    
    NSError* error;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"^([^:])+:(\\d){1,5}$" options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger count = [reg numberOfMatchesInString:serverAddress options:NSMatchingReportCompletion range:NSMakeRange(0, serverAddress.length)];
    
    if (error || count != 1) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"内容不符合规则" delegate:nil cancelButtonTitle:@"确  认" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    //保存服务器地址历史列表
    for (NSUInteger i =0; i<self.serverList.count; i++) {
        NSString* tmpAddress = self.serverList[i];
        if ([tmpAddress isEqualToString:serverAddress]) {
            [self.serverList removeObjectAtIndex:i];
            break;
        }
    }
    [self.serverList insertObject:serverAddress atIndex:0];
    [self saveServerList];
    
    [((AppDelegate*)[UIApplication sharedApplication].delegate) resetApplicationWithServerAddress:serverAddress];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)serverListFilePath
{
    return [NSString stringWithFormat:@"%@/serverlist", [FileUtility ebChatDocumentDirectory]];
}

//读取服务器地址历史列表
- (NSArray*)readServerList
{
    NSString* filePath = [self serverListFilePath];
//    if (![FileUtility fileExistAtPath:filePath]) {
//        NSLog(@"文件不存在:%@", filePath);
//        return nil;
//    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

//保存服务器地址历史列表
- (BOOL)saveServerList
{
//    NSError *error = nil;
    NSString* filePath = [self serverListFilePath];
//    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error]) {
//        NSLog(@"创建文件失败:%@", filePath);
//        return NO;
//    }
    return [NSKeyedArchiver archiveRootObject:self.serverList toFile:filePath];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//点击界面背景事件
- (IBAction)backgroundTap:(id)sender
{
    [self.serverAddressTextField resignFirstResponder]; //隐藏键盘
    [self.serverDDList show:YES]; //隐藏历史下拉列表
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.serverAddressTextField resignFirstResponder];
    [self saveConfig:nil];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField==self.serverAddressTextField)
        [self.serverDDList show:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField==self.serverAddressTextField)
        [self.serverDDList show:YES];
}

#pragma mark - DropDrownListDelegate

- (void)dropDownList:(DropDownList *)dropDownList atRow:(NSUInteger)row supplyCell:(UITableViewCell *)cell data:(id)data
{
    NSString* name = data;
    cell.textLabel.text = name;
    cell.textLabel.textColor = self.serverAddressTextField.textColor;
}

- (void)dropDownList:(DropDownList *)dropDownList atRow:(NSUInteger)row didSelectedWithData:(id)data
{
    self.serverAddressTextField.text = data;
    [self.serverAddressTextField resignFirstResponder];
}

- (void)dropDownList:(DropDownList *)dropDownList atRow:(NSUInteger)row deleteWithData:(id)data
{
    [self.serverList removeObjectAtIndex:row]; //从缓存里删除
    [self saveServerList]; //从持久化保存里删除
}

@end
