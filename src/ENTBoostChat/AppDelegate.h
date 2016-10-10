//
//  AppDelegate.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-2.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogonViewController.h"
#import "ENTBoost.h"

#define EBCHAT_AUTO_LOGON_ENABLED @"key_auto_logon_enabled"
#define EBCHAT_ESRVER_ADDRESS_KEY @"key_server_address"

@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ENTBoostKitDelegate>

@property(strong, nonatomic) UIWindow *window;

@property(strong, nonatomic) UIViewController          *splashScreenController;     //启动图控制器
@property(strong, nonatomic) LogonViewController       *logonViewController;        //登录页控制器
@property (strong, nonatomic) MainViewController     *tabBarController;           //tabBar控制器
@property(strong, nonatomic) UINavigationController    *mainNavigationController;   //主导航栏控制器

@property(strong, atomic) NSDate *lastLocalNotificationTime; //上一次本地通知发生时间

@property(strong, nonatomic) NSString *buildNo; //打包版本

/**本地存储数据
 * @param data 数据，可以存储的数据类型包括：NSData、NSString、NSNumber、NSDate、NSArray、NSDictionary
 * @param key 唯一关键字
 */
- (void)saveData:(id)data forKey:(NSString*)key;

/**读取本地存储的数据
 * @param key 唯一关键字
 * @return data 数据，读取的数据类型可能是：NSData、NSString、NSNumber、NSDate、NSArray、NSDictionary
 */
- (id)dataForKey:(NSString*)key;

/**重置应用状态
 * 用于设置服务器连接地址后
 * @param serverAddress 服务器连接地址
 */
- (void)resetApplicationWithServerAddress:(NSString*)serverAddress;

///产生本地通知
- (void)addLocalNotification;

@end
