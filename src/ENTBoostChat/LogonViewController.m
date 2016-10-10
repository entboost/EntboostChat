//
//  LogonViewController.m
//  EntBoostChat
//
//  Created by zhong zf on 14-8-2.
//  Copyright (c) 2014年 entboost. All rights reserved.
//

#import "LogonViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "BlockUtility.h"
#import "FileUtility.h"
#import "ENTBoost+Utility.h"
#import "CHKeychain.h"
#import "UserNamePassword.h"
#import "PublicUI.h"
#import "ServerConfigViewController.h"
#import "ResetPasswordViewController.h"
#import "RegistUserViewController.h"
#import "DropDownList.h"

@interface LogonViewController () <DropDownListDelegate, UITextFieldDelegate>
{
    UIStoryboard*   _logonStoryboard;
    NSMutableArray* _accountList;
    NSString*       _lastAccount;
}

@property(nonatomic, strong) DropDownList *accountDDList;  //历史账号列表
@property(nonatomic, strong) UIImageView* accountRightImageView; //账号输入框右侧图标视图

//最右边一个button与右边间隔约束
@property(nonatomic, strong) IBOutlet NSLayoutConstraint* rightButtonTraillingConstraint;
//两个button之间横向间隔约束
@property(nonatomic, strong) IBOutlet NSLayoutConstraint* buttonsSpaceConstraint1;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint* buttonsSpaceConstraint2;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint* buttonsSpaceConstraint3;
//button宽度约束
@property(nonatomic, strong) IBOutlet NSLayoutConstraint* buttonWidthConstraint1;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint* buttonWidthConstraint2;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint* buttonWidthConstraint3;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint* buttonWidthConstraint4;

@end

@implementation LogonViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.accountTextField];
}

- (NSString*)productInformation
{
    //显示程序版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"]; //app名称
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"]; //app版本
    NSString *buildNo = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).buildNo;
    
    NSString* serverName;
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    if (ebKit.isLicenseUser && ebKit.productName) {
        serverName = ebKit.productName;
    }
    
    NSRange range = [appVersion rangeOfString:@"D"];
    if (range.location!=NSNotFound) {
        appVersion = [NSString stringWithFormat:@"%@%@", [appVersion substringToIndex:range.location], [appVersion substringFromIndex:range.location+1]];
        if (buildNo)
            buildNo = [NSString stringWithFormat:@"%@D", buildNo];
    }
    
    NSMutableString* versionStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@-%@", serverName?serverName:appName, appVersion]];
    if (buildNo)
        [versionStr appendString:[NSString stringWithFormat:@".%@", buildNo]];
    
    return versionStr;
}

- (void)updateProductInformation
{
    self.versionLabel.text = [self productInformation];
}

//适应调整几个按钮宽度
- (void)adjustButtons
{
    const CGFloat MaxSpace = 180.0; //最大间隔
    const CGFloat rightSpace = 15.0; //距右侧宽度
    
    int validCount = 0; //显示的按钮数量
    CGFloat buttonWidth = 55.0; //每按钮宽度
    CGFloat totalWidth = self.view.width; //总宽度
    CGFloat expectTotalSpace = totalWidth - (2*rightSpace); //预期间隔之和
 
    //判断是否隐藏"修改密码"按钮
    if ([ENTBoostKit sharedToolKit].resetPasswordUrl==nil)
        self.resetPasswordButton.hidden = YES;
    
    //计算间隔值
    if (!self.visitorButton.hidden) {
        validCount++;
        expectTotalSpace = expectTotalSpace - buttonWidth; //self.visitorButton.width;
    } else {
        self.buttonWidthConstraint1.constant = 0.0;
    }
    
    if (!self.registerButton.hidden) {
        validCount++;
        expectTotalSpace = expectTotalSpace - buttonWidth; //self.registerButton.width;
    } else {
        self.buttonWidthConstraint2.constant = 0.0;
    }
    
    if (!self.resetPasswordButton.hidden) {
        validCount++;
        expectTotalSpace = expectTotalSpace - buttonWidth; //self.resetPasswordButton.width;
    } else {
        self.buttonWidthConstraint3.constant = 0.0;
    }
    
    if (!self.serverConfigButton.hidden) {
        validCount++;
        expectTotalSpace = expectTotalSpace - buttonWidth; //self.serverConfigButton.width;
    } else {
        self.buttonWidthConstraint4.constant = 0.0;
    }
    
    CGFloat validSpace = expectTotalSpace; //最终有效间隔值
    if (validCount > 1) {
        validSpace = expectTotalSpace/(validCount-1);
    }
    if (validSpace > MaxSpace)
        validSpace = MaxSpace;
    
    self.buttonsSpaceConstraint1.constant = validSpace;
    self.buttonsSpaceConstraint2.constant = validSpace;
    self.buttonsSpaceConstraint3.constant = validSpace;
    
    if (self.serverConfigButton.hidden)
        self.buttonsSpaceConstraint3.constant = 0.0;
    if (self.resetPasswordButton.hidden)
        self.buttonsSpaceConstraint2.constant = 0.0;
    if (self.registerButton.hidden)
        self.buttonsSpaceConstraint1.constant = 0.0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    //设置背景图片到底层
//    UIView* backgroundView = [self.view viewWithTag:101];
//    [self.view sendSubviewToBack:backgroundView];
    
//    //设置头像圆角边框
    UIImageView* headImageView = (UIImageView*)[self.view viewWithTag:102];
    headImageView.backgroundColor = [UIColor clearColor]; //背景色
//    EBCHAT_UI_SET_CORNER_VIEW_WHITE(headImageView);
    
//    //设置输入框背景圆角边框
//    UIView* inputBGiew = [self.view viewWithTag:103];
//    EBCHAT_UI_SET_CORNER_VIEW_WHITE(inputBGiew);
    
    //设置登录按钮圆角边框
    EBCHAT_UI_SET_CORNER_VIEW_CLEAR1(self.loginButton);
//    //设置游客登录按钮圆角边框
//    EBCHAT_UI_SET_CORNER_BUTTON_1(self.visitorButton);
    
    //==账号输入框样式==
    //边框颜色
    EBCHAT_UI_SET_DEFAULT_BORDER(self.accountTextField);
    //左缩进
    self.accountTextField.leftViewMode = UITextFieldViewModeAlways;
    self.accountTextField.leftView = [[UIView alloc] initWithFrame:(CGRect){0,0,8,1}];
    //右侧图标
    self.accountTextField.rightViewMode = UITextFieldViewModeAlways;
    self.accountRightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logon_triangle"]];
    self.accountRightImageView.frame = (CGRect){0,0,24,30};
    self.accountRightImageView.contentMode = UIViewContentModeCenter;
    self.accountRightImageView.userInteractionEnabled = YES;
    self.accountTextField.rightView = self.accountRightImageView;
    UITapGestureRecognizer* tapGestureReg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAccountList:)];
    [self.accountRightImageView addGestureRecognizer:tapGestureReg];
    
    //==密码输入框样式==
    //设置边框
    EBCHAT_UI_SET_DEFAULT_BORDER(self.passwordTextField);
    //左缩进
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.leftView = [[UIView alloc] initWithFrame:(CGRect){0,0,8,1}];
    
    //计算几个按钮间隔约束
    [self adjustButtons];
    
    
    //更新产品显示信息
    [self updateProductInformation];
    
    //初始化用户名和密码输入框
//    self.accountTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logon_account"]];
//    self.accountTextField.leftViewMode = UITextFieldViewModeAlways;
    _accountList = [[CHKeychain userNamePasswords] mutableCopy];
    UserNamePassword* unp = [CHKeychain lastUserNamePassword];
    self.accountTextField.text = unp.userName;
    _lastAccount = self.accountTextField.text;
    self.accountTextField.delegate = self;
//    [self.accountTextField setSpellCheckingType:];
//    self.accountField.textField.text = [CHKeychain userName];
    self.passwordTextField.text = unp.password;
    self.passwordTextField.delegate = self;
    
//    self.test = [[DropDownList alloc] initWithFrame:CGRectMake(10, 200, 140, 100)];
//    self.test.bounds = CGRectMake(0, 0, 140, 100);
//    self.test.tableArray = [[NSArray alloc]initWithObjects:@"电话",@"email",@"手机",@"aaa",@"bbb",@"ccc",nil];
//    [self.view addSubview:self.test];
//    [self.accountField.textField setFont:[self.accountField.textField.font fontWithSize:13.0]];
//    [self.accountField.textField setPlaceholder:@"请输入账号"];
//    self.accountField.tableArray = @[@"电话",@"email",@"手机",@"aaa",@"bbb",@"ccc"];
    
    _logonStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_LOGON bundle:nil];
    
    //监控用户账号输入值变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:self.accountTextField];
}

- (void)asyncLoadAndShowLogo:(NSString*)urlString
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    NSString* cacheImageFilePath = [NSString stringWithFormat:@"%@/logo/cache_logo.img", [FileUtility ebChatDocumentDirectory]]; //缓存logo图片路径
    NSString* prefix = [NSString stringWithFormat:@"%@/logo/%llu", [FileUtility ebChatDocumentDirectory], ebKit.serverDeployId];
    NSString* flagFilePath = [NSString stringWithFormat:@"%@.flag", prefix]; //图片完整标记文件路径，如果存在表示文件下载完整
    NSString* imageFilePath = [NSString stringWithFormat:@"%@.img", prefix]; //图片文件路径
    
    __weak typeof(self) safeSelf = self;
    __block int trytimes = 0;
    __block BOOL isReady = NO;
    [BlockUtility performBlockInGlobalQueue:^{
        do {
            trytimes++;
            [BlockUtility syncPerformBlockInMainQueue:^{
                if (safeSelf.logoImageView) {
                    isReady = YES;
                    
                    //显示对应IM服务的LOGO图片
                    if ([FileUtility isReadableFileAtPath:flagFilePath] && [FileUtility isReadableFileAtPath:imageFilePath] && urlString) {
                        [self.logoImageView setImage:[UIImage imageWithContentsOfFile:imageFilePath]];
                    } else {
                        if ([FileUtility isReadableFileAtPath:cacheImageFilePath] && urlString) { //显示缓存LOGO图片
                            [self.logoImageView setImage:[UIImage imageWithContentsOfFile:cacheImageFilePath]];
                        } else { //显示默认LOGO图片
                            [self.logoImageView setImage:[UIImage imageNamed:@"default_logon_head"]];
                        }
                        
                        //远程下载并显示图片
                        if (urlString) {
                            NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
                            NSOperationQueue *queue = [[NSOperationQueue alloc]init];
                            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                NSLog(@"logo data.length = %@, statusCode = %@", @(data.length), @(httpResponse.statusCode));
                                
                                if (httpResponse.statusCode==200) {
                                    [FileUtility writeFileAtPath:imageFilePath data:data]; //写入图片文件
                                    [FileUtility writeFileAtPath:flagFilePath data:[[NSData alloc] init]]; //写入空文件
                                    [FileUtility writeFileAtPath:cacheImageFilePath data:data]; //写入默认图片文件
                                    
                                    [safeSelf.logoImageView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithContentsOfFile:imageFilePath] waitUntilDone:NO]; //显示刚下载完毕的图片
                                }
                            }];
                        }
                    }
                }
            }];
            
            [NSThread sleepForTimeInterval:0.2];
        } while (!isReady && trytimes<20);
    }];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    //计算几个按钮间隔约束
//    [self adjustButtons];
//}

- (void)viewDidAppear:(BOOL)animated
{
    //更新历史账号显示列表
    _accountList = [[CHKeychain userNamePasswords] mutableCopy];
    if (!self.accountDDList) {
        self.accountDDList = [[DropDownList alloc] initWithInputView:self.accountTextField rootView:self.view delegate:self];
    }
    self.accountDDList.data = [_accountList mutableCopy];
    [self.accountDDList refresh];
    
//    if (self.accountListTableView)
//        [self.accountListTableView reloadData];
    
    //键盘活动事件监测
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil]; //self.accountTextField
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:self.passwordTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil]; //self.accountTextField
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:self.passwordTextField];

//    NSString* title = [NSString stringWithFormat:@"服务器 %@", ENTBoostKit.serverAddress];
    NSString* title = @"连接配置";
    [self.serverConfigButton setTitle:title forState:UIControlStateNormal];
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //删除事件监测注册
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil]; //self.accountTextField
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:self.passwordTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil]; //self.accountTextField
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:self.passwordTextField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//键盘显示事件
- (void)keyboardWasShown:(NSNotification *)notif
{
    NSLog(@"keyboardWasShown->logonViewController notification's name:%@", notif.name);
    NSDictionary *info = [notif userInfo];
    CGRect keyboardBounds;
    [[info valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    CGFloat keyboardHeight = keyboardBounds.size.height;
    
    //整个视图往上升
    CGRect frame = self.view.frame;
    self.view.frame = CGRectMake(0, -keyboardHeight + 140, frame.size.width, frame.size.height);
}

//键盘即将隐藏事件
- (void)keyboardWillHidden:(NSNotification *)notif
{
    NSLog(@"keyboardWillHidden->logonViewController notification's name:%@", notif.name);
    
    //整个视图回到原位
    CGRect frame = self.view.frame;
    self.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

//点击游客登录按钮事件
- (IBAction)loginVistorButtonPressed:(id)sender
{
    //发送正在登录通知事件
    [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_LOGON_EXECUTING object:self userInfo:nil];
    
    [BlockUtility performBlockInGlobalQueue:^{ //在并发线程中执行
        ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
        [ebKit logonSyncVisitorOnCompletion:^(EBAccountInfo *accountInfo) {
            NSLog(@"游客登录成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_MANUAL_LOGON_SUCCESS object:self userInfo:nil];
        } onFailure:^(NSError *error) {
            NSLog(@"登录恩布通讯服务失败, code = %@, msg = %@", @(error.code), error.localizedDescription);
            [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_MANUAL_LOGON_FAILURE object:self userInfo:@{@"error":error}];
        }];
    }];
}

//点击登录按钮事件
- (IBAction)loginButtonPressed:(id)sender
{
    //隐藏键盘
    [self.accountTextField resignFirstResponder];
//    [self.accountField.textField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    //获取用户账号和密码
    NSString* account = [self.accountTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(account.length==0 || password.length==0) {
        [[[UIAlertView alloc] initWithTitle:@"操作错误" message:@"用户名和密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    
    self.loginButton.enabled = NO;
    
    //发送正在登录通知事件
    [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_LOGON_EXECUTING object:self userInfo:nil];
    
    //执行登录过程
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInGlobalQueue:^{ //在并发线程中执行
        ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
        [ebKit logonSyncWithAccount:account password:password onCompletion:^(EBAccountInfo *accountInfo) {
            NSLog(@"用户登录成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_MANUAL_LOGON_SUCCESS object:self userInfo:nil];
            
            [BlockUtility performBlockInMainQueue:^{
                //用户账号和密码保存至操作系统密码链
                [CHKeychain saveUserName:account AndPassword:password];
                
                //更新历史账号显示列表
                _accountList = [[CHKeychain userNamePasswords] mutableCopy];
                [safeSelf.accountDDList.data removeAllObjects];
                [safeSelf.accountDDList.data addObjectsFromArray:_accountList];
                [safeSelf.accountDDList refresh];
                
                safeSelf.loginButton.enabled = YES;
            }];
        } onFailure:^(NSError *error) {
            NSLog(@"登录恩布通讯服务失败, code = %@, msg = %@", @(error.code), error.localizedDescription);
            [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_MANUAL_LOGON_FAILURE object:self userInfo:@{@"error":error}];
            [BlockUtility performBlockInMainQueue:^{
                safeSelf.loginButton.enabled = YES;
            }];
        }];
    }];
}

//显示账号下拉列表
- (IBAction)showAccountList:(id)sender
{
    if (!self.accountDDList || [self.accountDDList isHidden]) {
        [self.accountDDList show:NO];
        self.accountRightImageView.image = [UIImage imageNamed:@"logon_triangle_un"];
//        [self showAccountListInDefaultFrameByHidden:NO];
    } else {
        [self.accountDDList show:YES];
        self.accountRightImageView.image = [UIImage imageNamed:@"logon_triangle"];
//        [self showAccountListInDefaultFrameByHidden:YES];
    }
}

////在默认位置显示账号历史下拉列表
//- (void)showAccountListInDefaultFrameByHidden:(BOOL)hidden
//{
////    CGRect accountListFrame = [[self.accountTextField superview] convertRect:self.accountTextField.frame toView:self.view];
////    UITableView* accountListTableView = [self accountListTableView];
////    [self toggleAccountList:hidden toTargetFrame:accountListFrame inView:self.view usingListTableView:&accountListTableView];
//}

//- (void)toggleAccountList:(BOOL)hidden toTargetFrame:(CGRect)targetFrame inView:(UIView*)view usingListTableView:(UITableView**)listTableView
//{
//    if (!hidden) {
////        NSLog(@"source rect:%@", NSStringFromCGRect(self.accountTextField.frame));
////        CGRect targetFrame = [[self.accountTextField superview] convertRect:self.accountTextField.frame toView:self.view];
////        NSLog(@"dest rect:%@", NSStringFromCGRect(targetFrame));
//        
//        targetFrame.origin.y = targetFrame.origin.y + self.accountTextField.frame.size.height;
//        targetFrame.size.height = (_accountList.count+1) * 30.0;
//        
//        UITableView* tableView = (*listTableView);
//        //创建下拉列表
//        if (!tableView) {
//            tableView = [[UITableView alloc] initWithFrame:targetFrame];// CGRectMake(0, 30, frame.size.width, 200)];
//            (*listTableView) = tableView;
//
//            if (IOS7)
//              tableView.separatorInset = UIEdgeInsetsZero;
//            tableView.delegate = self;
//            tableView.dataSource = self;
//            tableView.backgroundColor = [UIColor whiteColor];
//            tableView.separatorColor = [UIColor lightGrayColor];
//            [view addSubview:tableView];
//            
//            EBCHAT_UI_SET_CORNER_BUTTON_3(tableView);
//        } else {
//            tableView.frame = targetFrame;
//            tableView.hidden = hidden;
//        }
//    } else {
//        (*listTableView).hidden = hidden;
//    }
//}

//注册新用户
- (IBAction)registUser:(id)sender
{
    
    RegistUserViewController* scViewController = [_logonStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_REGISTUSER_CONTROLLER];
    UINavigationController* navigationController = [[PublicUI sharedInstance] navigationControllerWithRootViewController:scViewController];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:scViewController];
//    
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
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

//重置密码
- (IBAction)resetPassword:(id)sender
{
    //resetPwdUrl
    ResetPasswordViewController* resetPwdViewController = [_logonStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_RESETPASSWORD_CONTROLLER];
    resetPwdViewController.resetPwdUrl = [ENTBoostKit sharedToolKit].resetPasswordUrl;
    NSLog(@"%@", resetPwdViewController.resetPwdUrl);
    UINavigationController* navigationController = [[PublicUI sharedInstance] navigationControllerWithRootViewController:resetPwdViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

//点击界面背景事件
- (IBAction)backgroundTap:(id)sender
{
    //隐藏键盘
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    //隐藏历史下拉列表
    [self.accountDDList show:YES];
    self.accountRightImageView.image = [UIImage imageNamed:@"logon_triangle"];
//    [self showAccountListInDefaultFrameByHidden:YES];
}

//用户账号输入完毕后事件
- (IBAction)accountDidEndOnExit:(id)sender
{
    [self.passwordTextField becomeFirstResponder];
}

//点击修改服务器配置按钮事件
- (IBAction)serverConfigButtonTap:(id)sender
{
    ServerConfigViewController* scViewController = [_logonStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_SERVERCONFIG_CONTROLLER];
    UINavigationController* navigationController = [[PublicUI sharedInstance] navigationControllerWithRootViewController:scViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
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

#pragma mark -  UITextFieldDelegate

- (void)textFiledEditChanged:(NSNotification*)notif
{
//    UITextField *textField = notif.object;
//    if (textField==self.accountTextField) {
//        //当账号输入框内容有变更时，清除密码输入框内容
//        if (textField.text && ![_lastAccount isEqualToString:textField.text]) {
//            self.passwordTextField.text = nil;
//        }
//        _lastAccount = textField.text;
//    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==self.accountTextField) {
        [self.accountTextField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    } else if (textField==self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
        [self loginButtonPressed:nil]; //执行登录
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    if (textField==self.accountTextField)
//        [self.accountDDList show:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.accountTextField) {
        [self.accountDDList show:YES];
        self.accountRightImageView.image = [UIImage imageNamed:@"logon_triangle"];
        
        //当账号输入框内容有变更时，清除密码输入框内容
        if (textField.text && ![_lastAccount isEqualToString:textField.text]) {
            self.passwordTextField.text = nil;
        }
        _lastAccount = textField.text;
    }
}


#pragma mark - DropDrownListDelegate

- (void)dropDownList:(DropDownList *)dropDownList atRow:(NSUInteger)row supplyCell:(UITableViewCell *)cell data:(id)data
{
    UserNamePassword* unp = data;
    cell.textLabel.text = unp.userName;
    cell.textLabel.textColor = self.accountTextField.textColor;
}

- (void)dropDownList:(DropDownList *)dropDownList atRow:(NSUInteger)row didSelectedWithData:(id)data
{
    [self.accountTextField resignFirstResponder];
    [self.accountDDList show:YES];
    self.accountRightImageView.image = [UIImage imageNamed:@"logon_triangle"];

    UserNamePassword* unp = data;
    self.accountTextField.text = unp.userName;
    
    if (unp.password)
        self.passwordTextField.text = unp.password;
    else {
        //当账号输入框内容有变更时，清除密码输入框内容
        if (self.accountTextField.text && ![_lastAccount isEqualToString:self.accountTextField.text]) {
            self.passwordTextField.text = nil;
        }
    }
    _lastAccount = self.accountTextField.text;
    
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField becomeFirstResponder];
}

- (void)dropDownList:(DropDownList *)dropDownList atRow:(NSUInteger)row deleteWithData:(id)data
{
    UserNamePassword* unp = data;
    [_accountList removeObjectAtIndex:row]; //从缓存里删除
    [CHKeychain removeUserName:unp.userName]; //从持久化保存里删除
}

//
//#pragma mark - UITableView
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return _accountList.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    UserNamePassword* unp = _accountList[indexPath.row];
//    
//    cell.textLabel.text = unp.userName;
//    cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    return cell;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 30.0;
//}
//
//////行缩进
////-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
////    return 0;
////}
//
////- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
////{
////    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
////        [cell setPreservesSuperviewLayoutMargins:NO];
////    }
////}
//
////- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
////{
////    return 30.0;
////}
////
////- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
////{
////    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30.0)];
////    [view setBackgroundColor:[UIColor clearColor]];
////    
////    return view;
////}
//
//
//- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self.accountTextField resignFirstResponder];
//    [self.accountListTableView setHidden:YES];
//    
//    UserNamePassword* unp = _accountList[indexPath.row];
//    self.accountTextField.text = unp.userName;
//    NSString* password;
//    if ([unp.password isMemberOfClass:[NSString class]])
//        password = unp.password;
//    self.passwordTextField.text = password;
//    
//    [self.accountTextField resignFirstResponder];
//    [self.passwordTextField becomeFirstResponder];
//    
////    self.textField.text = [self.tableArray objectAtIndex:[indexPath row]];
////    _isShowList = NO;
////    self.tv.hidden = YES;
////    
////    CGRect sf = self.frame;
////    sf.size.height = 30;
////    self.frame = sf;
////    
////    CGRect frame = self.tv.frame;
////    frame.size.height = 0;
////    self.tv.frame = frame;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        UserNamePassword* unp = _accountList[indexPath.row];
//        [_accountList removeObjectAtIndex:indexPath.row]; //从缓存里删除
//        [CHKeychain removeUserName:unp.userName]; //从持久化保存里删除
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft]; //删除视图对应行
//    }
//}
//
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete;
//}
//
//- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return @"删除";
//}
@end
