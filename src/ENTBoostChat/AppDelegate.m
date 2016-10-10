//
//  AppDelegate.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-2.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "AppDelegate.h"
#import "ENTBoostChat.h"
#import "BlockUtility.h"
#import "MainViewController.h"
#import "TalksTableViewController.h"
#import "RelationshipsViewController.h"
#import "CHKeychain.h"
#import "FileUtility.h"
#import "ENTBoost+Utility.h"
#import "PublicUI.h"

#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()
{
    uint64_t _sslId; //在恩布平台登记的远程推送证书编号
    UIStoryboard* _mainStoryboard;
}
//用于远程推送的设备令牌
@property(atomic, strong) NSString* deviceToken;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _mainStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_MAIN bundle:nil];
    
#if !TARGET_IPHONE_SIMULATOR
    //如果是真机标准日志输出保存到文件
    [self redirectNSlogToFile];
    
    //设置远程推送证书编号，该编号由恩布平台统一分配
    //恩布推送证书编号[DEV]，用于网站下载版：7606616803963781
    //恩布推送证书编号[PRD]，用于AppStore版：7715636013842198
    _sslId = 7715636013842198;
#endif
    
    //设置发布版本打包编号
    self.buildNo = @"149";
    
//    NSLog(@"launchOptions:\n%@", launchOptions);
//    NSLog(@"UIApplicationLaunchOptionsRemoteNotificationKey=%@", UIApplicationLaunchOptionsRemoteNotificationKey);
    NSDictionary* payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (payload) {
        NSLog(@"launch payload:\n%@", payload);
    }
    
    //获取SDK接口全局单实例
    //由于内部有重要的初始化任务，因此第一次获取实例务必保证同步执行结束
    //不要放在非主线程中执行
    [ENTBoostKit sharedToolKit];
    
    //注册APNS推送通知权限
    [self registerForRemoteNotifications:application options:(NSDictionary *)launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //设置服务器连接地址
    NSString* serverAddress = [self dataForKey:EBCHAT_ESRVER_ADDRESS_KEY];
    if (serverAddress && serverAddress.length)
        [ENTBoostKit setServerAddress:serverAddress];
    else
        [ENTBoostKit setServerAddress:@"entboost.entboost.com:18012"];
    
    //生成登录界面控制器
    UIStoryboard* logonStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_LOGON bundle:nil];
    self.logonViewController = [logonStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_LOGON_CONTROLLER];
    self.logonViewController.loginButton.enabled = NO;
    
    //启动图界面控制器
    self.splashScreenController = [logonStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_SPLASH_SCREEN_CONTROLLER];

//    //生成主控制器
//    self.tabBarController = [_mainStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_TABBAR_CONTROLLER];
//    self.mainNavigationController = [[[UINavigationController alloc] init] initWithRootViewController:self.tabBarController];
//    [[PublicUI sharedInstance] configureNavigationController:self.mainNavigationController];

    //设置默认页
    self.window.rootViewController = self.splashScreenController;
    [self.window makeKeyAndVisible];
    
    //注册接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoffHandle:) name:EBCHAT_NOTIFICATION_MANUAL_LOGOFF object:nil]; //手工退出登录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logonSuccessHandle:) name:EBCHAT_NOTIFICATION_MANUAL_LOGON_SUCCESS object:nil]; //手工登录成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logonFailureHandle:) name:EBCHAT_NOTIFICATION_MANUAL_LOGON_FAILURE object:nil]; //手工登录失败
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logonExecutingHandle:) name:EBCHAT_NOTIFICATION_LOGON_EXECUTING object:nil]; //正在执行登录
    
    //执行初始化恩布SDK环境
    [self performSelector:@selector(initENTBoostKit) withObject:nil afterDelay:0.5];
    
//    self.inBackground = NO;
    
    return YES;
}

- (void)dealloc
{
    //移除接收通知的注册
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EBCHAT_NOTIFICATION_MANUAL_LOGOFF object:nil]; //手工退出登录
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EBCHAT_NOTIFICATION_MANUAL_LOGON_SUCCESS object:nil]; //手工登录成功
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EBCHAT_NOTIFICATION_MANUAL_LOGON_FAILURE object:nil]; //手工登录成功
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EBCHAT_NOTIFICATION_LOGON_EXECUTING object:nil]; //正在执行登录
}

//初始化环境
- (void)initENTBoostKit
{
    //测试应用ID可到恩布官网申请获取 www.entboost.com
    NSString* appId =@"278573612908";
    NSString* appKey =@"ec1b9c69094db40d9ada80d657e08cc6";
    
    __weak typeof(self)safeSelf = self; //安全引用self对象,防止Block循环引用
    [BlockUtility performBlockInGlobalQueue:^{
    #if !TARGET_IPHONE_SIMULATOR
        //等待从苹果APNS服务器获取设备令牌
        int tryTimes = 0;
        while (!safeSelf.deviceToken && tryTimes < 10) {
            [NSThread sleepForTimeInterval:0.5];
            tryTimes++;
        }
        if (!safeSelf.deviceToken) {
//            [BlockUtility performBlockInMainQueue:^{
//                //提示重新初始化
//                NSString* msg = [NSString stringWithFormat:@"注册远程通知失败, 请重试"];
//                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:safeSelf cancelButtonTitle:@"重试" otherButtonTitles:@"放弃", nil];
//                [alertView show];
//            }];
//            return;
            NSLog(@"注册远程通知失败");
        }
    #endif
        
        //获取SDK接口全局单实例
        ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
        
        //设置尝试自动登录
        NSNumber* autoLogon = [safeSelf dataForKey:EBCHAT_AUTO_LOGON_ENABLED];
        if (autoLogon) { //有结果
            if (autoLogon.boolValue) //允许自动登录
                ebKit.wantAutoLogon = YES;
            else //不允许自动登录
                ebKit.wantAutoLogon = NO;
        } else {
            [safeSelf saveData:@YES forKey:EBCHAT_AUTO_LOGON_ENABLED];
            ebKit.wantAutoLogon = YES;
        }
        
        //注册和初始化恩布SDK环境
        [ebKit registerWithAppId:appId appKey:appKey andDelegate:safeSelf onCompletion:^{
            NSLog(@"恩布SDK初始化成功");
            //设置远程推送参数
            [ebKit setAPNSWithSSLId:_sslId andDeviceToken:safeSelf.deviceToken];
            
            [BlockUtility performBlockInMainQueue:^{ //主线程中执行
                [safeSelf.logonViewController asyncLoadAndShowLogo:ebKit.entLogoUrl];
                [safeSelf.logonViewController updateProductInformation];
                
                if (!ebKit.wantAutoLogon) {//非自动登录
                    self.window.rootViewController = safeSelf.logonViewController; //显示登录界面
                    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide]; //显示状态栏
                }
                
                safeSelf.logonViewController.loginButton.enabled = YES; //启用登录按钮
            }];
        } onFailure:^(NSError *error) {
            NSLog(@"恩布SDK初始化失败, code = %@, msg = %@", @(error.code), error.localizedDescription);
            [BlockUtility performBlockInMainQueue:^{ //主线程中执行
                //提示重新初始化
                NSString* msg = [NSString stringWithFormat:@"应用初始化失败, 请确认网络可用的情况下重试或修改连接配置"];
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:safeSelf cancelButtonTitle:@"重试" otherButtonTitles:@"连接配置", nil];
                [alertView show];
            }];
            
        }];
    }];
}

//定义的委托, 提示初始化失败后再次执行初始化
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag!=101) {
        if (buttonIndex ==0) {
            //重新注册APNS推送通知权限
            [self registerForRemoteNotifications:[UIApplication sharedApplication] options:nil];
            [self initENTBoostKit];
        } else {
            self.window.rootViewController = self.logonViewController; //显示登录界面
            [self.logonViewController serverConfigButtonTap:nil]; //进入连接配置界面
        }
    }
}

//退出登录事件处理方法
- (void)logoffHandle:(NSNotification*)notif
{
    NSDictionary* userInfo = notif.userInfo;
    if (userInfo[@"clearPasswordInput"] && ![userInfo[@"clearPasswordInput"] boolValue])
        [self resetApplication:NO acceptPush:NO];
    else
        [self resetApplication:YES acceptPush:NO];
    
    [self initENTBoostKit];
    
    //操作提示
    if (userInfo[@"description"]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:userInfo[@"description"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

//登录成功事件处理方法
- (void)logonSuccessHandle:(NSNotification*)notif
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        if (!safeSelf.tabBarController) {
            safeSelf.tabBarController = [_mainStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_TABBAR_CONTROLLER];
            safeSelf.mainNavigationController = [[UINavigationController alloc] initWithRootViewController:safeSelf.tabBarController];
            [[PublicUI sharedInstance] configureNavigationController:self.mainNavigationController];
        }
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide]; //显示状态栏
        safeSelf.window.rootViewController = safeSelf.mainNavigationController; //safeSelf.tabBarController; //切换主界面
        [safeSelf.tabBarController setSelectedIndex:0]; //设置第一个tab为焦点
        
        //设置尝试自动登录
        NSNumber* isAuto = notif.userInfo[@"auto"];
        if (!isAuto || ![isAuto boolValue]) {
            [ENTBoostKit sharedToolKit].wantAutoLogon = YES;
            [safeSelf saveData:@YES forKey:EBCHAT_AUTO_LOGON_ENABLED];
        }
    }];
}

- (void)logonFailureHandle:(NSNotification*)notif
{
    NSError* error = notif.userInfo[@"error"];
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        safeSelf.window.rootViewController = safeSelf.logonViewController;
        NSString* msg;
        
        if (error.code == EB_STATE_ACC_PWD_ERROR)
            msg = @"用户名或密码错误";
        else if (error.code == EB_STATE_TIMEOUT_ERROR)
            msg = @"登录超时";
        else if (error.code == EB_STATE_ACCOUNT_NOT_EXIST)
            msg = @"用户不存在";
        else if (error.code == EB_STATE_ACCOUNT_FREEZE)
            msg = @"用户已被锁定";
        else if (error.code == EB_STATE_MAX_RETRY_ERROR)
            msg = @"输入错误密码次数超限，请稍后重试";
        else if (error.code < 0)
            msg = [NSString stringWithFormat:@"应用异常，请完全关闭后重新打开应用，错误码：%@", @(error.code)];
        else
            msg = [NSString stringWithFormat:@"登录失败, code = %@, msg = %@", @(error.code), error.localizedDescription];
        
        [[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}

//正在执行登录事件处理方法
- (void)logonExecutingHandle:(NSNotification*)notif
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide]; //隐藏状态栏
        safeSelf.window.rootViewController = safeSelf.splashScreenController;
    }];
}

//注册APNS推送通知权限
- (void)registerForRemoteNotifications:(UIApplication*)application options:(NSDictionary *)launchOptions
{
    if (IOS10) { //IOS10
        #if !TARGET_IPHONE_SIMULATOR
        //注册APNS
        [application registerForRemoteNotifications];
        #endif
        
        //申请权限
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) { //点击允许
                NSLog(@"注册通知成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"%@", settings);
                }];
            } else { //点击不允许
                NSLog(@"注册通知失败");
            }
        }];
    } else {
        if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) { //IOS8-IOS9
            #if !TARGET_IPHONE_SIMULATOR
            //注册APNS
            [application registerForRemoteNotifications];
            #endif
            
            //申请权限
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
            [application registerUserNotificationSettings:settings];
        } else { //IOS7
            #if !TARGET_IPHONE_SIMULATOR
            [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
            #endif
        }
    }
    
    if (launchOptions) {
        NSDictionary* pushNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (pushNotificationKey) {
            //清除通知中心远程通知
            [application setApplicationIconBadgeNumber:1];
            [application setApplicationIconBadgeNumber:0];
        }
    }
}

- (void)addLocalNotification
{
    //间隔超过60秒才可以发一次通知，防止高频率刷屏
    BOOL needExecute = NO;
    @synchronized(self) {
        if (!self.lastLocalNotificationTime) {
            needExecute = YES;
        } else {
            NSTimeInterval interval = fabs([self.lastLocalNotificationTime timeIntervalSinceNow]);
            if (interval > 60) {
                needExecute = YES;
            }
        }
        
        if (needExecute)
            self.lastLocalNotificationTime = [NSDate date];
        else
            return;
    }
    
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification) {
        //从现在开始，1秒以后通知
        notification.fireDate=[[NSDate date] dateByAddingTimeInterval:1];
        //使用本地时区
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.alertBody= [NSString stringWithFormat:@"您有%lu条未读聊天信息", (unsigned long)[[ENTBoostKit sharedToolKit] countOfUnreadMessages]];
        //通知提示音
        notification.soundName= UILocalNotificationDefaultSoundName;
        notification.alertAction= NSLocalizedString(@"您有新消息", nil);
        //应用程序右上角显示的数字。
        notification.applicationIconBadgeNumber = [[ENTBoostKit sharedToolKit] countOfTalksHavingUnreadMessage];
        
//        //给这个通知增加key 便于中途取消。nfkey是自定义
//        NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:notificationTag], @"nfkey", nil];
//        [notification setUserInfo:dict];
        
        //启动这个通知
        [[UIApplication sharedApplication]  scheduleLocalNotification:notification];
        
        //这句真的特别特别重要。如果不加这一句，通知到时间了，发现顶部通知栏提示的地方有了，然后你通过通知栏进去，然后你发现通知栏里边还有这个提示
        //除非你手动清除，这当然不是我们希望的。加上这一句就好了。网上很多代码都没有，就比较郁闷了。
    }
}

- (void)resetApplicationWithServerAddress:(NSString*)serverAddress
{
    //复位应用环境
    [self resetApplication:YES acceptPush:YES];
    //缓存当前访问服务地址
    [self saveData:serverAddress forKey:EBCHAT_ESRVER_ADDRESS_KEY];
    //设置SDK访问服务地址
    [ENTBoostKit setServerAddress:serverAddress];
//    //显示访问服务地址
//    NSString* title = [NSString stringWithFormat:@"服务器 %@", ENTBoostKit.serverAddress];
//    [self.logonViewController.serverConfigButton setTitle:title forState:UIControlStateNormal];
    //初始化SDK环境
    [self performSelector:@selector(initENTBoostKit) withObject:nil afterDelay:0.5];
}

//重置应用
- (void)resetApplication:(BOOL)clearPasswordInput acceptPush:(BOOL)acceptPush
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    
    //执行注销登录
    [ebKit asyncLogoffWithAcceptPush:acceptPush];
//    //清空缓存
//    [ChatRenderingCache clear];
    
    //因为是主动注销，所以设置禁止自动登录
    ebKit.wantAutoLogon = NO;
    
    __block typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        //设置自动登录状态为否
        [safeSelf saveData:@NO forKey:EBCHAT_AUTO_LOGON_ENABLED];
        
        safeSelf.window.rootViewController = safeSelf.logonViewController; //显示登录界面
        safeSelf.logonViewController.loginButton.enabled = YES; //启用登录按钮
        
        if (clearPasswordInput) {
            [CHKeychain saveUserName:safeSelf.logonViewController.accountTextField.text AndPassword:nil]; //删除记录的密码
            safeSelf.logonViewController.passwordTextField.text = @""; //清空密码输入框
        }
        
        safeSelf.tabBarController = nil;
        safeSelf.mainNavigationController = nil;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide]; //显示状态栏
    }];
}

#pragma mark - persistence
- (void)saveData:(id)data forKey:(NSString*)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:key];
    [defaults synchronize]; //用synchronize方法把数据持久化到standardUserDefaults数据库
}

- (id)dataForKey:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

// 将NSlog打印信息保存到文件中
- (void)redirectNSlogToFile
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd-HHmmss"];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *logFilePath = [NSString stringWithFormat:@"%@/entboost/logs/rollfile-%@.txt", paths[0], [dateFormatter stringFromDate:[NSDate date]]];
    NSString *logFilePath = [NSString stringWithFormat:@"%@/rollfile-%@.txt", [FileUtility ebChatLogDirectory], [dateFormatter stringFromDate:[NSDate date]]];
    
    NSString* dirPath = [logFilePath stringByDeletingLastPathComponent];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dirPath]) {
        NSLog(@"try to create directory = %@", dirPath);
        NSError* pError;
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&pError];
        if(pError) {
            NSLog(@"create directory = %@ error, code = %li, msg = %@", dirPath, (long)pError.code, pError.localizedDescription);
        }
    }
    
    // 将log重定向输出到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
    
    //===清理比较旧的日志文件
    NSDateFormatter* ptDateFormatter =[[NSDateFormatter alloc] init];
    [ptDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSError* error;
    NSArray* files = [fileManager subpathsOfDirectoryAtPath:dirPath error:&error];
    NSMutableArray* toBeDeletedFiles = [[NSMutableArray alloc] init]; //待删除文件列表
    
    //遍历日志目录获取比较旧的日志文件
    if (!error) {
        NSDate* now = [NSDate date];
        for (NSString* fileName in files) {
            if (fileName) {
                NSString* filePath = [NSString stringWithFormat:@"%@/%@", dirPath, fileName];
                BOOL isDirectory = NO; //是否文件夹
                if ([fileManager fileExistsAtPath:filePath isDirectory:&isDirectory] && !isDirectory) {
                    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
                    if (!error) {
                        NSDate *fileModDate = [fileAttributes objectForKey:NSFileModificationDate];
                        NSTimeInterval timeInterval = fabs([now timeIntervalSinceDate:fileModDate]);
                        NSInteger iDays = timeInterval/60/60/24;
                        //7天以前的文件将被删除
                        if (iDays >=7)
                            [toBeDeletedFiles addObject:fileName];
//                        NSLog(@"fileName:%@ | modified date:%@ | interval = %0.f | iDays = %@", fileName, [ptDateFormatter stringFromDate:fileModDate], timeInterval, @(iDays));
                    }
                }
            }
        }
    }
    
    //删除日志文件
    if ([toBeDeletedFiles count]) {
        for (NSString* fileName in toBeDeletedFiles) {
            NSString* filePath = [NSString stringWithFormat:@"%@/%@", dirPath, fileName];
            [fileManager removeItemAtPath:filePath error:&error];
            if (!error)
                NSLog(@"delete log file:%@", filePath);
        }
    }
}


#pragma mark - application event
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [[ENTBoostKit sharedToolKit] countOfTalksHavingUnreadMessage]; //更新应用图标上数字
    [self.tabBarController.talksController handleAVResourceDisabled]; //通知聊天会话音视频资源不可用
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    //清除所有本地通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    [self.tabBarController.talksController handleAVResourceDisabled]; //通知聊天会话音视频资源不可用
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    NSString* token = [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];
//    NSString* token = [NSString stringWithFormat:@"%@", deviceToken];
//    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
//    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
//    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSUInteger len = [deviceToken length];
    char *chars = (char *)[deviceToken bytes];
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for(NSUInteger i = 0; i < len; i++ )
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
    
    NSLog(@"apns -> 生成的devToken:%@", hexString);
    self.deviceToken = hexString;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"apns -> 注册推送功能时发生错误， 错误信息:\n %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"apns -> didReceiveRemoteNotification, Receive Data:\n%@", userInfo);

    //清除通知中心远程通知
    [application setApplicationIconBadgeNumber:1];
    [application setApplicationIconBadgeNumber:0];
//    [application cancelAllLocalNotifications];
}

// -------IOS10接收通知的实现方法-----
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    //应用在前台收到通知
    NSLog(@"========%@", notification); //如果需要在应用在前台也展示通知
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    //点击通知进入应用
    NSLog(@"response:%@", response);
}
// -------IOS10接收通知的实现方法-----

#pragma mark - ENTBoostKitDelegate

#pragma mark - 登录流程事件

- (void)onLogonBeginForAccount:(NSString *)account uid:(uint64_t)uid virtualAccount:(NSString *)virtualAccount type:(int)type
{
    NSLog(@"onLogonBeginForAccount, uid = %llu, account = %@, virtualAccount = %@, type = %i", uid, account, virtualAccount, type);
}

- (void)onLogonProcessing:(int)step
{
    NSLog(@"onLogonProcessing step = %i", step);
}

- (void)onLogonCompletion:(EBAccountInfo *)accountInfo
{
    NSLog(@"onLogonCompletion, uid = %llu, account = %@, userName = %@", accountInfo.uid, accountInfo.account, accountInfo.userName);
    [self.tabBarController.talksController handleLogonCompletion:accountInfo];
    [self.tabBarController.relationshipController handleLogonCompletion:accountInfo];
}

- (void)onLogonError:(NSError *)error
{
    NSLog(@"onLogonError, code = %@, msg = %@", @(error.code), error.localizedDescription);
}

//自动登录状况回调事件
- (void)onAutoLogonEvent:(BOOL)state accountInfo:(EBAccountInfo *)accountInfo error:(NSError *)error
{
    NSLog(@"onAutoLogonEvent state = %i, code = %@, msg = %@", state, @(error.code), error.localizedDescription);
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        if (state) { //登录成功
//            //把MainViewController设置为根控制器
//            safeSelf.window.rootViewController = safeSelf.mainNavigationController; //safeSelf.tabBarController;
            [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_MANUAL_LOGON_SUCCESS object:self userInfo:@{@"auto":@YES}];
        } else { //登录失败
//            //把LogonViewController设置为根控制器
//            safeSelf.window.rootViewController = safeSelf.logonViewController;
//            safeSelf.logonViewController.loginButton.enabled = YES;
            if (error && error.code==EB_STATE_ACC_PWD_ERROR)
                [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_MANUAL_LOGOFF object:safeSelf userInfo:@{@"clearPasswordInput":@YES}];
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_MANUAL_LOGOFF object:safeSelf userInfo:@{@"clearPasswordInput":@NO}];
//            [safeSelf logoffHandle:nil];
        }
    }];
}

//表情和头像资源文件下载完成事件
- (void)onLoadedEmotionsComplete:(NSArray *)expressions headPhotos:(NSArray *)headPhotos
{
    [self.tabBarController.talksController refreshEmotions:expressions headPhotos:headPhotos];
}

#pragma mark - 呼叫会话事件

//会话已经接通
- (void)onCallConnected:(const EBCallInfo *)callInfo
{
    [self.tabBarController.talksController handleCall:callInfo callActionType:CALL_ACTION_TYPE_CONNECTED];
}

//被邀请方忙，未应答
- (void)onCallBusy:(const EBCallInfo *)callInfo
{
    [self.tabBarController.talksController handleCall:callInfo callActionType:CALL_ACTION_TYPE_BUSY];
}

//被邀请方拒绝通话
- (void)onCallReject:(const EBCallInfo *)callInfo
{
    [self.tabBarController.talksController handleCall:callInfo callActionType:CALL_ACTION_TYPE_REJECT];
}

//断开会话
- (void)onCallHangup:(const EBCallInfo *)callInfo
{
    [self.tabBarController.talksController handleCallHangup:callInfo];
}

//正在进行会话邀请
- (void)onCallAlerting:(const EBCallInfo *)callInfo toUid:(uint64_t)toUid
{
    [self.tabBarController.talksController handleCallAlerting:callInfo toUid:toUid];
}

//接收到会话邀请
- (void)onCallIncoming:(const EBCallInfo *)callInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard clientAddress:(NSString *)clientAddress
{
    [self.tabBarController.talksController handleCallIncoming:callInfo fromUid:fromUid fromAccount:fromAccount vCard:vCard clientAddress:clientAddress];
}

#pragma mark - 常用事件

- (void)onNewNotification:(EB_TALK_TYPE)type notiId:(uint64_t)notiId
{
    [self.tabBarController.talksController handleNewNotification:type notiId:notiId];
}

#pragma mark - 联系人、部门、群组变更通知事件

//有人申请入群的通知事件
- (void)onRequestToJoinGroup:(EBGroupInfo *)groupInfo description:(NSString *)description fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    [self.tabBarController.talksController handleRequestToJoinGroup:groupInfo description:description fromUid:fromUid fromAccount:fromAccount];
}

//被邀请进入群(部门)的通知事件
- (void)onInvitedToJoinGroup:(uint64_t)depCode groupName:(NSString *)groupName description:(NSString *)description fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    [self.tabBarController.talksController handleInvitedToJoinGroup:depCode groupName:groupName description:description fromUid:fromUid fromAccount:fromAccount];
}

//被邀请方拒绝进入群(部门)或者管理员拒绝入群申请的通知事件
- (void)onRejectToJoinGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    [self.tabBarController.talksController handleRejectToJoinGroup:groupInfo fromUid:fromUid fromAccount:fromAccount];
}

//有一个新成员加入到部门或群组的通知事件
- (void)onAddMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    [self.tabBarController.relationshipController handleAddMember:memberInfo toGroup:groupInfo fromUid:fromUid fromAccount:fromAccount];
    [self.tabBarController.talksController handleAddMember:memberInfo toGroup:groupInfo fromUid:fromUid fromAccount:fromAccount];
}

//有一个成员退出(包括主动和被动)部门或群组的通知事件
- (void)onExitMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount passive:(BOOL)passive targetIsMe:(BOOL)targetIsMe
{
    [self.tabBarController.relationshipController handleExitMember:memberInfo toGroup:groupInfo fromUid:fromUid fromAccount:fromAccount passive:passive targetIsMe:targetIsMe];
}

//部门或群组成员资料变更的通知事件
- (void)onUpdateMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    [self.tabBarController.relationshipController handleUpdateMember:memberInfo toGroup:groupInfo fromUid:fromUid fromAccount:fromAccount];
    [self.tabBarController.talksController handleUpdateMember:memberInfo toGroup:groupInfo fromUid:fromUid fromAccount:fromAccount];
}

//新增或修改部门或群组资料的通知事件
- (void)onUpdateGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    [self.tabBarController.relationshipController handleUpdateGroup:groupInfo fromUid:fromUid fromAccount:fromAccount];
}

//删除部门或群组的通知事件
- (void)onDeleteGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    [self.tabBarController.relationshipController handleDeleteGroup:groupInfo fromUid:fromUid fromAccount:fromAccount];
    [self.tabBarController.talksController handleDeleteGroup:groupInfo fromUid:fromUid fromAccount:fromAccount];
}

//新增临时讨论组的通知事件
- (void)onAddTempGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    [self.tabBarController.relationshipController handleAddTempGroup:groupInfo fromUid:fromUid fromAccount:fromAccount];
    [self.tabBarController.talksController handleAddTempGroup:groupInfo fromUid:fromUid fromAccount:fromAccount];
}

//被邀请为好友的通知事件
- (void)onAddContactRequestFromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard description:(NSString *)description
{
    [self.tabBarController.talksController handleAddContactRequestFromUid:fromUid fromAccount:fromAccount vCard:vCard description:description];
}

//好友邀请被接受的通知事件
- (void)onAddContactAccept:(EBContactInfo *)contactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard
{
    [self.tabBarController.relationshipController handleAddContactAccept:contactInfo fromUid:fromUid fromAccount:fromAccount vCard:vCard];
    [self.tabBarController.talksController handleAddContactAccept:contactInfo fromUid:fromUid fromAccount:fromAccount vCard:vCard];
}

//好友邀请被拒绝的通知事件
- (void)onAddContactRejectFromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard description:(NSString *)description
{
    [self.tabBarController.talksController handleAddContactRejectFromUid:fromUid fromAccount:fromAccount vCard:vCard description:description];
}

//删除好友的通知事件
- (void)onDeleteContact:(EBContactInfo *)contactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount isBothDeleted:(BOOL)isBothDeleted
{
    [self.tabBarController.relationshipController handleDeleteContact:contactInfo fromUid:fromUid fromAccount:fromAccount isBothDeleted:isBothDeleted];
}

//被对方删除好友的通知事件
- (void)onBeDeletedContact:(EBContactInfo *)contactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard isBothDeleted:(BOOL)isBothDeleted
{
    [self.tabBarController.relationshipController handleBeDeletedContact:contactInfo fromUid:fromUid fromAccount:fromAccount vCard:vCard isBothDeleted:isBothDeleted];
}

//用户状态变化
- (void)onUserChangeLineState:(EB_USER_LINE_STATE)userLineState fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount inEntGroups:(NSArray *)entGroupIds inPersonalGroups:(NSArray *)personalGroupIds
{
    [self.tabBarController.relationshipController handleUserChangeLineState:userLineState fromUid:fromUid fromAccount:fromAccount inEntGroups:entGroupIds inPersonalGroups:personalGroupIds];
    [self.tabBarController.talksController handleUserChangeLineState:userLineState fromUid:fromUid fromAccount:fromAccount inEntGroups:entGroupIds inPersonalGroups:personalGroupIds];
}

- (void)onUserKickedByAnotherFromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_MANUAL_LOGOFF object:safeSelf userInfo:@{@"clearPasswordInput":@NO, @"description":@"当前用户在别处登录，您已被强制登出应用；如不是您本人操作，请注意是否被他人盗号！"}];
    }];
}

#pragma mark - 接收消息、文件的事件

//接收到聊天消息
- (void)onRecevieMessage:(EBMessage*)message
{
    [self.tabBarController.talksController dispatchReceviedMessage:message ackBlock:nil cancelBlock:nil];
}

//即将开始接收文件事件
- (void)onWillRecevieFileForCall:(uint64_t)callId msgId:(uint64_t)msgId msgTime:(NSDate *)msgTime fromUid:(uint64_t)fromUid fileName:(NSString *)fileName fileSize:(uint64_t)fileSize ackBlock:(EB_RECEIVE_FILE_ACK_BLOCK)ackBlock cancelBlock:(EB_RECEIVE_FILE_CANCEL_BLOCK)cancelBlock
{
    [self.tabBarController.talksController handleWillRecevieFileForCall:callId msgId:msgId msgTime:msgTime fromUid:fromUid fileName:fileName fileSize:fileSize ackBlock:ackBlock cancelBlock:cancelBlock];
}

- (void)onBeginRecevieFileForCall:(uint64_t)callId msgId:(uint64_t)msgId
{
    [self.tabBarController.talksController handleBeginRecevieFileForCall:callId msgId:msgId];
}

- (void)onDidRecevieFileForCall:(uint64_t)callId msgId:(uint64_t)msgId
{
    [self.tabBarController.talksController handleDidRecevieFileForCall:callId msgId:msgId];
}

- (void)onRecevingFileForCall:(uint64_t)callId msgId:(uint64_t)msgId percent:(double_t)percent speed:(double_t)speed
{
    [self.tabBarController.talksController handleRecevingFileForCall:callId msgId:msgId percent:percent speed:speed];
}

- (void)onCancelRecevingFileForCall:(uint64_t)callId msgId:(uint64_t)msgId initiative:(BOOL)initiative
{
    [self.tabBarController.talksController handleCancelRecevingFileForCall:callId msgId:msgId initiative:initiative];
}

- (void)onRecevieFileError:(NSError*)error forCall:(uint64_t)callId msgId:(uint64_t)msgId
{
    [self.tabBarController.talksController handleRecevieFileError:error forCall:callId msgId:msgId];
}

#pragma mark - 发送文件事件

//发送文件完成事件(通常用于接收离线文件)
- (void)onDidSentFileForCall:(uint64_t)callId msgId:(uint64_t)msgId
{
    [self.tabBarController.talksController handleDidSentFileForCall:callId msgId:msgId];
}

//对方取消或拒绝接收文件事件(通常用于接收离线文件)
- (void)onCancelSentFileForCall:(uint64_t)callId msgId:(uint64_t)msgId
{
    [self.tabBarController.talksController handleCancelSentFileForCall:callId msgId:msgId];
}

#pragma mark - 音视频事件

//一位演讲者(发出音视频数据的用户)加入音视频通话的事件
- (void)onAVOratorJoin:(uint64_t)callId fromUid:(uint64_t)fromUid includeVideo:(BOOL)includeVideo
{
    [self.tabBarController.talksController handleAVOratorJoin:callId fromUid:fromUid includeVideo:includeVideo];
}

//一位接收者(接收音视频数据的用户)加入音视频通话的事件
- (void)onAVReceiverJoin:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    [self.tabBarController.talksController handleAVReceiverJoin:callId fromUid:fromUid];
}

//一位参与者离开音视频通话的事件
- (void)onAVMemberLeft:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    [self.tabBarController.talksController handleAVMemberLeft:callId fromUid:fromUid];
}

//被邀请加入视频通话的事件
- (void)onAVRequest:(uint64_t)callId fromUid:(uint64_t)fromUid includeVideo:(BOOL)includeVideo
{
    [self.tabBarController.talksController handleAVRequest:callId fromUid:fromUid includeVideo:includeVideo];
}

//对方接受视频通话邀请的事件
- (void)onAVAccept:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    [self.tabBarController.talksController handleAVAccept:callId fromUid:fromUid];
}

//邀请视频通话超时的事件
- (void)onAVTimeout:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    [self.tabBarController.talksController handleAVTimeout:callId fromUid:fromUid];
}

//对方拒绝视频通话邀请的事件
- (void)onAVReject:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    [self.tabBarController.talksController handleAVReject:callId fromUid:fromUid];
}

//视频通话结束的事件
- (void)onAVClose:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    [self.tabBarController.talksController handleAVClose:callId fromUid:fromUid];
}

//接收到第一个数据帧
- (void)onAVRecevieFirstFrame:(uint64_t)callId
{
    [self.tabBarController.talksController handleAVRecevieFirstFrame:callId];
}

@end
