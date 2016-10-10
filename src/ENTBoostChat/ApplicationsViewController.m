//
//  ApplicationsViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-10-15.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "ApplicationsViewController.h"
#import "ApplicationViewController.h"
#import "MainViewController.h"
#import "ENTBoostChat.h"
#import "ENTBoost.h"
#import "CustomSeparator.h"
#import "ApplicationsCell.h"
#import "BlockUtility.h"
#import "FileUtility.h"
#import "ENTBoost+Utility.h"
#import "ResourceKit.h"

@interface ApplicationsViewController ()
{
    UIStoryboard* _appStoryboard;
}

//应用功能Controller缓存
@property(nonatomic, strong) NSMutableDictionary* appViewControllers;
//应用功能列表
@property(nonatomic, strong) NSArray* subscribeFuncInfos;

@end

@implementation ApplicationsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        //注册接收通知：显示应用界面
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:EBCHAT_NOTIFICATION_SHOW_APPLICATION object:nil];
        
        _appStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_APP bundle:nil];
        self.appViewControllers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //获取应用参数
    [self fetchSubscribeFuncInfos];
}

- (void)viewDidAppear:(BOOL)animated
{
//    //设置分割线
//    if (IOS7)
//        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
//    [self.tableView setSeparatorColor:[UIColor colorWithHexString:@"#c1dce5"]];
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //移除接收通知的注册
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EBCHAT_NOTIFICATION_SHOW_APPLICATION object:nil];
}

//获取应用参数
- (void)fetchSubscribeFuncInfos
{
    if (!self.subscribeFuncInfos.count) {
        //获取应用功能列表
        NSDictionary* subscribeFuncInfos = [[ENTBoostKit sharedToolKit] subscribeFuncInfos];
        //排序
        NSArray* keys = [subscribeFuncInfos keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            EBSubscribeFuncInfo* sFuncInfo1 = obj1;
            EBSubscribeFuncInfo* sFuncInfo2 = obj2;
            if (sFuncInfo1.index > sFuncInfo2.index)
                return NSOrderedAscending;
            else if (sFuncInfo1.index < sFuncInfo2.index)
                return NSOrderedDescending;
            else
                return NSOrderedSame;
        }];
        
        NSMutableArray* tempSubscribeFuncInfos = [[NSMutableArray alloc] init];
        for (id key in keys) {
            [tempSubscribeFuncInfos addObject:subscribeFuncInfos[key]];
        }
        self.subscribeFuncInfos = tempSubscribeFuncInfos;
    }
}

//处理显示应用界面的通知
- (void)handleNotification:(NSNotification*)notif
{
    uint64_t subId = [notif.userInfo[@"subId"] unsignedLongLongValue];
    EB_TALK_TYPE talkType = [notif.userInfo[@"type"] intValue];
    if (subId) {
        [self fetchSubscribeFuncInfos];
        for(EBSubscribeFuncInfo* sFuncInfo in self.subscribeFuncInfos) {
            if (sFuncInfo.subId == subId) {
                //识别广播消息和系统消息
                NSString* customParam;
                if(talkType==EB_TALK_TYPE_MY_MESSAGE)
                    customParam = @"&color=56bef5&tab_type=sys_msg";
                else if (talkType==EB_TALK_TYPE_BROADCAST_MESSAGE)
                    customParam = @"&color=56bef5&tab_type=bc_msg";
                else if (talkType==EB_TALK_TYPE_BROADCAST_MESSAGE_NEW_EMAIL) {
                    EBNotification* ebNotification = notif.userInfo[@"ebNotification"];
                    EBEmailDescription* emailDesc = [[EBEmailDescription alloc] initWithFormatedString:ebNotification.content1];
                    customParam = emailDesc.customParam.length>0?emailDesc.customParam:nil;//[NSString stringWithFormat:@"&%@", emailDesc.customParam];
                }
//                else if(talkType==EB_TALK_TYPE_BROADCAST_MESSAGE_EMAIL_COUNT) {
//                    
//                }
                
                //显示应用界面
                [self showApplication:sFuncInfo customParam:customParam];
                break;
            }
        }
    }
}

//显示应用界面
- (void)showApplication:(EBSubscribeFuncInfo*)sFuncInfo customParam:(NSString*)customParam
{
    ApplicationViewController* appViewController = self.appViewControllers[@(sFuncInfo.subId)];
    //如果不存在就创建一个
    if (!appViewController) {
        appViewController = [_appStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_APP_CONTROLLER];
        //        self.appViewControllers[@(sFuncInfo.subId)] = appViewController;
        appViewController.subscribeFuncInfo = sFuncInfo;
        appViewController.subscribeFuncUrl = [ENTBoostKit sharedToolKit].subscribeFuncUrl;
        appViewController.customParam = customParam;
    }
    
    switch (sFuncInfo.funcMode) {
        //使用外部浏览器访问
        case EB_FUNC_MODE_BROWSER:
        {
            NSString* url = [[appViewController generateUrl] URLEncodedString];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
            break;
        //使用内嵌浏览器访问
        case EB_FUNC_MODE_MAINFRAME:
        case EB_FUNC_MODE_WINDOW:
        case EB_FUNC_MODE_MODAL:
        {
            [self.navigationController pushViewController:appViewController animated:YES];
        }
            break;
        //暂不支持
        case EB_FUNC_MODE_PROGRAM:
        case EB_FUNC_MODE_SERVER:
            break;;
    }
//    //切换至应用页面
//    [self.tabBarController setSelectedViewController:self.parentViewController];
//    
//    //如果在导航视图中该TalkView聊天界面没有显示，就使它显示
//    if(![[self.navigationController topViewController] isEqual:appViewController]) {
//        [self.navigationController popToRootViewControllerAnimated:NO];
//        [self.navigationController pushViewController:appViewController animated:YES];
//    }
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([ENTBoostKit sharedToolKit].accountInfo.isVisitor)
        return 0;
    
    return self.subscribeFuncInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ApplicationsCell";
    ApplicationsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
//    if (IOS7)
//        cell.backgroundColor = [UIColor colorWithHexString:@"#EFFAFE"];
//    else {
//        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
//        backgrdView.backgroundColor = [UIColor colorWithHexString:@"#EFFAFE"];
//        cell.backgroundView = backgrdView;
//    }
    
    EBSubscribeFuncInfo* sFuncInfo = self.subscribeFuncInfos[indexPath.row];
    cell.customTextLabel.text = sFuncInfo.funcName;
    cell.customDetailTextLabel.text = nil;
    if (indexPath.row==0)
        cell.hiddenCustomSeparatorTop = NO; //显示顶部分隔线
    
    //从程序包获取接入应用对应的图标
    UIImage* image = [ResourceKit imageOf3rdApplicationWithSubId:sFuncInfo.subId];
    
    if (image) {
        cell.customImageView.image = image;
    } else {
        //检查在服务端是否有图标
        if (sFuncInfo.iconResId && sFuncInfo.iconMD5) {
            NSString* fileAbsolutePath = [NSString stringWithFormat:@"%@/%llu", [FileUtility ebChatCacheDirectory], sFuncInfo.iconResId];
            //检查已下载的图标文件是否存在和MD5码是否相等
            if ([FileUtility isEqualWithMD5:sFuncInfo.iconMD5 atPath:fileAbsolutePath]) {
                cell.customImageView.image = [UIImage imageWithContentsOfFile:fileAbsolutePath];
            } else { //没有下载文件
                if (sFuncInfo.iconUrl) {
                    //后台异步加载图标
                    [BlockUtility performBlockInGlobalQueue:^{
                        //远程下载文件
                        NSURL* imageUrl = [NSURL URLWithString:sFuncInfo.iconUrl];
                        NSData* data = [NSData dataWithContentsOfURL:imageUrl];
                        if (data) {
                            [FileUtility deleteFileAtPath:fileAbsolutePath]; //删除旧文件
                            [FileUtility writeFileAtPath:fileAbsolutePath data:data]; //写入本地文件
                            //界面显示图标
                            UIImage* image = [UIImage imageWithData:data];
                            [BlockUtility performBlockInMainQueue:^{
                                cell.customImageView.image = image;
                            }];
                        } else {
                            [ResourceKit show3rdApplicationHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
                        }
                    }];
                } else {
                    [ResourceKit show3rdApplicationHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
                }
            }
        } else {
            [ResourceKit show3rdApplicationHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

#define HEIGHT_FOR_HEADER_FOOTER 20.0f

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEIGHT_FOR_HEADER_FOOTER;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, HEIGHT_FOR_HEADER_FOOTER)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return HEIGHT_FOR_HEADER_FOOTER;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, HEIGHT_FOR_HEADER_FOOTER)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EBSubscribeFuncInfo* sFuncInfo = self.subscribeFuncInfos[indexPath.row];
    if (sFuncInfo)
        [self showApplication:sFuncInfo customParam:nil];
}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

@end
