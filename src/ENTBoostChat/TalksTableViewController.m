//
//  TalksTableViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-2.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "TalksTableViewController.h"
#import "TalkViewController.h"
#import "MainViewController.h"
#import "SeedUtility.h"
#import "BlockUtility.h"
#import "TalksCell.h"
#import "TableTreeNode.h"
#import "AppDelegate.h"
#import "ENTBoost+Utility.h"
#import "PublicUI.h"
#import "ButtonKit.h"
#import "ResourceKit.h"
#import "MJRefresh.h"
#import "ControllerManagement.h"
#import "FilesBrowserController.h"
#import "SearchPersonController.h"
#import "GroupInformationViewController.h"
#import "UserInformationViewController.h"
#import "ApplicationViewController.h"

@interface TalksTableViewController ()
{
    UIStoryboard* _talkStoryobard;
    UIStoryboard* _otherStoryboard;
}

@property(nonatomic, strong) NSMutableDictionary* lastMessagesOfTalkIds; //各talk最新一条聊天记录缓存
@property(nonatomic, strong) NSMutableDictionary* headPhotoLoadedCache; //记录Talk加载头像情况

@end

@implementation TalksTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.p2pTalkViewControllesrs            = [[NSMutableDictionary alloc] init];
        self.groupTalkViewControllers           = [[NSMutableDictionary alloc] init];
        self.notificationTalkViewControllers    = [[NSMutableDictionary alloc] init];
        self.talkIds = [[NSMutableArray alloc] init];
        self.lastMessagesOfTalkIds = [[NSMutableDictionary alloc] init];
        self.headPhotoLoadedCache = [[NSMutableDictionary alloc] init];
        
        _talkStoryobard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_TALK bundle:nil];
        _otherStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_OTHER bundle:nil];
        
        //注册接收通知：显示对话界面
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTalk:) name:EBCHAT_NOTIFICATION_RELATIONSHIP_DIDSELECT object:nil]; //来源于联系人界面
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTalk:) name:EBCHAT_NOTIFICATION_APPLICATION_DIDSELECT object:nil]; //来源于应用界面
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTalk:) name:EBCHAT_NOTIFICATION_SHOW_TALK object:nil]; //来源于用户(群组)属性界面
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browseFolder:) name:EBCHAT_NOTIFICATION_BROWSE_FOLDER object:nil]; //浏览文件目录界面
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)configureNavigationBar:(UINavigationItem*)navigationItem
{
//    navigationItem.title = @"聊天";
    
    //右边按钮1
//    UIButton* btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 24)];
//    [btn1 setImage:[UIImage imageNamed:@"navigation_search"] forState:UIControlStateNormal];
//    [btn1 addTarget:self action:@selector(searchMenu) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem * rightButton1 = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:nil action:nil];
//    rightButton1.customView = btn1;
    UIBarButtonItem * rightButton1 = [ButtonKit searchBarButtonWithTarget:self action:@selector(searchMenu)];
    
    //右边按钮2
//    UIButton* btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 24)];
//    [btn2 setImage:[UIImage imageNamed:@"navigation_menu"] forState:UIControlStateNormal] ;
//    [btn2 addTarget:self action:@selector(popupMenu) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem * rightButton2 = [[UIBarButtonItem alloc] initWithTitle:@"下拉菜单" style:UIBarButtonItemStylePlain target:nil action:nil];
//    rightButton2.customView = btn2;
    UIBarButtonItem * rightButton2 = [ButtonKit popMenuBarButtonWithTarget:self action:@selector(popupMenu)];
    
    navigationItem.rightBarButtonItems = @[rightButton2, rightButton1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //置空背景图
    [self.tableView setBackgroundView:nil];
    
    //查询获取对话归类
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    NSArray* talks = [ebKit talks];
    
    for (EBTalk* talk in talks) {
        //获取该Talk的聊天记录数量
//        NSUInteger msgCount = [ebKit countOfMessagesWithTalkId:talk.talkId andBeginTime:nil endTime:nil];
//        if(!msgCount) {
//            NSLog(@"no message, miss to create TalkViewController,  talkId = %@", talk.talkId);
//            continue;
//        }
        NSUInteger index = 0;
        BOOL bAdded = [self addTalkId:talk.talkId append:YES index:&index];
        
        //如果成功加入，就生成对应界面
        if(bAdded)
            [self createTalkViewControllerWithTalk:talk];
    }
    
    //加入下拉刷新功能
    [self setupRefresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self updateBadgeValue];    //更新TabBar、应用图标右上角提醒内容
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc
{
    //移除接收通知的注册
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EBCHAT_NOTIFICATION_RELATIONSHIP_DIDSELECT object:nil]; //来源于联系人界面
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EBCHAT_NOTIFICATION_APPLICATION_DIDSELECT object:nil]; //来源于应用界面
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EBCHAT_NOTIFICATION_SHOW_TALK object:nil]; //来源于用户(群组)属性界面
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EBCHAT_NOTIFICATION_BROWSE_FOLDER object:nil]; //浏览文件目录界面
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing) viewHeight:-1.0 clipsToBounds:NO];
    
    // 设置文字
    self.tableView.headerPullToRefreshText = @"下拉刷新聊天列表";
    self.tableView.headerReleaseToRefreshText = @"松开马上刷新";
    self.tableView.headerRefreshingText = @"加载中,请稍后...";
}

//执行刷新动作
- (void)headerRereshing
{
//    // 查询数据
//    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
//    NSArray* messages;
//    
//    if(self.messages.count>0) {
//        EBMessage* message;
//        
//        if ([[self.messages objectAtIndex:0] isMemberOfClass:[EBMessage class]])
//            message = [self.messages objectAtIndex:0];
//        else if (self.messages.count>1 && [[self.messages objectAtIndex:1] isMemberOfClass:[EBMessage class]])
//            message = [self.messages objectAtIndex:1];
//        
//        if (message)
//            messages = [ebKit messagesFromLastMessageId:message.msgId orderByTimeAscending:NO perPageSize:EB_CHAT_PER_PAGE_SIZE];
//    } else {
//        messages = [ebKit messagesWithTalkId:self.talkId andBeginTime:nil endTime:nil perPageSize:EB_CHAT_PER_PAGE_SIZE currentPage:1 orderByTimeAscending:NO];
//    }
//    
//    NSUInteger endIndex = messages.count-1;
//    
//    // 加入到聊天界面中
//    if (messages && messages.count>0) {
//        //检测缓存内第一条记录是否时间戳，如果是则删除它
//        if (self.messages.count>0) {
//            id obj = self.messages[0];
//            if (![obj isMemberOfClass:[EBMessage class]]) {
//                endIndex++;
//                [self.messages removeObjectAtIndex:0];
//                [self.talkTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//            }
//        }
//        
//        //加入缓存队列
//        [self addMessages:messages append:NO noUpdateView:NO];
//        //更新时间戳显示
//        [self refreshMessageTimestampAtStartIndex:0 endIndex:endIndex noUpdateView:NO];
//    }
    
    [self.tableView reloadData];
    
    //调用endRefreshing可以结束刷新状态
    [self.tableView headerEndRefreshing];
}

- (void)searchMenu
{
    [[PublicUI sharedInstance] searchMenuInViewController:self];
}

//弹出菜单
- (void)popupMenu
{
    [[PublicUI sharedInstance] popupNavigationMenuInView:self.view];
}

//浏览文件目录
- (void)browseFolder:(NSNotification*)notif
{
    FilesBrowserController* vc = [_otherStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_FILES_CONTROLLER];
    vc.actionType = FilesBrowserActionTypeOpen;
    
    [self.navigationController pushViewController:vc animated:YES];
//    [self.tabBarController setSelectedViewController:self.navigationController];
}

//创建talk controller
- (TalkViewController*)createTalkViewControllerWithTalk:(EBTalk*)talk
{
    TalkViewController* tvc = [_talkStoryobard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_TALK_CONTROLLER];
    tvc.talksController = self;
    tvc.talkId = talk.talkId;
    //加入界面缓存
    if (talk.type==EB_TALK_TYPE_CHAT) {
        //群组聊天
        if (talk.isGroup) {
            tvc.depCode = talk.depCode;
//            tvc.depName = talk.depName;
            //获取部门或群组资料
            if (!tvc.groupInfo)
                tvc.groupInfo = [[ENTBoostKit sharedToolKit] groupInfoWithDepCode:tvc.depCode];
            
            self.groupTalkViewControllers[@(talk.depCode)] = tvc;
        } else { //一对一聊天
            tvc.otherUid = talk.otherUid;
            tvc.otherAccount = talk.otherAccount;
            tvc.otherUserName = talk.otherUserName;
            //                tvc.otherEmpCode = talk.otherEmpCode;
            
            self.p2pTalkViewControllesrs[@(talk.otherUid)] = tvc;
        }
    } else {
        self.notificationTalkViewControllers[talk.talkId] = tvc;
    }
    
    tvc.headPhotoFilePath = talk.iconFile;
    
    return tvc;
}

//处理接收显示聊天界面的通知
- (void)showTalk:(NSNotification*)notif
{
    __block BOOL needCall = NO;
    __block uint64_t otherUid = 0;
    __block NSString* otherAccount;
    __block NSString* otherUserName;
    __block uint64_t otherEmpCode = 0;
    uint64_t depCode = 0;
    NSDictionary* userInfo = notif.userInfo;
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    
    if (userInfo[@"node"]) { //联系人
        needCall = YES;
        TableTreeNode* node = notif.userInfo[@"node"];
        RELATIONSHIP_TYPE type = ((NSNumber*)node.data[@"type"]).shortValue;
        
        switch (type) {
            case RELATIONSHIP_TYPE_MYDEPARTMENT: //我的部门
            case RELATIONSHIP_TYPE_ENTGROUP: //部门
            case RELATIONSHIP_TYPE_PERSONALGROUP: //个人群组
            {
                EBGroupInfo* groupInfo = node.data[@"groupInfo"];
                depCode = groupInfo.depCode;
            }
                break;
            case RELATIONSHIP_TYPE_MEMBER: //部门或群组成员
            {
                EBMemberInfo* memberInfo = node.data[@"memberInfo"];
                otherUid = memberInfo.uid;
                otherAccount = memberInfo.empAccount;
                otherUserName = memberInfo.userName;
                otherEmpCode = memberInfo.empCode;
            }
                break;
            case RELATIONSHIP_TYPE_CONTACT: //通讯录中的联系人
            {
                EBContactInfo* contactInfo = node.data[@"contactInfo"];
                //联系人是本系统的用户才可以聊天
                if (contactInfo.uid) {
                    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
                    [ebKit queryAccountInfoWithVirtualAccount:[NSString stringWithFormat:@"%llu", contactInfo.uid] onCompletion:^(uint64_t uid, NSString* account) {
                        otherUid = uid;
                        otherAccount = account;
                        dispatch_semaphore_signal(sem);
                    } onFailure:^(NSError *error) {
                        NSLog(@"查询联系人失败, code = %li, msg = %@", (long)error.code, error.localizedDescription);
                        needCall = NO;
                        dispatch_semaphore_signal(sem);
                    }];
                    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 5.0f * NSEC_PER_SEC)); //最长等待5秒
                    otherUserName = contactInfo.name;
                } else {
                    needCall = NO;
                }
            }
            default:
                break;
        }
    } else if (userInfo[@"ebim-tag"]) { //应用标签
        needCall = YES;
        if (userInfo[@"account"]) { //单聊
            NSString* virtualAccount = userInfo[@"account"];
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            
            [ebKit queryUserInfoWithVirtualAccount:virtualAccount onCompletion:^(uint64_t uid, NSString *account, EBVCard *vCard) {
                otherUid = uid;
                otherAccount = account;
                otherUserName = vCard.name;
                dispatch_semaphore_signal(sem);
            } onFailure:^(NSError *error) {
                NSLog(@"查询联系人失败, code = %@, msg = %@", @(error.code), error.localizedDescription);
                needCall = NO;
                dispatch_semaphore_signal(sem);
            }];
            dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 5.0f * NSEC_PER_SEC)); //最长等待5秒
        } else if (userInfo[@"depCode"]) { //群聊
            depCode = [userInfo[@"depCode"] unsignedLongLongValue];
        }
    } else if (userInfo[@"informationType"]) { //用户(群组)属性页面 或其它来源
        needCall = YES;
        
        NSString* informationType = userInfo[@"informationType"];
        if ([informationType isEqualToString:@"USER"]) { //一对一会话
            otherUid = [userInfo[@"otherUid"] unsignedLongLongValue];
            otherAccount = userInfo[@"otherAccount"];
            otherUserName = userInfo[@"otherUserName"];
            otherEmpCode = [userInfo[@"otherEmpCode"] unsignedLongLongValue]; //可能是0
            depCode = [userInfo[@"depCode"] unsignedLongLongValue]; //可能是0
        } else if ([informationType isEqualToString:@"GROUP"]) { //群组(部门)会话
            depCode = [userInfo[@"depCode"] unsignedLongLongValue];
        }
    }
    
    if (needCall) {
        if (!otherUid && !depCode) {
            if (!otherAccount) {
                NSLog(@"uid 和 depCode都等于0，otherAccount等于nil，没有对话目标");
                return;
            }
            
            __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            [ebKit queryAccountInfoWithVirtualAccount:otherAccount onCompletion:^(uint64_t uid, NSString *account) {
                otherUid = uid;
                otherAccount = account;
                dispatch_semaphore_signal(sem);
            } onFailure:^(NSError *error) {
                NSLog(@"showTalk->queryAccountInfoWithVirtualAccount:%@ error, code = %@, msg = %@", otherAccount, @(error.code), error.localizedDescription);
                dispatch_semaphore_signal(sem);
            }];
            long result = dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 3.0f * NSEC_PER_SEC));
            
            if (!otherUid || result) {
                NSLog(@"没有找到对话目标:%@", otherAccount);
                return;
            }
        }
        
        if (otherUid == ebKit.accountInfo.uid) {
            NSLog(@"不能与自己进行对话");
            return;
        }
        
        NSLog(@"showTalk otherAccount = %@", otherAccount);
        
        __weak typeof(self) safeSelf = self;
            [self createOrUpdateTalkViewControllerWithOtherUid:otherUid otherAccount:otherAccount otherUserName:otherUserName otherEmpCode:otherEmpCode depCode:depCode noMessageShow:YES forceUpdateTalk:YES onCompletion:^(TalkViewController *tvc) {
                [BlockUtility performBlockInMainQueue:^{
                    [safeSelf showTalkViewController:tvc];
//                    //尝试让会话进入就绪状态
//                    BOOL waittingResult, result;
//                    [tvc detectAndLaunchCallWithWaitting:&waittingResult result:&result forMessage:nil];
//                    
//                    //判断在导航视图中该TalkView聊天界面没有显示
//                    BOOL isExist = NO;
//                    for (UIViewController* tmpVc in safeSelf.navigationController.viewControllers) {
//                        if (tmpVc == tvc) {
//                            isExist = YES;
//                            break;
//                        }
//                    }
//                    
//                    //如果没有显示，就显示出来
//                    if(isExist) {
//                        [safeSelf.navigationController popToViewController:tvc animated:YES];
//                    } else
//                        [safeSelf.navigationController pushViewController:tvc animated:YES];
                }];
            } onFailure:^(NSError *error) {
                NSLog(@"创建或更新Talk失败，code = %li, msg = %@", (long)error.code, error.localizedDescription);
            }];
    }
}


/**把talkId加入到显示队列中
 * @param talkId talk编号
 * @param append 是否追加在最后，YES=追加在最后，NO=插入在第一位置
 * @param pIndex 输出参数，当talkId已存在时的索引位置
 * @return 是否成功加入, 如有重复将不能加入
 */
- (BOOL)addTalkId:(NSString*)talkId append:(BOOL)append index:(NSUInteger*)pIndex
{
    __block BOOL isEqual = NO;
    for (NSUInteger i=0; i<self.talkIds.count; i++) {
        NSString* value = self.talkIds[i];
        if([talkId isEqualToString:value]) {
            isEqual = YES;
            *pIndex = i;
            break;
        }
    }
    
    if(!isEqual) {
        if (append)
            [self.talkIds addObject:talkId];
        else
            [self.talkIds insertObject:talkId atIndex:0];
       
        return YES;
    }
    
    return NO;
}

//创建或更新聊天界面对象
- (void)createOrUpdateTalkViewControllerWithOtherUid:(uint64_t)otherUid otherAccount:(NSString*)otherAccount otherUserName:(NSString*)otherUserName otherEmpCode:(uint64_t)otherEmpCode depCode:(uint64_t)depCode noMessageShow:(BOOL)forceShow forceUpdateTalk:(BOOL)forceUpdateTalk onCompletion:(void(^)(TalkViewController* tvc))completionBlock onFailure:(void(^)(NSError *error))failureBlock
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    __block TalkViewController* tvc;
    __block EBTalk* talk;
    __weak typeof(self)safeSelf = self;
    
    
    void(^block)(void) = ^{
        //非强制显示时，需检查是否存在聊天记录后，决定是否显示界面
        if(!forceShow) {
            //获取聊天记录数量
            NSUInteger msgCount = [ebKit countOfMessagesWithTalkId:talk.talkId andBeginTime:nil endTime:nil];
            if(!msgCount) {
                NSLog(@"no message, miss to create TalkViewController,  talkId = %@", talk.talkId);
                return;
            }
        }
        
        //查找已有会话
        if (depCode)
            tvc = safeSelf.groupTalkViewControllers[@(depCode)];
        else
            tvc = safeSelf.p2pTalkViewControllesrs[@(otherUid)];
        
        //插入到显示队列最前面
        NSUInteger index = 0;
        BOOL bAdded = [safeSelf addTalkId:talk.talkId append:NO index:&index];
        
        if(bAdded) { //成功加入，生成聊天界面
            if(!tvc) {
                tvc = [safeSelf createTalkViewControllerWithTalk:talk];
                tvc.otherUserName = talk.otherUserName;
            }
            
            [safeSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } else { //已存在，刷新列表
            [safeSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        if (completionBlock)
            completionBlock(tvc);
    };
    
    
    if(depCode) { //群组会话
        talk = [ebKit talkWithDepCode:depCode]; //获取对应的talk
        if (!talk) { //talk不存在
            [ebKit insertOrUpdateTalkWithDepCode:depCode onCompletion:^(EBTalk *newTalk) {
                talk = newTalk;
                [BlockUtility performBlockInMainQueue:block];
            } onFailure:^(NSError *error) {
                NSLog(@"createOrUpdateTalkViewControllerWithOtherUid error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
                if (failureBlock)
                    failureBlock(error);
            }];
        } else { //talk存在
            if (forceUpdateTalk) { //强制更新talk会话
                [ebKit insertOrUpdateTalkWithDepCode:depCode onCompletion:^(EBTalk *newTalk) {
                    talk = newTalk;
                    [BlockUtility performBlockInMainQueue:block];
                } onFailure:^(NSError *error) {
                    NSLog(@"createOrUpdateTalkViewControllerWithOtherUid error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
                    if (failureBlock)
                        failureBlock(error);
                }];
            } else {
                [BlockUtility performBlockInMainQueue:block];
            }
        }
    } else { //一对一会话
        talk = [ebKit talkWithUid:otherUid]; //获取对应的Talk
        if (!talk) {
            //新建或更新Talk
            [ebKit insertOrUpdateTalkWithUid:otherUid otherAccount:otherAccount otherUserName:otherUserName otherEmpCode:0 onCompletion:^(EBTalk *newTalk) {
                talk = newTalk;
                [BlockUtility performBlockInMainQueue:block];
            } onFailure:^(NSError *error) {
                NSLog(@"createOrUpdateTalkViewControllerWithOtherUid error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
                if (failureBlock)
                    failureBlock(error);
            }];
        } else { //talk存在
            if (forceUpdateTalk) { //强制更新talk会话
                //新建或更新Talk
                [ebKit insertOrUpdateTalkWithUid:otherUid otherAccount:otherAccount otherUserName:otherUserName otherEmpCode:0 onCompletion:^(EBTalk *newTalk) {
                    talk = newTalk;
                    [BlockUtility performBlockInMainQueue:block];
                } onFailure:^(NSError *error) {
                    NSLog(@"createOrUpdateTalkViewControllerWithOtherUid error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
                    if (failureBlock)
                        failureBlock(error);
                }];
            } else {
                [BlockUtility performBlockInMainQueue:block];
            }
        }
    }
    
    /*
    if(depCode) { //群组会话
        void(^block)(void) = ^{
            //非强制显示时，需检查是否存在聊天记录才显示界面
            if(!forceShow) {
                //获取该对话归类下聊天记录数量
                NSUInteger msgCount = [ebKit countOfMessagesWithTalkId:talk.talkId andBeginTime:nil endTime:nil];
                if(!msgCount) {
                    NSLog(@"no message, miss to create TalkViewController,  talkId = %@", talk.talkId);
                    return;
                }
            }
            
            //查找已有会话
            NSNumber* key = @(depCode);
            tvc = safeSelf.groupTalkViewControllers[key];
            
            //插入到显示队列最前面
            NSUInteger index = 0;
            BOOL bAdded = [safeSelf addTalkId:talk.talkId append:NO index:&index];
            
            if(bAdded) { //成功加入，生成聊天界面
                if(!tvc)
                    tvc = [safeSelf createTalkViewControllerWithTalk:talk];
                
                [safeSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            } else { //已存在，刷新列表
                [safeSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if (completionBlock)
                completionBlock(tvc);
        };
        
        //获取对应的talk
        talk = [ebKit talkWithDepCode:depCode];
        if (!talk) { //talk不存在
            [ebKit insertOrUpdateTalkWithDepCode:depCode onCompletion:^(EBTalk *newTalk) {
                talk = newTalk;
                [BlockUtility performBlockInMainQueue:block];
            } onFailure:^(NSError *error) {
                NSLog(@"createOrUpdateTalkViewControllerWithOtherUid error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
                if (failureBlock) failureBlock(error);
            }];
        } else { //talk存在
            if (forceUpdateTalk) { //强制更新talk会话
                [ebKit insertOrUpdateTalkWithDepCode:depCode onCompletion:^(EBTalk *newTalk) {
                    talk = newTalk;
                    [BlockUtility performBlockInMainQueue:block];
                } onFailure:^(NSError *error) {
                    NSLog(@"createOrUpdateTalkViewControllerWithOtherUid error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
                    if (failureBlock) failureBlock(error);
                }];
            } else {
                [BlockUtility performBlockInMainQueue:block];
            }
        }
    } else { //一对一会话
        void(^block)(void) = ^{
            //非强制显示时，需检查是否存在聊天记录才显示界面
            if(!forceShow) {
                //获取该对话归类下聊天记录数量
                NSUInteger msgCount = [ebKit countOfMessagesWithTalkId:talk.talkId andBeginTime:nil endTime:nil];
                if(!msgCount) {
                    NSLog(@"no message, miss to create TalkViewController,  talkId = %@", talk.talkId);
                    return;
                }
            }
            
            //查找已有会话
            NSNumber* key = @(otherUid);
            tvc = safeSelf.p2pTalkViewControllesrs[key];
            
            //插入到显示队列最前面
//            BOOL bAdded = [safeSelf addTalkId:talk.talkId append:NO];
            NSUInteger index = 0;
            BOOL bAdded = [safeSelf addTalkId:talk.talkId append:NO index:&index];
            
            if(bAdded) { //成功加入，生成聊天界面
                if(!tvc)
                    tvc = [safeSelf createTalkViewControllerWithTalk:talk];
                tvc.otherUserName = talk.otherUserName; //更新信息
//            if (otherEmpCode)
//                tvc.otherEmpCode = otherEmpCode;
                
                [safeSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            } else { //已存在，刷新列表
                [safeSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if (completionBlock)
                completionBlock(tvc);
        };
        
        //获取对应的Talk
        talk = [ebKit talkWithUid:otherUid];
        if (!talk) {
            //新建或更新Talk
            [ebKit insertOrUpdateTalkWithUid:otherUid otherAccount:otherAccount otherUserName:otherUserName otherEmpCode:0 onCompletion:^(EBTalk *newTalk) {
                talk = newTalk;
                [BlockUtility performBlockInMainQueue:block];
            } onFailure:^(NSError *error) {
                NSLog(@"createOrUpdateTalkViewControllerWithOtherUid error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
                if (failureBlock)
                    failureBlock(error);
            }];
        } else {
            if (forceUpdateTalk) { //强制更新talk会话
                //新建或更新Talk
                [ebKit insertOrUpdateTalkWithUid:otherUid otherAccount:otherAccount otherUserName:otherUserName otherEmpCode:0 onCompletion:^(EBTalk *newTalk) {
                    talk = newTalk;
                    [BlockUtility performBlockInMainQueue:block];
                } onFailure:^(NSError *error) {
                    NSLog(@"createOrUpdateTalkViewControllerWithOtherUid error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
                    if (failureBlock)
                        failureBlock(error);
                }];
            } else {
                [BlockUtility performBlockInMainQueue:block];
            }
        }
    }*/
}

- (void)dispatchReceviedMessage:(EBMessage*)message ackBlock:(EB_RECEIVE_FILE_ACK_BLOCK)ackBlock cancelBlock:(EB_RECEIVE_FILE_CANCEL_BLOCK)cancelBlock
{
    __weak typeof(self) safeSelf = self;
    
    EBCallInfo* callInfo = [[ENTBoostKit sharedToolKit] callInfoWithCallId:message.callId];
    uint64_t otherUid = callInfo.isGroupCall?0:callInfo.onePerson.uid;
    NSString* otherAccount = callInfo.isGroupCall?nil:callInfo.onePerson.account;
    NSString* otherUserName = callInfo.isGroupCall?nil:callInfo.onePerson.vCard.name;
    uint64_t otherEmpCode = callInfo.isGroupCall?0:callInfo.onePerson.vCard.empCode;
    
    NSLog(@"dispatchReceviedMessage otherAccount = %@", otherAccount);
    [self createOrUpdateTalkViewControllerWithOtherUid:otherUid otherAccount:otherAccount otherUserName:otherUserName otherEmpCode:otherEmpCode depCode:callInfo.depCode noMessageShow:NO forceUpdateTalk:NO onCompletion:^(TalkViewController *tvc) {
        //创建或更新聊天界面对象
        [BlockUtility performBlockInMainQueue:^{
            //把响应block暂存
            if (ackBlock || cancelBlock) {
                NSMutableDictionary* blockDict = tvc.receiveFileBlockCache[@(message.msgId)] = [NSMutableDictionary dictionaryWithCapacity:2];
                if (ackBlock)
                    blockDict[RECEIVE_FILE_ACK_BLOCK_NAME] = ackBlock;
                if (cancelBlock)
                    blockDict[RECEIVE_FILE_CANCEL_BLOCK_NAME] = cancelBlock;
            }
            
            //调整Talks表视图显示顺序
            [safeSelf adjustTableViewWithTalkId:tvc.talkId];
            
            BOOL bAdded = NO;
            //聊天界面已经显示过才需要更新聊天界面
            if (!tvc.isFirstShow) {
                [tvc refreshLastMessageTimestamp]; //刷新最新一条信息时间戳
                bAdded = [tvc addMessages:@[message] append:YES noUpdateView:NO]; //在聊天界面中显示信息
            }
            
            if(/*bAdded*/YES) {
                [tvc scrollToBottom:YES]; //滚动到最后一行
                [tvc checkToUpdateMessagesReadedStateAndBadge]; //检测当前会话窗口并更新消息未读状态
                
                //播放提示音
                NSTimeInterval backgroundTimeRemaining = [[UIApplication sharedApplication] backgroundTimeRemaining];
                if (backgroundTimeRemaining == DBL_MAX) { //应用在前台
                    //聊天消息属于当前窗口播放轻声提示音
                    BOOL playedSoftlySound = NO;
                    if ([self.navigationController topViewController]==tvc) {
                        AudioServicesPlaySystemSound(1003);
                        playedSoftlySound = YES;
                    }
//                    if ([self.tabBarController selectedViewController] == self.navigationController) { //选项卡当前选中的ViewController是否为本TalksTableViewController的导航控制器
//                        UIViewController* topViewController = [self.navigationController topViewController];
//                        if (topViewController == tvc) {  //该tvc是否处于最顶端
//                            AudioServicesPlaySystemSound(1003);
//                            playedSoftlySound = YES;
//                        }
//                    }
                    
                    //否则播放重声提示音
                    if (!playedSoftlySound) {
                        static NSDate* lastPlayTime;
                        NSDate* now = [NSDate date];
                        //从未播放或距离上次播放超过2秒，执行播放提示音
                        if (!lastPlayTime || [now timeIntervalSinceDate:lastPlayTime]>2.0) {
                            lastPlayTime = now;
                            AudioServicesPlaySystemSound(1007);
                        }
                    }
                } else { //应用在后台
                    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [appDelegate addLocalNotification];
                }
            }
            
            [self updateBadgeValue]; //更新TabBar和应用图标右上角提醒
        }];
    } onFailure:^(NSError *error) {
        
    }];
}

- (void)reloadRowWithTalkId:(NSString*)talkId
{
    __block NSInteger foundIdx = -1;
    [self.talkIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([talkId isEqualToString:(NSString*)obj]) {
            foundIdx = idx;
            *stop = YES;
        }
    }];
    
    //找到目标，重载指定行
    if (foundIdx != -1) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:foundIdx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)adjustTableViewWithTalkId:(NSString*)talkId
{
    //检查当前talk是否在显示队列的第一位,如不是就调整至第一位置
    __block NSInteger foundIdx = -1;
    [self.talkIds enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        if ([talkId isEqualToString:obj]) {
            foundIdx = idx;
            *stop = YES;
        }
    }];
    
    if (foundIdx > 0) { //已找到且不在第一位置
        //从旧位置删除
        [self.talkIds removeObjectAtIndex:foundIdx];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:foundIdx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
        //插入到第一位置
        [self.talkIds insertObject:talkId atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//        [self.tableView reloadData];
    } else if (foundIdx < 0) { //不存在
        [self.talkIds insertObject:talkId atIndex:0]; //插入到第一位置
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//        [self.tableView reloadData];
    }
}

- (void)updateBadgeValue
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    NSUInteger count1 = [ebKit countOfTalksHavingUnreadMessage];
    NSUInteger count2 = [ebKit countOfTalksHavingUnreadNotification];
    NSUInteger count = count1+count2;
    
    [self.tabBarController updateTabBarItemBadgeValue:count>0?[NSString stringWithFormat:@"%@", @(count)]:nil atIndex:0]; //更新TabBar图标右上角数字
    [UIApplication sharedApplication].applicationIconBadgeNumber = count>99?99:count; //更新应用图标右上角数字
    
}

//查询已缓存的TalkViewController
- (TalkViewController*)talkViewControllerWithTalk:(EBTalk*)talk
{
    __block TalkViewController* tvc;
    
    if (talk.type==EB_TALK_TYPE_CHAT) {
        if (!talk.isGroup) { //一对一会话缓存内查找
            [self.p2pTalkViewControllesrs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                TalkViewController* tmpTvc = obj;
                if([tmpTvc.talkId isEqualToString:talk.talkId]) {
                    tvc = obj;
                    *stop = YES;
                }
            }];
        } else { //群组会话内查找
            [self.groupTalkViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                TalkViewController* tmpTvc = obj;
                if([tmpTvc.talkId isEqualToString:talk.talkId]) {
                    tvc = obj;
                    *stop = YES;
                }
            }];
        }
    } else { //消息通知缓存内查找
        tvc = self.notificationTalkViewControllers[talk.talkId];
    }
    
    //不存在则创建
    if (!tvc)
        tvc = [self createTalkViewControllerWithTalk:talk];
    
    return tvc;
}

//检测界面是否已经显示
- (BOOL)isTalkViewControllerShowed:(TalkViewController*)tvc
{
    BOOL isExist = NO;
    NSArray* controllers = [self.navigationController viewControllers];
    for (UIViewController* tmpVC in controllers) {
        if (tmpVC==tvc) {
            isExist = YES;
            break;
        }
    }
    return isExist;
}

//显示聊天会话界面
- (void)showTalkViewController:(TalkViewController*)tvc
{
    if ([self isTalkViewControllerShowed:tvc]) {
        NSLog(@"当前会话界面已弹出");
        [self.navigationController popToViewController:tvc animated:YES];
        return;
    }
    
    //尝试让会话进入就绪状态
    BOOL waittingResult, result;
    [tvc detectAndLaunchCallWithWaitting:&waittingResult result:&result forMessage:nil];
    
    if (tvc.depCode) {
//        //获取部门或群组资料
//        if (!tvc.groupInfo)
//            tvc.groupInfo = [[ENTBoostKit sharedToolKit] groupInfoWithDepCode:tvc.depCode];
        
        //获取成员列表
        if (!tvc.memberInfoDict) {
            [[ENTBoostKit sharedToolKit] loadMemberInfosWithDepCode:tvc.depCode onCompletion:^(NSDictionary *memberInfos) {
                [BlockUtility performBlockInMainQueue:^{
                    tvc.memberInfoDict = [[NSMutableDictionary alloc] init];
                    for (EBMemberInfo* memberInfo in [memberInfos allValues])
                        tvc.memberInfoDict[@(memberInfo.uid)] = memberInfo;
                    
                    //进入聊天界面
                    [self.navigationController pushViewController:tvc animated:YES];
                }];
            } onFailure:^(NSError *error) {
                NSLog(@"loadMemberInfosWithDepCode:%llu, code = %@, msg = %@", tvc.depCode, @(error.code), error.localizedDescription);
            }];
        } else {
            [self.navigationController pushViewController:tvc animated:YES]; //进入聊天界面
        }
    } else {
        [self.navigationController pushViewController:tvc animated:YES]; //进入聊天界面
    }
}


#pragma mark - 处理登录流程事件
- (void)handleLogonCompletion:(EBAccountInfo *)accountInfo
{
    [BlockUtility performBlockInMainQueue:^{
        [self.p2pTalkViewControllesrs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            TalkViewController* tvc = obj;
            [tvc loadOnlineStateOfMembers:YES];
        }];
        
        [self.groupTalkViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            TalkViewController* tvc = obj;
            [tvc loadOnlineStateOfMembers:YES];
        }];
    }];
}


#pragma mark - 处理呼叫会话事件
- (void)handleCall:(const EBCallInfo*)callInfo callActionType:(CALL_ACTION_TYPE)callActionType
{
    switch (callActionType) {
        case CALL_ACTION_TYPE_CONNECTED: //会话就绪
        {
            uint64_t otherUid = callInfo.isGroupCall?0:callInfo.onePerson.uid;
            NSString* otherAccount = callInfo.isGroupCall?nil:callInfo.onePerson.account;
            NSString* otherUserName = callInfo.isGroupCall?nil:callInfo.onePerson.vCard.name;
            uint64_t otherEmpCode = callInfo.isGroupCall?0:callInfo.onePerson.vCard.empCode;
            
            NSLog(@"call_connected otherAccount = %@, isGroup = %i", otherAccount, callInfo.isGroupCall);
            [self createOrUpdateTalkViewControllerWithOtherUid:otherUid otherAccount:otherAccount otherUserName:otherUserName otherEmpCode:otherEmpCode depCode:callInfo.depCode noMessageShow:NO forceUpdateTalk:YES onCompletion:^(TalkViewController *tvc) {
            } onFailure:^(NSError *error) {
            }];
        }
            break;
        case CALL_ACTION_TYPE_BUSY: //对方忙，没有响应邀请
        {
            
            
        }
            break;
        case CALL_ACTION_TYPE_REJECT: //对方拒绝邀请
        {
            
        }
            break;
    }
}

- (void)handleCallHangup:(const EBCallInfo*)callInfo
{
    
}

- (void)handleCallAlerting:(const EBCallInfo*)callInfo toUid:(uint64_t)toUid
{
    
}

- (void)handleCallIncoming:(const EBCallInfo *)callInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard clientAddress:(NSString *)clientAddress
{
    NSLog(@"handleCallIncoming callId = %llu, fromUid = %llu, fromAccount = %@, userName = %@, clientAddress = %@", callInfo.callId, fromUid, fromAccount, vCard.name, clientAddress);
    //自动应答(待定)
    [[ENTBoostKit sharedToolKit] ackTheCall:callInfo.callId accept:YES onCompletion:^{
        NSLog(@"应答邀请成功, callId = %llu", callInfo.callId);
        //[self createOrUpdateTalkViewControllerWithCallInfo:callInfo]; //创建或更新聊天界面对象
    } onFailure:^(NSError *error) {
        NSLog(@"应答邀请失败, callId = %llu", callInfo.callId);
    }];
}

- (void)refreshEmotions:(NSArray *)expressions headPhotos:(NSArray *)headPhotos
{
    [BlockUtility performBlockInMainQueue:^{
        [self.p2pTalkViewControllesrs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            TalkViewController* tvc = obj;
            [tvc refreshStampInputView];
        }];
        
        [self.groupTalkViewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            TalkViewController* tvc = obj;
            [tvc refreshStampInputView];
        }];
    }];
}

#pragma mark - 处理常用事件

- (void)handleNewNotification:(EB_TALK_TYPE)type notiId:(uint64_t)notiId
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        [safeSelf updateNotificationCellWithType:type notiId:notiId];
        [safeSelf updateBadgeValue];
    }];
}

#pragma mark - 处理联系人、部门、群组变更通知事件
- (void)handleRequestToJoinGroup:(EBGroupInfo *)groupInfo description:(NSString *)description fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
//    [self updateNotificationCellWithType];
}

- (void)handleInvitedToJoinGroup:(uint64_t)depCode groupName:(NSString *)groupName description:(NSString *)description fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
//    [self updateNotificationCellWithType];
}

- (void)handleRejectToJoinGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
//    [self updateNotificationCellWithType];
}

- (void)handleAddMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        for (id key in safeSelf.groupTalkViewControllers) {
            TalkViewController* tvc = safeSelf.groupTalkViewControllers[key];
            if (tvc.depCode==groupInfo.depCode)
                [tvc addMemberInfo:memberInfo];
        }
    }];
}

- (void)handleUpdateMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        for (id key in safeSelf.p2pTalkViewControllesrs) {
            TalkViewController* tvc = safeSelf.p2pTalkViewControllesrs[key];
            if (tvc.otherUid==memberInfo.uid)
                [tvc updateMemberInfo:memberInfo];
        }
        for (id key in safeSelf.groupTalkViewControllers) {
            TalkViewController* tvc = safeSelf.groupTalkViewControllers[key];
            if (tvc.depCode==groupInfo.depCode)
                [tvc updateMemberInfo:memberInfo];
        }
    }];
}

- (void)handleDeleteGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    EBTalk* talk = [ebKit talkWithDepCode:groupInfo.depCode];
    if (talk) {
        //删除缓存的Talk
        [ebKit deleteTalkWithId:talk.talkId];
        
        //删除界面对应的聊天归类
        __weak typeof(self) safeSelf = self;
        [BlockUtility performBlockInMainQueue:^{
            //查找索引
            int index = -1;
            for (int i=0; i<safeSelf.talkIds.count; i++) {
                if ([talk.talkId isEqualToString:safeSelf.talkIds[i]]) {
                    index = i;
                    break;
                }
            }
            
            //执行删除
            if (index > -1) {
                [safeSelf.talkIds removeObjectAtIndex:index];
                [safeSelf.groupTalkViewControllers removeObjectForKey:@(groupInfo.depCode)];
                [safeSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
    }
}

- (void)handleAddTempGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    __weak typeof(self) safeSelf = self;
    [self createOrUpdateTalkViewControllerWithOtherUid:0 otherAccount:nil otherUserName:nil otherEmpCode:0 depCode:groupInfo.depCode noMessageShow:YES forceUpdateTalk:YES onCompletion:^(TalkViewController *tvc) {
        [BlockUtility performBlockInMainQueue:^{
            //尝试让会话进入就绪状态
            BOOL waittingResult, result;
            [tvc detectAndLaunchCallWithWaitting:&waittingResult result:&result forMessage:nil];
            
            //如果在导航视图中该TalkView聊天界面没有显示，就使它显示
            BOOL isExist = NO;
            for (UIViewController* vc in safeSelf.navigationController.viewControllers) {
                if ([vc isEqual:tvc]) {
                    isExist = YES;
                    break;
                }
            }
            if (isExist) {
                [safeSelf.navigationController popToViewController:tvc animated:YES];
            } else {
                [safeSelf.navigationController pushViewController:tvc animated:YES];
            }
            
//            if(![[safeSelf.navigationController topViewController] isEqual:tvc]) {
//                [safeSelf.navigationController popToRootViewControllerAnimated:NO];
//                
//                [safeSelf.navigationController pushViewController:tvc animated:YES];
//            }
            
//            //切换至聊天页
//            [safeSelf.tabBarController setSelectedViewController:safeSelf.parentViewController];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"创建或更新Talk失败，code = %li, msg = %@", (long)error.code, error.localizedDescription);
    }];
}

//更新动态通知
- (void)updateNotificationCellWithType:(EB_TALK_TYPE)talkType notiId:(uint64_t)notiId
{
    __weak typeof(self) safeSelf = self;
    NSArray* talks = [[ENTBoostKit sharedToolKit] talksWithType:talkType];
    if (talks.count > 0) {
        EBTalk* talk = talks[0];
//        talk.customData = @{@"notiId":@(notiId)};
        [BlockUtility performBlockInMainQueue:^{
            NSIndexPath* indexPathTop = [NSIndexPath indexPathForRow:0 inSection:0];
            NSArray* indexPaths0 = @[indexPathTop];
            
            NSUInteger index = 0;
            BOOL result = [safeSelf addTalkId:talk.talkId append:NO index:&index];
            if (result){ //已插入到最前端
                [safeSelf.tableView insertRowsAtIndexPaths:indexPaths0 withRowAnimation:UITableViewRowAnimationFade];
                [safeSelf.tableView reloadRowsAtIndexPaths:indexPaths0 withRowAnimation:UITableViewRowAnimationFade];
            } else { //已存在
                if (index!=0) {
                    //从非第一位移动到第一位
                    [safeSelf.tableView beginUpdates];
                    [safeSelf.talkIds removeObjectAtIndex:index];
                    [safeSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    [safeSelf.talkIds insertObject:talk.talkId atIndex:0];
                    [safeSelf.tableView insertRowsAtIndexPaths:indexPaths0 withRowAnimation:UITableViewRowAnimationFade];
                    [safeSelf.tableView endUpdates];
                    
                    //刷新视图
                    NSMutableArray* indexPaths = [NSMutableArray arrayWithCapacity:index];
                    for (int i=1; i<=index; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    [safeSelf.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                } else {
                    [safeSelf.tableView reloadRowsAtIndexPaths:indexPaths0 withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }];
    }
}

- (void)handleAddContactRequestFromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard description:(NSString *)description
{
//    [self updateNotificationCellWithType];
}

- (void)handleAddContactAccept:(EBContactInfo*)contactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount vCard:(EBVCard*)vCard
{
//    [self updateNotificationCellWithType];
}

- (void)handleAddContactRejectFromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard description:(NSString *)description
{
//    [self updateNotificationCellWithType];
}

- (void)handleUserChangeLineState:(EB_USER_LINE_STATE)userLineState fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount inEntGroups:(NSArray *)entGroupIds inPersonalGroups:(NSArray *)personalGroupIds
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        for (id key in safeSelf.p2pTalkViewControllesrs) {
            TalkViewController* tvc = safeSelf.p2pTalkViewControllesrs[key];
            [tvc updateUserLineState:userLineState fromUid:fromUid fromAccount:fromAccount];
        }
        for (id key in safeSelf.groupTalkViewControllers) {
            TalkViewController* tvc = safeSelf.groupTalkViewControllers[key];
            [tvc updateUserLineState:userLineState fromUid:fromUid fromAccount:fromAccount];
        }
    }];
}

#pragma mark - 处理收发文件事件
- (void)handleWillRecevieFileForCall:(uint64_t)callId msgId:(uint64_t)msgId msgTime:(NSDate *)msgTime fromUid:(uint64_t)fromUid fileName:(NSString *)fileName fileSize:(uint64_t)fileSize ackBlock:(EB_RECEIVE_FILE_ACK_BLOCK)ackBlock cancelBlock:(EB_RECEIVE_FILE_CANCEL_BLOCK)cancelBlock
{
    EBMessage* message = [[ENTBoostKit sharedToolKit] messageWithMessageId:msgId];
    if (message) {
//        message.isWaittingAck = YES;
        [self dispatchReceviedMessage:message ackBlock:ackBlock cancelBlock:cancelBlock];
    }
}

- (void)handleBeginRecevieFileForCall:(uint64_t)callId msgId:(uint64_t)msgId
{
    [self updateTalkViewWithMsgId:msgId usingBlock:^(TalkViewController *vc, EBMessage *message) {
//        message.isWaittingAck = NO;
        message.isWorking = YES;
        [vc updateCellWithMessage:message reload:YES];
    }];
}

- (void)handleDidRecevieFileForCall:(uint64_t)callId msgId:(uint64_t)msgId
{
    [self updateTalkViewWithMsgId:msgId usingBlock:nil];
}

- (void)handleRecevingFileForCall:(uint64_t)callId msgId:(uint64_t)msgId percent:(double_t)percent speed:(double_t)speed
{
    [self updateTalkViewWithMsgId:msgId usingBlock:^(TalkViewController *vc, EBMessage* message) {
//        message.isWaittingAck = NO;
        message.isWorking = YES;
        [vc updateCellWithMessage:message reload:NO];
    }];
}

- (void)handleCancelRecevingFileForCall:(uint64_t)callId msgId:(uint64_t)msgId initiative:(BOOL)initiative
{
    [self updateTalkViewWithMsgId:msgId usingBlock:nil];
}

- (void)handleRecevieFileError:(NSError*)error forCall:(uint64_t)callId msgId:(uint64_t)msgId
{
    [self updateTalkViewWithMsgId:msgId usingBlock:nil];
}

- (void)handleDidSentFileForCall:(uint64_t)callId msgId:(uint64_t)msgId
{
    [self updateTalkViewWithMsgId:msgId usingBlock:nil];
}

- (void)handleCancelSentFileForCall:(uint64_t)callId msgId:(uint64_t)msgId
{
    [self updateTalkViewWithMsgId:msgId usingBlock:nil];
}

//更新聊天会话视图
- (void)updateTalkViewWithMsgId:(uint64_t)msgId usingBlock:(void(^)(TalkViewController* vc, EBMessage* message))block
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    EBMessage* message = [ebKit messageWithMessageId:msgId];
    if (message) {
        __weak typeof(self) safeSelf = self;
        EBTalk* talk = [ebKit talkWithTalkId:message.talkId];
        [BlockUtility performBlockInMainQueue:^{
            TalkViewController* vc = [safeSelf talkViewControllerWithTalk:talk];
            if (vc) {
                if (block)
                    block(vc, message);
                else
                    [vc updateCellWithMessage:message reload:YES];
            }
        }];
    }
}

#pragma mark - 处理音视频通话事件
//判断当前状态是否可以接收音视频邀请
- (BOOL)canAcceptAVRequest:(TalkViewController**)outTVC
{
    __block BOOL accept = YES;
    __weak typeof(self) safeSelf = self;
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [BlockUtility performBlockInMainQueue:^{
        for (TalkViewController* tvc in [safeSelf.p2pTalkViewControllesrs allValues]) {
            if ([tvc isAQSViewControllerShowed]) {
                *outTVC = tvc;
            }
            if ([tvc isAVBusying]) {
                accept = NO;
                dispatch_semaphore_signal(sem);
                return;
            }
        }
        
        for (TalkViewController* tvc in [safeSelf.groupTalkViewControllers allValues]) {
            if ([tvc isAQSViewControllerShowed]) {
                *outTVC = tvc;
            }
            if ([tvc isAVBusying]) {
                accept = NO;
                dispatch_semaphore_signal(sem);
                return;
            }
        }
        
        dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    return accept;
}

/*! 执行事件处理
 @function
 @param callId 会话编号
 @param block
 */
- (void)executeAVEventWithCallId:(uint64_t)callId usingBlock:(void(^)(TalkViewController* tvc))block
{
    if (callId) {
        __weak typeof(self) safeSelf = self;
        [BlockUtility performBlockInMainQueue:^{
            ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
            EBTalk* talk;
            
            for (id key in safeSelf.p2pTalkViewControllesrs) {
                TalkViewController* tvc = safeSelf.p2pTalkViewControllesrs[key];
                talk = [ebKit talkWithTalkId:tvc.talkId];
                if (talk && talk.currentCallId==callId) {
                    if (block)
                        block(tvc);
                    break;
                }
            }
            
            for (id key in safeSelf.groupTalkViewControllers) {
                TalkViewController* tvc = safeSelf.groupTalkViewControllers[key];
                talk = [ebKit talkWithTalkId:tvc.talkId];
                if (talk && talk.currentCallId==callId) {
                    if (block)
                        block(tvc);
                    break;
                }
            }
        }];
    }
}

- (void)handleAVOratorJoin:(uint64_t)callId fromUid:(uint64_t)fromUid includeVideo:(BOOL)includeVideo
{
    
}

- (void)handleAVReceiverJoin:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    
}

- (void)handleAVMemberLeft:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    
}

- (void)handleAVRequest:(uint64_t)callId fromUid:(uint64_t)fromUid includeVideo:(BOOL)includeVideo
{
    //检测是否能接收音视频邀请
    TalkViewController* oldTVC;
    if ([self canAcceptAVRequest:&oldTVC]) {
        __weak typeof(self) safeSelf = self;
        [self executeAVEventWithCallId:callId usingBlock:^(TalkViewController *tvc) {
//            [((UITabBarController*)safeSelf.navigationController.parentViewController) setSelectedViewController:safeSelf.navigationController];
            
            if (oldTVC && [safeSelf isTalkViewControllerShowed:oldTVC] && ![oldTVC.talkId isEqualToString:tvc.talkId]) {
                [oldTVC dismissAQSViewControllerIfIdle]; //释放通话界面
            }
            
            [safeSelf showTalkViewController:tvc];
            
            [BlockUtility performBlockInGlobalQueue:^{
                [NSThread sleepForTimeInterval:1.0];
                [BlockUtility performBlockInMainQueue:^{
                    [tvc handleAVRequest:callId fromUid:fromUid includeVideo:includeVideo];;
                }];
            }];
        }];
    } else { //目前状态不允许接听，拒绝
        int ackType = 2;
        [[ENTBoostKit sharedToolKit] avAckWithCallId:callId toUid:fromUid ackType:ackType onCompletion:^{
            NSLog(@"拒绝通话邀请成功，callId = %llu, targetUid = %llu, ackType =%@", callId, fromUid, @(ackType));
        } onFailure:^(NSError *error) {
            NSLog(@"拒绝通话邀请失败，callId = %llu, targetUid = %llu, ackType =%@, code = %@, msg = %@", callId, fromUid, @(ackType), @(error.code), error.localizedDescription);
        }];
    }
}

- (void)handleAVAccept:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    [self executeAVEventWithCallId:callId usingBlock:^(TalkViewController *tvc) {
       [tvc handleAVAccept:callId fromUid:fromUid];
    }];
}

- (void)handleAVReject:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    [self executeAVEventWithCallId:callId usingBlock:^(TalkViewController *tvc) {
        [tvc handleAVReject:callId fromUid:fromUid];
    }];
}

- (void)handleAVTimeout:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    [self executeAVEventWithCallId:callId usingBlock:^(TalkViewController *tvc) {
        [tvc handleAVTimeout:callId fromUid:fromUid];
    }];
}

- (void)handleAVClose:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    [self executeAVEventWithCallId:callId usingBlock:^(TalkViewController *tvc) {
        [tvc handleAVClose:callId fromUid:fromUid];
    }];
}

- (void)handleAVRecevieFirstFrame:(uint64_t)callId
{
    [self executeAVEventWithCallId:callId usingBlock:^(TalkViewController *tvc) {
        [tvc handleAVRecevieFirstFrame:callId];
    }];
}

- (void)handleAVResourceDisabled
{
    TalkViewController* oldTVC;
    //检测是否正在进行音视频通话
    if (![self canAcceptAVRequest:&oldTVC] && oldTVC) {
        [BlockUtility performBlockInMainQueue:^{
            [oldTVC stopAVTalking];
        }];
        [NSThread sleepForTimeInterval:0.5];
    }
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.talkIds.count;
}

//更新显示未读提示
- (void)updateBadgeIncell:(TalksCell*)cell forTalk:(EBTalk*)talk
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    //未读消息提示
    NSUInteger countOfUnreadMsg = 0;
    if (talk.type==EB_TALK_TYPE_CHAT)
        countOfUnreadMsg = [ebKit countOfUnreadMessagesWithTalkId:talk.talkId];
    else
        countOfUnreadMsg = [ebKit countOfUnreadNotificationsWithTalkId:talk.talkId];
    
    NSString* badgeString = countOfUnreadMsg>99?@"99+":(!countOfUnreadMsg?nil:[NSString stringWithFormat:@"%@", @(countOfUnreadMsg)]);
    cell.badgeString = badgeString;
    cell.badgeColor = [UIColor colorWithHexString:@"#ef3c4a"];//[UIColor colorWithRed:0.6 green:0.0 blue:0.0 alpha:0.6];
    //cell.badgeColor = [UIColor colorWithRed:0.197 green:0.592 blue:0.219 alpha:1.000];
//    cell.badge.radius = 9;
}

- (void)updateBadgeWithTalkId:(NSString*)talkId
{
    if (!talkId) {
        NSLog(@"updateBadgeWithTalkId talkId is nil, miss action");
        return;
    }
    
    __block TalksCell* cell;
    NSArray* cells = [self.tableView visibleCells];
    [cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TalksCell* tmpCell = obj;
        if ([tmpCell.talkId isEqualToString:talkId]) {
            cell = tmpCell;
            *stop = YES;
        }
    }];
    
    if (cell) {
//        NSLog(@"found cell for talkId:%@", talkId);
        [self updateBadgeIncell:cell forTalk:[[ENTBoostKit sharedToolKit] talkWithTalkId:talkId]];
        
        //刷新所在行
        for (NSUInteger i=0; i<self.talkIds.count; i++) {
            if ([self.talkIds[i] isEqualToString:talkId]) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
//        if (cell.currentIndexPath)
//            [self.tableView reloadRowsAtIndexPaths:@[cell.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        NSLog(@"not found cell for talkId:%@", talkId);
    }
}

//缩略聊天记录
- (NSString*)simpleContentWithMessage:(EBMessage*)message
{
    NSMutableString* content = [[NSMutableString alloc] init];
    if (message) {
        if (message.isFile) {
            [content appendFormat:@"[文件]%@", message.fileName];
        } else if (message.chats.count>0) {
            
            for (EBChat* chatDot in message.chats) {
                switch (chatDot.type) {
                    case EB_CHAT_ENTITY_TEXT:
                        [content appendString:((EBChatText*)chatDot).text];
                        break;
                    case EB_CHAT_ENTITY_RESOURCE:
                    {
                        EBChatResource* resDot = (EBChatResource*)chatDot;
                        EBEmotion* expression = resDot.expression;
                        [content appendFormat:@"[%@]", expression.descri];
                    }
                        break;
                    case EB_CHAT_ENTITY_IMAGE:
                        [content appendString:@"[图片]"];
                        break;
                    case EB_CHAT_ENTITY_AUDIO:
                        [content appendString:@"[语音消息]"];
                        break;
                }
            }
        }
    }
    return content;
}

//获取talk对应的最新一条聊天记录
- (NSString*)lastMessageWithTalkId:(NSString*)talkId outMessage:(EBMessage**)outMessage
{
    NSDictionary* lastMessagesOfTalkIds = [[ENTBoostKit sharedToolKit] lastMessagesWithTalkIds:@[talkId]];
    if (lastMessagesOfTalkIds) {
        [self.lastMessagesOfTalkIds setDictionary:lastMessagesOfTalkIds];
        EBMessage *message = self.lastMessagesOfTalkIds[talkId];
        if (outMessage)
            *outMessage = message;
        
        return [self simpleContentWithMessage:message];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"talkCell";
    TalksCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    cell.currentIndexPath = indexPath;
    
    cell.customImageView.tag = -1;
    if (!cell.headPhotoTapRecognizer && !cell.customImageView) {
        [cell.customImageView removeGestureRecognizer:cell.headPhotoTapRecognizer];
    }
    
    //通过行索引获取显示队列中的talkId
    NSString* talkId = [self.talkIds objectAtIndex:indexPath.row];
    cell.talkId = talkId;
    
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    
//    //设置空背景
//    if (IOS7)
//        cell.backgroundView = nil;
//    else
//        cell.contentView.backgroundColor = EBCHAT_DEFAULT_BLACKGROUND_COLOR;
    
//    //设置选中颜色
//    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
//    cell.selectedBackgroundView.backgroundColor = EBCHAT_DEFAULT_SELECTED_COLOR;
    //设置头像图片圆角边框
    [cell.customImageView setCornerRadius:5.0 borderWidth:1.0 borderColor:[UIColor clearColor]];
    //设置时间标签
    EBTalk* talk = [ebKit talkWithTalkId:talkId];
    if (talk.updatedTime) {
        cell.timeTextLabel.text = [talk.updatedTime stringByFlexibleFormat];
    }
    
    //更新图标右上角数字
    [self updateBadgeIncell:cell forTalk:talk];
    //清空聊天内容框
    cell.customDetailTextLabel.text = nil;
    
    TalkViewController* tvc = [self talkViewControllerWithTalk:talk];
    
    if (talk.type==EB_TALK_TYPE_CHAT) { //聊天
        if(tvc.depCode) { //群组聊天
//            cell.customTextLabel.text = tvc.depName;
            cell.customTextLabel.text = tvc.groupInfo.depName;
            
            //获取最后说话成员的名称，并与聊天内容一起用作缩略显示
            EBMessage* message;
            NSString* simpleContent = [self lastMessageWithTalkId:talkId outMessage:&message];
            if (message) {
                __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
                [ebKit loadMemberInfoWithUid:message.fromUid depCode:tvc.depCode onCompletion:^(EBMemberInfo *memberInfo) {
                    [BlockUtility performBlockInMainQueue:^{
                        cell.customDetailTextLabel.text = [NSString stringWithFormat:@"%@: %@", memberInfo.userName, simpleContent];
                    }];
                    dispatch_semaphore_signal(sem);
                } onFailure:^(NSError *error) {
                    NSLog(@"loadMemberInfoWithUid:%llu, depCode:%llu error, code = %@, msg = %@", message.fromUid, tvc.depCode, @(error.code), error.localizedDescription);
                    dispatch_semaphore_signal(sem);
                }];
                dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 2.0f * NSEC_PER_SEC));
            }
        } else { //一对一聊天
            cell.customTextLabel.text = tvc.otherUserName;
            cell.customDetailTextLabel.text = [self lastMessageWithTalkId:talkId outMessage:nil];
        }
        
        //头像点击事件
        cell.headPhotoTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didHeadPhotoTap:)];
        [cell.customImageView addGestureRecognizer:cell.headPhotoTapRecognizer];
        cell.customImageView.tag = indexPath.row;
    } else if (talk.type==EB_TALK_TYPE_MY_MESSAGE || talk.type==EB_TALK_TYPE_BROADCAST_MESSAGE || talk.type==EB_TALK_TYPE_BROADCAST_MESSAGE_NEW_EMAIL || talk.type==EB_TALK_TYPE_BROADCAST_MESSAGE_EMAIL_COUNT) { //"我的消息"应用
        cell.customTextLabel.text = talk.talkName;
        
        NSArray* notifications = [ebKit notificationsWithTalkId:talk.talkId];
        if (notifications.count>0) {
            EBNotification* notif = notifications[0];
            
            if (talk.type==EB_TALK_TYPE_MY_MESSAGE) { //显示我的消息通知细节
                cell.customDetailTextLabel.text = notif.content;
            } else if (talk.type==EB_TALK_TYPE_BROADCAST_MESSAGE) { //显示广播消息通知细节
                cell.customDetailTextLabel.text = notif.content;
            } else if (talk.type==EB_TALK_TYPE_BROADCAST_MESSAGE_EMAIL_COUNT) { //显示未读邮件通知细节
                cell.customDetailTextLabel.text = [NSString stringWithFormat:@"共有%@封未读邮件", notif.content1];
            } else if(talk.type==EB_TALK_TYPE_BROADCAST_MESSAGE_NEW_EMAIL) { //显示最新邮件通知细节
                EBEmailDescription* emailDesc = [[EBEmailDescription alloc] initWithFormatedString:notif.content1];
                cell.customDetailTextLabel.text = emailDesc.subject;
            }
        }
    } else if (talk.type==EB_TALK_TYPE_SYS_NOTICE) { //系统通知
        cell.customTextLabel.text = talk.talkName;
        NSArray* notifications = [ebKit notificationsWithTalkId:talk.talkId];
        if (notifications.count>0) {
            EBNotification* notif = notifications[0];
            cell.customDetailTextLabel.text = notif.content;
        }
    } else {
        cell.customTextLabel.text = @"未知";
    }
    
    __weak typeof(self) safeSelf = self;
    
    //只对于一对一聊天和未加载过
    if (talk.type==EB_TALK_TYPE_CHAT && !tvc.depCode && tvc.headPhotoFilePath.length==0) {
        NSNumber* boolNum = self.headPhotoLoadedCache[talkId];
        
        if (boolNum==nil) {
            //加载头像图片
            [ebKit loadHeadPhotoWithTalkId:talkId onCompletion:^(NSString *filePath) {
                if (filePath.length > 0) {
                    [BlockUtility syncPerformBlockInMainQueue:^{ //主线程同步执行
                        tvc.headPhotoFilePath = filePath;
                        safeSelf.headPhotoLoadedCache[talkId] = @YES;
                    }];
                } else {
                    [BlockUtility syncPerformBlockInMainQueue:^{ //主线程同步执行
                        safeSelf.headPhotoLoadedCache[talkId] = @NO;
                    }];
                }
                
                [safeSelf updateHeadPhotoWithCell:cell talkViewController:tvc talkType:talk.type];
            } onFailure:^(NSError *error) {
                [BlockUtility syncPerformBlockInMainQueue:^{ //主线程同步执行
                    safeSelf.headPhotoLoadedCache[talkId] = @NO;
                }];
                
                [safeSelf updateHeadPhotoWithCell:cell talkViewController:tvc talkType:talk.type];
            }];
        } else {
            [safeSelf updateHeadPhotoWithCell:cell talkViewController:tvc talkType:talk.type];
        }
    } else {
        [safeSelf updateHeadPhotoWithCell:cell talkViewController:tvc talkType:talk.type];
    }
    
    return cell;
}

//处理点击头像事件
- (void)didHeadPhotoTap:(UITapGestureRecognizer*)sender
{
    NSInteger row = sender.view.tag;
    if (row > -1) {
        NSString* talkId = self.talkIds[row];
        EBTalk* talk = [[ENTBoostKit sharedToolKit] talkWithTalkId:talkId];
        if (talk.isGroup) {
            [[ControllerManagement sharedInstance] fetchGroupControllerWithDepCode:talk.depCode onCompletion:^(GroupInformationViewController *gvc) {
                [self.navigationController pushViewController:gvc animated:YES]; //进入属性界面
            } onFailure:nil];
        } else {
            [[ControllerManagement sharedInstance] fetchUserControllerWithUid:talk.otherUid orAccount:talk.otherAccount checkVCard:YES onCompletion:^(UserInformationViewController *uvc) {
                [self.navigationController pushViewController:uvc animated:YES]; //进入属性界面
            } onFailure:nil];
        }
    }
}

//设置Cell头像
- (void)updateHeadPhotoWithCell:(TalksCell*)cell talkViewController:(TalkViewController*)talkViewController talkType:(EB_TALK_TYPE)talkType
{
    [BlockUtility performBlockInMainQueue:^{
        //获取文件路径
        NSString* filePath = talkViewController.headPhotoFilePath;
        uint64_t depCode = talkViewController.depCode;
        
        //显示图片
        if (![ResourceKit showImageWithFilePath:filePath inImageView:cell.customImageView]) {
            if (talkType==EB_TALK_TYPE_CHAT) { //聊天
                if (depCode)
                    [ResourceKit showGroupHeadPhotoWithFilePath:nil inImageView:cell.customImageView forGroupType:talkViewController.groupInfo.type];
                else
                    [ResourceKit showUserHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
            } else if (talkType==EB_TALK_TYPE_SYS_NOTICE || talkType==EB_TALK_TYPE_MY_MESSAGE || talkType==EB_TALK_TYPE_BROADCAST_MESSAGE) { //我的消息
                UIImage* image = [ResourceKit imageOf3rdApplicationWithSubId:1002300103];
                
                if (image)
                    cell.customImageView.image = image;
                else
                    [ResourceKit showNotificationHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
            } else if (talkType==EB_TALK_TYPE_BROADCAST_MESSAGE_NEW_EMAIL || talkType==EB_TALK_TYPE_BROADCAST_MESSAGE_EMAIL_COUNT) { //我的邮件
                UIImage* image = [ResourceKit imageOf3rdApplicationWithSubId:1002300104];
                
                if (image)
                    cell.customImageView.image = image;
                else
                    [ResourceKit showNotificationHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
            } else { //其它
                [ResourceKit showNotificationHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
            }
        }
    }];
}

#define HEIGHT_FOR_HEADER_FOOTER 20.0f

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return HEIGHT_FOR_HEADER_FOOTER;
//}
//
//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, HEIGHT_FOR_HEADER_FOOTER)];
//    [view setBackgroundColor:[UIColor clearColor]];
//    
//    return view;
//}

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
    
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    EBTalk* talk = [ebKit talkWithTalkId:[self.talkIds objectAtIndex:indexPath.row]];
    TalkViewController* tvc = [self talkViewControllerWithTalk:talk];
    
    if (talk.type==EB_TALK_TYPE_CHAT) { //聊天会话
        [self showTalkViewController:tvc];
    } else if (talk.type==EB_TALK_TYPE_SYS_NOTICE //系统通知
               || talk.type==EB_TALK_TYPE_MY_MESSAGE //系统消息
               || talk.type==EB_TALK_TYPE_BROADCAST_MESSAGE //群发广播消息
               || talk.type==EB_TALK_TYPE_BROADCAST_MESSAGE_NEW_EMAIL //新邮件通知
               || talk.type==EB_TALK_TYPE_BROADCAST_MESSAGE_EMAIL_COUNT) { //未读邮件数量通知
        
        EBNotification* notification;
        NSArray* notifications = [ebKit notificationsWithTalkId:talk.talkId];
        if (notifications.count>0) {
            notification = notifications[0];
        }
        
        if (notification) {
            uint64_t subId = notification.value;
            
            [ebKit markNotificationsAsReadedWithTalkId:talk.talkId]; //设置为已读状态
            [self updateBadgeValue]; //更新TabBar、应用图标右上角提醒内容
            
            if (talk.type==EB_TALK_TYPE_BROADCAST_MESSAGE_EMAIL_COUNT) {
                //删除通知消息
                [ebKit deleteTalkWithId:talk.talkId];
                [self.talkIds removeObjectAtIndex:indexPath.row];
                //删除当前cell
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } else {
                //更新当前cell
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if (talk.type!=EB_TALK_TYPE_SYS_NOTICE) {
                //发送显示“系统通知”、"广播消息"应用的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_SHOW_APPLICATION object:self userInfo:@{@"subId":@(subId), @"type":@(talk.type), @"ebNotification":notification}];
            }
        }
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
         NSString* talkId = [self.talkIds objectAtIndex:indexPath.row];
         
         EBTalk* talk = [ebKit talkWithTalkId:talkId];
         if (talk) {
             [ebKit deleteTalkWithId:talkId];
             [self.talkIds removeObject:talkId];
             
             if (talk.type==EB_TALK_TYPE_CHAT) {
                 if (talk.depCode) {
                     [self.groupTalkViewControllers removeObjectForKey:@(talk.depCode)];
                 } else {
                     [self.p2pTalkViewControllesrs removeObjectForKey:@(talk.otherUid)];
                 }
             } else {
                 [self.notificationTalkViewControllers removeObjectForKey:talkId];
             }
             
             //删除视图对应行
             [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
             //更新TabBar、应用图标右上角提醒内容
             [self updateBadgeValue];
         }
     } else if (editingStyle == UITableViewCellEditingStyleInsert) {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
 }

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */
@end
