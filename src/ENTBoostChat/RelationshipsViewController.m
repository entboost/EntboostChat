//
//  RelationshipsViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-2.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "RelationshipsViewController.h"
#import "RelationshipHelper.h"
#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "RelationshipHelper.h"
#import "TableTreeNode.h"
#import "BlockUtility.h"
#import "ENTBoost+Utility.h"
#import "CustomSeparator.h"
#import "FVCustomAlertView.h"
#import "AppDelegate.h"
#import "RelationshipDeepInViewController.h"
#import "ControllerManagement.h"
#import "PublicUI.h"
#import "ButtonKit.h"
#import "UserInformationViewController.h"
#import "GroupInformationViewController.h"
#import "ContactInformationViewController.h"

@interface RelationshipsViewController () <GroupInformationViewControllerDelegate, UserInformationViewControllerDelegate>
{
    BOOL _isInited; //是否已经执行过初始化
    UIStoryboard* _mainStoryboard;
}

@property(nonatomic, strong) RelationshipHelper* helper; //联系人视图辅助实例

@property(nonatomic, strong) IBOutlet UIView* toolbar; //工具栏视图
@property(nonatomic, strong) IBOutlet CustomSeparator* toolbarBottomBorder; //工具栏下边框
@property(nonatomic, strong) IBOutlet UIView* treeContainer; //树显示容器

@property(nonatomic, strong) IBOutlet UIButton* myDepartmentBtn; //"我的部门"按钮
@property(nonatomic, strong) IBOutlet UIButton* contactBtn; //"通讯录"按钮
@property(nonatomic, strong) IBOutlet UIButton* personalGroupBtn; //"个人群组"按钮
@property(nonatomic, strong) IBOutlet UIButton* enterpriseBtn; //"组织架构"按钮
@property(nonatomic, strong) IBOutlet UIView* floatMarkedLine; //标记线

@property(nonatomic, strong) IBOutlet CustomSeparator* selectedViewBottomBorder; //当前选中
@property(nonatomic, strong) IBOutlet UILabel* selectedViewLabel; //当前选中视图标题显示控件

@end

@implementation RelationshipsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
//        self.relationshipArray = [NSMutableArray array];
        _mainStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_MAIN bundle:nil];
        
        //注册接收通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createGroup:) name:EBCHAT_NOTIFICATION_CREATE_PERSONAL_GROUP object:nil]; //创建个人群组
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup:) name:EB_CHAT_NOTIFICATION_EXIT_GROUP object:nil]; //退出群组
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteGroup:) name:EB_CHAT_NOTIFICATION_DELETE_GROUP object:nil]; //解散群组
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMember:) name:EB_CHAT_NOTIFICATION_DELETE_MEMBER object:nil]; //删除群组成员
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteContact:) name:EB_CHAT_NOTIFICATION_DELETE_CONTACT object:nil]; //删除联系人
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContact:) name:EB_CHAT_NOTIFICATION_RELOAD_CONTACT object:nil]; //重新载入联系人
        
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addContact:) name:EB_CHAT_NOTIFICATION_ADD_CONTACT object:nil]; //添加联系人
        
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    //设置导航栏
//    [self initNavigationBar];
    
    self.helper = [[RelationshipHelper alloc] initWithToolbar:self.toolbar treeContainer:self.treeContainer selectedViewLabel:self.selectedViewLabel selectedViewBottomBorder:self.selectedViewBottomBorder toolbarBottomBorder:self.toolbarBottomBorder myDepartmentBtn:self.myDepartmentBtn contactBtn:self.contactBtn personalGroupBtn:self.personalGroupBtn enterpriseBtn:self.enterpriseBtn floatMarkedLine:self.floatMarkedLine delegate:self];
    
    //设置工具栏
    [self.helper initToolbar:self.view];
    //设置选中的视图的属性
    [self.helper initSelectedView];
}

- (void)viewDidAppear:(BOOL)animated
{
    //联系人关系视图
    if (!_isInited) { //保证只执行一次初始化
        _isInited = YES;
        
        //读取数据并填充视图
        [self.helper fillTreesWithIsHiddenTalkBtn:YES isHiddenPropertiesBtn:NO isHiddenTickBtn:YES isHiddenGroupTickBtn:YES];
        //设置当前选中标记线位置
        [self.helper setSelectedButtonAtIndex:0];
    }
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EBCHAT_NOTIFICATION_CREATE_PERSONAL_GROUP object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EB_CHAT_NOTIFICATION_EXIT_GROUP object:nil]; //当前用户退出群组
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EB_CHAT_NOTIFICATION_DELETE_GROUP object:nil]; //解散群组
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EB_CHAT_NOTIFICATION_DELETE_MEMBER object:nil]; //删除群组成员
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EB_CHAT_NOTIFICATION_DELETE_CONTACT object:nil]; //删除联系人
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EB_CHAT_NOTIFICATION_RELOAD_CONTACT object:nil]; //重新载入联系人
}

//处理创建个人群组的通知
- (void)createGroup:(NSNotification*)notif
{
    NSString* groupName = notif.userInfo[@"groupName"];
    if (groupName) {
        __weak typeof(self) safeSelf =self;
        ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
        uint64_t myUid = ebKit.accountInfo.uid;
        EBGroupInfo* newGroupInfo = [[EBGroupInfo alloc] initWithDepCode:0 depName:groupName parentCode:0 phone:nil fax:nil email:nil url:nil address:nil descri:nil];
        
        //显示提示框
        ShowAlertView();
        
        [ebKit createGroup:newGroupInfo groupType:EB_GROUP_TYPE_GROUP onCompletion:^(EBGroupInfo* groupInfo) {
            NSLog(@"创建个人群组'%@'成功", groupName);
            
            if (groupInfo) {
                NSLog(@"构造虚拟创建群组事件, depCode = %llu", groupInfo.depCode);
                AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [appDelegate onUpdateGroup:groupInfo fromUid:ebKit.accountInfo.uid fromAccount:ebKit.accountInfo.account];
                
                //弹出查看群组资料界面
                [[ControllerManagement sharedInstance] fetchGroupControllerWithDepCode:groupInfo.depCode onCompletion:^(GroupInformationViewController *gvc) {
                    [ebKit loadMemberInfoWithUid:myUid depCode:groupInfo.depCode onCompletion:^(EBMemberInfo *memberInfo) {
                        [BlockUtility performBlockInMainQueue:^{
                            gvc.delegate = safeSelf;
                            gvc.dataObject = nil;
                            gvc.myMemberInfo = memberInfo;
                            [safeSelf.navigationController pushViewController:gvc animated:YES];
                        }];
                    } onFailure:^(NSError *error) {
                        [BlockUtility performBlockInMainQueue:^{
                            gvc.delegate = safeSelf;
                            gvc.dataObject = nil;
                            [safeSelf.navigationController pushViewController:gvc animated:YES];
                        }];
                    }];
                } onFailure:nil];
            }
            
            //关闭提示框
            CloseAlertView();
        } onFailure:^(NSError *error) {
            NSLog(@"创建个人群组'%@'失败，code = %@, msg = %@", groupName, @(error.code), error.localizedDescription);
            //关闭提示框
            CloseAlertView();
        }];
    }
}

//处理当前用户退出群组的通知
- (void)exitGroup:(NSNotification*)notif
{
    NSDictionary* userInfo = notif.userInfo;
    uint64_t depCode = [userInfo[@"depCode"] unsignedLongLongValue];
    uint64_t empCode = [userInfo[@"empCode"] unsignedLongLongValue];
    //显示提示框
    ShowAlertView();
    
    [[ENTBoostKit sharedToolKit] deleteMember:empCode depCode:depCode onCompletion:^{
        NSLog(@"退出群组成功，empCode = %llu, depCode = %llu", empCode, depCode);
        //关闭提示框
        CloseAlertView();
    } onFailure:^(NSError *error) {
        NSLog(@"退出群组失败，empCode = %llu, depCode = %llu, code = %@, msg = %@", empCode, depCode, @(error.code), error.localizedDescription);
        //关闭提示框
        CloseAlertView();
    }];
}

//处理主动解散群组的通知
- (void)deleteGroup:(NSNotification*)notif
{
    NSDictionary* userInfo = notif.userInfo;
    uint64_t depCode = [userInfo[@"depCode"] unsignedLongLongValue];
    
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    EBGroupInfo* groupInfo = [ebKit groupInfoWithDepCode:depCode];
    //显示提示框
    ShowAlertView();
    
    [[ENTBoostKit sharedToolKit] deleteGroup:depCode onCompletion:^{
        NSLog(@"删除群组:%llu 成功", depCode);
        if (groupInfo) {
            NSLog(@"构造虚拟删除群组事件, depCode = %llu", depCode);
            AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate onDeleteGroup:groupInfo fromUid:ebKit.accountInfo.uid fromAccount:ebKit.accountInfo.account];
        }
        //关闭提示框
        CloseAlertView();
    } onFailure:^(NSError *error) {
        NSLog(@"删除群组:%llu 失败, code = %@, msg = %@", depCode, @(error.code), error.localizedDescription);
        //关闭提示框
        CloseAlertView();
    }];
}

//删除群组成员
- (void)deleteMember:(NSNotification*)notif
{
    NSDictionary* userInfo = notif.userInfo;
    uint64_t depCode = [userInfo[@"depCode"] unsignedLongLongValue];
    uint64_t empCode = [userInfo[@"empCode"] unsignedLongLongValue];
    //显示提示框
    ShowAlertView();
    
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    [ebKit deleteMember:empCode depCode:depCode onCompletion:^{
        NSLog(@"删除群组成员:%llu 成功", empCode);
        //关闭提示框
        CloseAlertView();
    } onFailure:^(NSError *error) {
        NSLog(@"删除群组成员: empCode = %llu, depCode = %llu 失败, code = %@, msg = %@", empCode, depCode, @(error.code), error.localizedDescription);
        //关闭提示框
        CloseAlertView();
    }];
}

//处理删除联系人的通知
- (void)deleteContact:(NSNotification*)notif
{
    uint64_t contactId = [notif.userInfo[@"contactId"] unsignedLongLongValue];
    __weak typeof(self) safeSelf = self;
    //显示提示框
    ShowAlertView();
    
    [RelationshipHelper deleteContact:contactId onCompletion:^{
        //更新界面
        [BlockUtility performBlockInMainQueue:^{
            [safeSelf.helper.contactTree removeNodeWithId:[NSString stringWithFormat:@"%llu", contactId] updateParentNodeLoadedState:NO];
        }];
        
        //关闭提示框
        CloseAlertView();
    } onFailureBlock:^(NSError *error) {
        //关闭提示框
        CloseAlertView();
    }];
}

//处理重新载入联系人的通知
- (void)reloadContact:(NSNotification*)notif
{
    [self.helper reloadContactTree];
}

- (void)configureNavigationBar:(UINavigationItem*)navigationItem
{
//    //设置标题
//    self.navigationItem.title = @"联系人";
    
//    //左边按钮1
//    UIButton* lBtn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 24)];
//    [lBtn1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//    [lBtn1 setImage:[UIImage imageNamed:@"navigation_goback"] forState:UIControlStateNormal];
//    UIBarButtonItem * leftButton1 = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
//    leftButton1.customView = lBtn1;
    
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

//弹出菜单
- (void)popupMenu
{
    [[PublicUI sharedInstance] popupNavigationMenuInView:self.view];
}

//切换到搜索界面
- (void)searchMenu
{
    [[PublicUI sharedInstance] searchMenuInViewController:self];
}

#pragma mark - Update Tree

//更新联系人节点
- (void)updateTree:(TableTree*)tree usingContactInfo:(EBContactInfo*)contactInfo isRemove:(BOOL)isRemove
{
    if (!contactInfo) {
        NSLog(@"updateTree contactInfo is nil, do nothing");
        return;
    }
    
    if (!isRemove) { //增加
        //构造成员节点
        TableTreeNode* contactNode = [[TableTreeNode alloc] init];
        contactNode.isDepartment = NO;
        contactNode.parentNodeId = [NSString stringWithFormat:@"%llu", contactInfo.groupId];
        contactNode.nodeId = [NSString stringWithFormat:@"%llu", contactInfo.contactId];
        contactNode.name = [NSString stringWithFormat:@"%@", contactInfo.name?contactInfo.name:contactInfo.account];
        if (!contactInfo.verified && [ENTBoostKit sharedToolKit].isContactNeedVerification) {
            contactNode.name = [NSString stringWithFormat:@"%@[%@]", contactNode.name, @"未验证"];
        }
        
        if (contactInfo.uid && contactInfo.uid!=[ENTBoostKit sharedToolKit].accountInfo.uid)
            contactNode.isHiddenTalkBtn = NO;
        
        ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
        //判断通讯录是否需要验证
        if (ebKit.isContactNeedVerification) {
            contactNode.isOffline = YES;
        } else {
            contactNode.isOffline = NO;
        }
        
        contactNode.data = [[NSMutableDictionary alloc] initWithCapacity:2];
        contactNode.data[@"contactInfo"] = contactInfo;
        contactNode.data[@"type"] = @(RELATIONSHIP_TYPE_CONTACT);
        
        [BlockUtility performBlockInMainQueue:^{
            //成员节点原来不存在，分组节点计算数量加1
            if (![tree isNodeExists:contactNode.nodeId]) {
                TableTreeNode* groupNode = [tree nodeWithId:contactNode.parentNodeId];
                if (groupNode) {
                    //                    NSMutableDictionary* data = [groupNode.data mutableCopy];
                    groupNode.data[@"leafCount"] = @([groupNode.data[@"leafCount"] intValue]+1);
                    //                    groupNode.data = data;
                    
                    [tree insertOrUpdateWithNode:groupNode inFirstLevel:YES];
                }
            }
            //更新成员节点
            [tree insertOrUpdateWithNode:contactNode inFirstLevel:NO];
            
            //加载联系人在线状态
            if (ebKit.isContactNeedVerification) {
                if (contactInfo.uid) {
                    [ebKit loadOnlineStateOfUsers:@[@(contactInfo.uid)] onCompletion:^(NSDictionary *onlineStates) {
                        NSNumber* onlineStateNum = [onlineStates objectForKey:@(contactInfo.uid)];
                        if (onlineStateNum) {
                            [BlockUtility performBlockInMainQueue:^{
                                [tree updateOnlineStateCountOfGroupWithUserLineState:[onlineStateNum intValue] forContactUid:contactInfo.uid]; //更新在线人数，一定要比[updateMemberOnlineState:]先执行
                                [tree updateMemberOnlineState:[onlineStateNum intValue] forContactId:contactInfo.contactId]; //更新在线状态
                            }];
                        }
                    } onFailure:^(NSError *error) {
                        NSLog(@"loadOnlineStateOfUsers error, code = %@, msg = %@", @(error.code), error.localizedDescription);
                    }];
                } else {
                    [tree updateMemberOnlineState:EB_LINE_STATE_UNKNOWN forContactId:contactInfo.contactId];
                }
            } else {
                [tree updateMemberOnlineState:EB_LINE_STATE_ONLINE forContactId:contactInfo.contactId];
            }
        }];
    } else { //删除
        [BlockUtility performBlockInMainQueue:^{
            NSString* nodeId = [NSString stringWithFormat:@"%llu", contactInfo.contactId];
            //更新在线人数
            if ([ENTBoostKit sharedToolKit].isContactNeedVerification) {
                [tree updateOnlineStateCountOfGroupOnWillRemoveNode:nodeId];
            }
            //删除节点
            [tree removeNodeWithId:nodeId updateParentNodeLoadedState:NO];
        }];
    }
}

/**更新tree视图
 * @param tree 树结构对象
 * @param memberInfo 成员资料
 * @param groupInfo 群组(部门)资料
 * @param groupType 联系人类型
 * @param onlineCountOfMembers 该群组成员在线人数
 * @param isRemove 是否删除
 */
- (void)updateTree:(TableTree*)tree usingMemberInfo:(EBMemberInfo*)memberInfo groupInfo:(EBGroupInfo*)groupInfo groupType:(RELATIONSHIP_TYPE)groupType onlineCountOfMembers:(NSInteger)onlineCountOfMembers isRemove:(BOOL)isRemove
{
    //构造成员节点
    __block TableTreeNode* memberNode = nil;
    if (memberInfo) {
        memberNode = [[TableTreeNode alloc] init];
        memberNode.isDepartment = NO;
        memberNode.parentNodeId = [NSString stringWithFormat:@"%llu", groupInfo.depCode];
        memberNode.nodeId = [NSString stringWithFormat:@"%llu", memberInfo.empCode];
        memberNode.name = memberInfo.userName;
        memberNode.isOffline = YES;
        
        if (memberInfo.uid == [ENTBoostKit sharedToolKit].accountInfo.uid)
            memberNode.isHiddenTalkBtn = YES;
        else
            memberNode.isHiddenTalkBtn = NO;
        
        memberNode.isHiddenPropertiesBtn = YES;
        
        memberNode.data = [[NSMutableDictionary alloc] initWithCapacity:2];
        memberNode.data[@"memberInfo"] = memberInfo;
        memberNode.data[@"type"] = @(RELATIONSHIP_TYPE_MEMBER);
    }
    
    //构造部门节点
    TableTreeNode* groupNode = [RelationshipHelper treeNodeWithGroupInfo:groupInfo groupType:groupType onlineCountOfMembers:onlineCountOfMembers isHiddenTalkBtn:YES isHiddenPropertiesBtn:NO isHiddenTickBtn:YES isHiddenGroupTickBtn:YES];
    //判断部门节点是否应在首层
    BOOL inFirstLevel = groupInfo.parentCode?NO:YES;
    //我的部门
    if (groupType == RELATIONSHIP_TYPE_MYDEPARTMENT) {
        inFirstLevel = YES;
    }
    //个人群组
    if (groupType == RELATIONSHIP_TYPE_PERSONALGROUP) {
        inFirstLevel = YES;
    }
    
    //增操作
    if (!isRemove) {
        //插入或更新群组(部门)节点
        [BlockUtility performBlockInMainQueue:^{
            BOOL isShowed = [tree isNodeShowed:groupNode.nodeId];
            [tree insertOrUpdateWithNode:groupNode inFirstLevel:inFirstLevel];
            
            //部门之前没被显示，排序
            if (!isShowed)
                [tree sortNodesOfSameGroupWithNodeId:groupNode.nodeId];
        }];
        
        if (memberNode) {
            //更新成员节点
            __block BOOL isReturn = NO; //本函数是否已经执行结束
            __block EB_USER_LINE_STATE onlineState = EB_LINE_STATE_OFFLINE;
            
            //加载在线状态
            __block dispatch_semaphore_t sem0 = dispatch_semaphore_create(0);
            [[ENTBoostKit sharedToolKit] loadOnlineStateOfUsers:@[@(memberInfo.uid)] onCompletion:^(NSDictionary *onlineStates) {
                NSNumber* onlineStateNum = [onlineStates objectForKey:@(memberInfo.uid)];
                if (onlineStateNum) {
                    onlineState = [onlineStateNum intValue];
                    [BlockUtility performBlockInMainQueue:^{
                        if (onlineState!=EB_LINE_STATE_OFFLINE && onlineState!=EB_LINE_STATE_UNKNOWN) {
                            memberNode.isOffline = NO;
                            
                            //如果上级函数已经返回才需要刷新视图
                            if (isReturn)
                                [tree updateMemberOnlineState:onlineState forUid:memberInfo.uid];
                        }
                    }];
                }
                
                dispatch_semaphore_signal(sem0);
            } onFailure:^(NSError *error) {
                NSLog(@"loadOnlineStateOfUsers error, code = %@, msg = %@", @(error.code), error.localizedDescription);
                dispatch_semaphore_signal(sem0);
            }];
            dispatch_semaphore_wait(sem0, dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC));
            
            //加载头像
            __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            [[ENTBoostKit sharedToolKit] loadHeadPhotoWithMemberInfo:memberInfo onCompletion:^(NSString *filePath) {
                NSLog(@"head photo filePath:%@", filePath);
                [BlockUtility performBlockInMainQueue:^{
                    //设置Node的头像文件路径
                    memberNode.icon = filePath;
                    //如果上级函数已经返回才需要刷新视图
                    if (isReturn)
                        [tree reloadData];
                }];
                dispatch_semaphore_signal(sem);
            } onFailure:^(NSError *error) {
//                NSLog(@"loadHeadPhotoWithMemberInfo error, code = %@, msg = %@", @(error.code), error.localizedDescription);
                dispatch_semaphore_signal(sem);
            }];
            dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC));
            
            //回调返回结果集
            [BlockUtility performBlockInMainQueue:^{
                [tree insertOrUpdateWithNode:memberNode inFirstLevel:NO];
                [tree updateMemberOnlineState:onlineState forUid:memberInfo.uid];
                isReturn = YES; //标记本函数执行结束
            }];
        }
    }
    //减操作
    else {
        [BlockUtility performBlockInMainQueue:^{
            //删除成员节点
            if (memberNode)
                [tree removeNodeWithId:memberNode.nodeId updateParentNodeLoadedState:YES];
            //更新上层部门节点
            [tree insertOrUpdateWithNode:groupNode inFirstLevel:inFirstLevel];
        }];
    }
}

//更新节点
- (void)executeUpdateWithNode:(TableTreeNode*)node inFirstLevel:(BOOL)inFirstLevel inTree:(TableTree*)tree
{
    if ([tree isNodeExists:node.nodeId]) {
        [tree insertOrUpdateWithNode:node inFirstLevel:inFirstLevel];
        [tree sortNodesOfSameGroupWithNodeId:node.nodeId];
    }
}

//更新成员在线状态
- (void)updateMemberOnlineStatesInTree:(TableTree*)tree
{
    [BlockUtility performBlockInMainQueue:^{
        NSArray* depNodes = [tree departmentNodesOfLoadedSubNodes];
        for (TableTreeNode* depNode in depNodes) {
            if (depNode.data[@"type"]) {
                int type = [depNode.data[@"type"] intValue];
                
                if (type!=RELATIONSHIP_TYPE_CONTACTGROUP) { //企业部门或群组
                    EBGroupInfo* groupInfo = depNode.data[@"groupInfo"];
                    if (groupInfo) {
                        [[ENTBoostKit sharedToolKit] loadOnlineStateOfMembersWithDepCode:groupInfo.depCode onCompletion:^(NSDictionary *onlineStates, uint64_t depCode) {
                            [BlockUtility performBlockInMainQueue:^{
                                [tree updateMemberOnlineStates:onlineStates forParentNodeId:[NSString stringWithFormat:@"%llu", depCode]];
                            }];
                        } onFailure:^(NSError *error) {
                            NSLog(@"加载成员在线状态失败，depCode = %llu, code = %@, msg = %@", groupInfo.depCode, @(error.code), error.localizedDescription);
                        }];
                    }
                }
            }
        }
    }];
}

//更新好友在线状态
- (void)updateContactOnlineStatesInTree:(TableTree*)tree
{
    [[ENTBoostKit sharedToolKit] loadOnlineStateOfContactsOnCompletion:^(NSDictionary *onlineStates) {
        [BlockUtility performBlockInMainQueue:^{
            [tree updateMemberOnlineStates:onlineStates forParentNodeId:nil];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"加载好友在线状态失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
    }];
}


#pragma mark - TableTreeDelegate

- (void)tableTree:(TableTree *)tableTree didSelectedRowWithNode:(TableTreeNode *)node
{
    if (!node.isDepartment) {
        [RelationshipHelper showPropertiesWithNode:node navigationController:self.navigationController delegate:self];
    }
}

- (void)tableTree:(TableTree *)tableTree talkBtnTapInNode:(TableTreeNode *)node
{
    [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_RELATIONSHIP_DIDSELECT object:self userInfo:@{@"node": node}];
}

- (void)tableTree:(TableTree *)tableTree propertiesBtnTapInNode:(TableTreeNode *)node
{
    [RelationshipHelper showPropertiesWithNode:node navigationController:self.navigationController delegate:self];
}

- (void)tableTree:(TableTree *)tableTree deepInToNode:(TableTreeNode *)node
{
    EBGroupInfo* groupInfo;
    if ([RelationshipHelper tableTree:tableTree deepInToNode:node groupInfo:&groupInfo]) {
        RelationshipDeepInViewController* rdvc = [_mainStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_RELATIONSHIP_DEEPIN_CONTROLLER];
        rdvc.parentGroupInfo = groupInfo;
        [self.navigationController pushViewController:rdvc animated:YES];
    }
}

- (void)tableTree:(TableTree *)tableTree loadLeavesUnderNode:(TableTreeNode *)parentNode onCompletion:(void(^)(NSArray *))completionBlock
{
    if ([RelationshipHelper respondsToSelector:@selector(tableTree:loadLeavesUnderNode:isHiddenTalkBtn:isHiddenPropertiesBtn:isHiddenTickBtn:onCompletion:)]) {
        [RelationshipHelper tableTree:tableTree loadLeavesUnderNode:parentNode isHiddenTalkBtn:YES isHiddenPropertiesBtn:YES isHiddenTickBtn:YES onCompletion:completionBlock];
    }
}

//- (NSComparisonResult)tableTree:(TableTree *)tableTree compareWithNode1:(TableTreeNode*)node1 node2:(TableTreeNode*)node2
//{
//    return [RelationshipHelper compareWithNode1:node1 node2:node2];
//}

- (void)tableTree:(TableTree *)tableTree sortNodes:(NSMutableArray *)nodes
{
    [RelationshipHelper sortNodes:nodes];
}


#pragma mark - UserInformationViewControllerDelegate

- (void)userInformationViewController:(UserInformationViewController *)viewController updateMemberInfo:(EBMemberInfo *)memberInfo dataObject:(id)dataObject
{
    TableTreeNode* node = dataObject;
    
    if (node && memberInfo) {
        node.data[@"memberInfo"] = memberInfo;
        node.name = memberInfo.userName;
        
        ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
        if (ebKit.accountInfo.uid == memberInfo.uid)
            node.name = [NSString stringWithFormat:@"%@[自己]", memberInfo.userName];
        
        __weak typeof(self) safeSelf = self;
        //执行刷新界面
        void(^refreshBlock)(void) = ^{
            BOOL inFirstLevel = (node.parentNodeId.length)?NO:YES;
            [safeSelf executeUpdateWithNode:node inFirstLevel:inFirstLevel inTree:safeSelf.helper.enterpriseTree];
            [safeSelf executeUpdateWithNode:node inFirstLevel:inFirstLevel inTree:safeSelf.helper.myDepartmentTree];
            [safeSelf executeUpdateWithNode:node inFirstLevel:inFirstLevel inTree:safeSelf.helper.personalGroupTree];
        };
        
        //加载头像文件，如超过1秒则暂时跳过设置头像步骤
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [ebKit loadHeadPhotoWithMemberInfo:memberInfo onCompletion:^(NSString *filePath) {
            NSLog(@"loadHeadPhotoWithMemberInfo success, filePath:%@", filePath);
            [BlockUtility performBlockInMainQueue:^{
                //设置Node的头像文件路径
                node.icon = filePath;
                refreshBlock();
            }];
            dispatch_semaphore_signal(sem);
        } onFailure:^(NSError *error) {
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC));
        
        refreshBlock();
    }
}

#pragma mark - GroupInformationViewControllerDelegate

- (void)groupInformationViewController:(GroupInformationViewController *)viewController updateGroup:(EBGroupInfo *)groupInfo dataObject:(id)dataObject
{
    TableTreeNode* srcNode = dataObject;
    
    if (srcNode && groupInfo && [srcNode.data objectForKey:@"type"] && [srcNode.data objectForKey:@"onlineCount"]) {
        TableTreeNode* groupNode = [RelationshipHelper treeNodeWithGroupInfo:groupInfo groupType:[srcNode.data[@"type"] intValue] onlineCountOfMembers:[srcNode.data[@"onlineCount"] intValue] isHiddenTalkBtn:srcNode.isHiddenTalkBtn isHiddenPropertiesBtn:srcNode.isHiddenPropertiesBtn isHiddenTickBtn:srcNode.isHiddenTickBtn isHiddenGroupTickBtn:srcNode.isHiddenTickBtn];
        
        BOOL inFirstLevel = (srcNode.parentNodeId.length)?NO:YES;
        
        [self executeUpdateWithNode:groupNode inFirstLevel:inFirstLevel inTree:self.helper.enterpriseTree];
        [self executeUpdateWithNode:groupNode inFirstLevel:inFirstLevel inTree:self.helper.myDepartmentTree];
        [self executeUpdateWithNode:groupNode inFirstLevel:inFirstLevel inTree:self.helper.personalGroupTree];
    }
}

#pragma mark - ContactInformationViewControllerDelegate

- (void)contactInformationViewController:(ContactInformationViewController*)viewController updateContactInfo:(EBContactInfo*)contactInfo dataObject:(id)dataObject
{
    TableTreeNode* srcNode = dataObject;
    
    if (srcNode && contactInfo) {
        TableTreeNode* conactNode = [RelationshipHelper treeNodeWithContactInfo:contactInfo outLeafCount:NULL isHiddenTalkBtn:srcNode.isHiddenTalkBtn isHiddenTickBtn:srcNode.isHiddenTickBtn];
        [self executeUpdateWithNode:conactNode inFirstLevel:NO inTree:self.helper.contactTree];
    }
}

#pragma mark - handleEvent

- (void)handleLogonCompletion:(EBAccountInfo *)accountInfo
{
    //更新成员在线状态
    [self updateMemberOnlineStatesInTree:self.helper.myDepartmentTree];
    [self updateMemberOnlineStatesInTree:self.helper.personalGroupTree];
    [self updateMemberOnlineStatesInTree:self.helper.enterpriseTree];
    [self updateContactOnlineStatesInTree:self.helper.contactTree];
    
    __weak typeof(self) safeSelf = self;
    //更新“我的部门”和“企业架构”部门的在线人数
    [[ENTBoostKit sharedToolKit] loadOnlineStateCountsOfEntGroupsOnCompletion:^(NSDictionary *countsOfGroupOnlineState) {
        [BlockUtility performBlockInMainQueue:^{
            [safeSelf.helper.myDepartmentTree updateCountsOfGroupOnlineState:countsOfGroupOnlineState];
            [safeSelf.helper.enterpriseTree updateCountsOfGroupOnlineState:countsOfGroupOnlineState];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"handleLogonCompletion->loadOnlineStateCountsOfEntGroups error, code = %@, msg = %@", @(error.code), error.localizedDescription);
    }];
    
    //更新“个人群组”的在线人数
    [[ENTBoostKit sharedToolKit] loadOnlineStateCountsOfPersonalGroupsOnCompletion:^(NSDictionary *countsOfGroupOnlineState) {
        [BlockUtility performBlockInMainQueue:^{
            [safeSelf.helper.personalGroupTree updateCountsOfGroupOnlineState:countsOfGroupOnlineState];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"handleLogonCompletion->loadOnlineStateCountsOfPersonalGroups error, code = %@, msg = %@", @(error.code), error.localizedDescription);
    }];
    
    //更新"好友"待定
    
    //深层视图响应
    for (RelationshipDeepInViewController* vc in [self relationshipDeepInViewControllers]) {
        [vc handleLogonCompletion:accountInfo];
    }
}

//获取当前弹出的深层联系人Controller
- (NSArray*)relationshipDeepInViewControllers
{
    NSArray* viewControllers = self.navigationController.viewControllers;
    __block NSMutableArray* array = [[NSMutableArray alloc] init];
    [BlockUtility syncPerformBlockInMainQueue:^{
        for (UIViewController* vc in viewControllers) {
            if ([vc isMemberOfClass:[RelationshipDeepInViewController class]]) {
                [array addObject:vc];
            }
        }
    }];
    return array;
}

- (void)handleAddorUpdateMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    NSString* groupCode = [NSString stringWithFormat:@"%llu", groupInfo.depCode];
    __weak typeof(self) safeSelf = self;
    
    [BlockUtility performBlockInGlobalQueue:^{
        //延迟3秒后加载在线人数并更新视图
        [NSThread sleepForTimeInterval:3.0];
        
        NSInteger countOfGroupOLS = [RelationshipHelper loadOnlineStateCountsOfGroupsWithDepCode:groupInfo.depCode];
        
        //==========更新联系人视图
        //企业架构
        if ([safeSelf.helper.enterpriseTree isNodeExists:groupCode] || (groupInfo.parentCode && [safeSelf.helper.enterpriseTree isNodeExists:[NSString stringWithFormat:@"%llu", groupInfo.parentCode]])) {//1.部门已存在； 2.当前部门不存在但更上一级的部门存在
            [safeSelf updateTree:safeSelf.helper.enterpriseTree usingMemberInfo:memberInfo groupInfo:groupInfo groupType:RELATIONSHIP_TYPE_ENTGROUP onlineCountOfMembers:countOfGroupOLS isRemove:NO];
            
            //更新企业架构视图标题
            [safeSelf.helper updateSelectedViewLabelOfEnterpriseView];
        }
        
        //个人群组
        if ([safeSelf.helper.personalGroupTree isNodeExists:groupCode] || (groupInfo.myEmpCode && !groupInfo.entCode)) {//1.群组已存在； 2.当前用户被加人个人群组
            [safeSelf updateTree:safeSelf.helper.personalGroupTree usingMemberInfo:memberInfo groupInfo:groupInfo groupType:RELATIONSHIP_TYPE_PERSONALGROUP onlineCountOfMembers:countOfGroupOLS isRemove:NO];
        }
        
        //我的部门
        if ([safeSelf.helper.myDepartmentTree isNodeExists:groupCode] || (groupInfo.myEmpCode && groupInfo.entCode)) { //1.部门已存在； 2.当前用户被增加进部门
            [safeSelf updateTree:safeSelf.helper.myDepartmentTree usingMemberInfo:memberInfo groupInfo:groupInfo groupType:RELATIONSHIP_TYPE_MYDEPARTMENT onlineCountOfMembers:countOfGroupOLS isRemove:NO];
        }
        
        //    _contactTree;
        
        //深层视图响应
        for (RelationshipDeepInViewController* vc in [safeSelf relationshipDeepInViewControllers]) {
            [vc handleAddMember:memberInfo toGroup:groupInfo onlineCountOfMembers:countOfGroupOLS fromUid:fromUid fromAccount:fromAccount];
        }
    }];
}

- (void)handleAddMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    [self handleAddorUpdateMember:memberInfo toGroup:groupInfo fromUid:fromUid fromAccount:fromAccount];
}

- (void)handleUpdateMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    [self handleAddorUpdateMember:memberInfo toGroup:groupInfo fromUid:fromUid fromAccount:fromAccount];
}

- (void)handleExitMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount passive:(BOOL)passive targetIsMe:(BOOL)targetIsMe
{
    //==========更新联系人视图
    NSString* groupCode = [NSString stringWithFormat:@"%llu", groupInfo.depCode];
    __weak typeof(self) safeSelf = self;
    
    //定义更新树视图的模块
    void(^updateTreeBlock)(TableTree* tree, RELATIONSHIP_TYPE groupType, NSInteger onlineCountOfMembers) = ^(TableTree* tree, RELATIONSHIP_TYPE groupType, NSInteger onlineCountOfMembers) {
        if ([tree isNodeExists:groupCode]) {
            //删除成员节点
            [safeSelf updateTree:tree usingMemberInfo:memberInfo groupInfo:groupInfo groupType:groupType onlineCountOfMembers:onlineCountOfMembers isRemove:YES];
            
            //如果退出的是当前用户，则删除"我的部门"节点
            if (targetIsMe) {
                [BlockUtility performBlockInMainQueue:^{
                    [tree removeNodeWithId:[NSString stringWithFormat:@"%llu", groupInfo.depCode] updateParentNodeLoadedState:YES];
                }];
            }
        }
    };
    
    [BlockUtility performBlockInGlobalQueue:^{
        //延迟3秒后加载在线人数并更新视图
        [NSThread sleepForTimeInterval:3.0];
        
        NSInteger countOfGroupOLS = [RelationshipHelper loadOnlineStateCountsOfGroupsWithDepCode:groupInfo.depCode];
        
        //企业架构
        if ([safeSelf.helper.enterpriseTree isNodeExists:groupCode]) {
            //删除成员节点
            [safeSelf updateTree:safeSelf.helper.enterpriseTree usingMemberInfo:memberInfo groupInfo:groupInfo groupType:RELATIONSHIP_TYPE_ENTGROUP onlineCountOfMembers:countOfGroupOLS isRemove:YES];
            //更新企业架构视图标题
            [safeSelf.helper updateSelectedViewLabelOfEnterpriseView];
        }
        
        updateTreeBlock(safeSelf.helper.personalGroupTree, RELATIONSHIP_TYPE_PERSONALGROUP, countOfGroupOLS); //个人群组
        updateTreeBlock(safeSelf.helper.myDepartmentTree, RELATIONSHIP_TYPE_MYDEPARTMENT, countOfGroupOLS); //我的部门
        
        //深层视图响应
        for (RelationshipDeepInViewController* vc in [safeSelf relationshipDeepInViewControllers]) {
            [vc handleExitMember:memberInfo toGroup:groupInfo onlineCountOfMembers:countOfGroupOLS fromUid:fromUid fromAccount:fromAccount passive:passive];
        }
    }];
}

- (void)handleUpdateGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInGlobalQueue:^{
        NSInteger countOfGroupOLS = [RelationshipHelper loadOnlineStateCountsOfGroupsWithDepCode:groupInfo.depCode];
        
        //企业部门
        if (groupInfo.entCode) {
            TableTreeNode* groupNode = [RelationshipHelper treeNodeWithGroupInfo:groupInfo groupType:RELATIONSHIP_TYPE_ENTGROUP onlineCountOfMembers:countOfGroupOLS isHiddenTalkBtn:YES isHiddenPropertiesBtn:NO isHiddenTickBtn:YES isHiddenGroupTickBtn:YES];
            [BlockUtility performBlockInMainQueue:^{
                //更新企业架构视图
                [safeSelf.helper.enterpriseTree insertOrUpdateWithNode:groupNode inFirstLevel:groupInfo.parentCode?NO:YES];
                [safeSelf.helper.enterpriseTree sortNodesOfSameGroupWithNodeId:groupNode.nodeId];
                //更新企业架构视图标题
                [safeSelf.helper updateSelectedViewLabelOfEnterpriseView];
            }];
            
            //更新"我的部门"视图
            if (groupInfo.myEmpCode) {
                TableTreeNode* myGroupNode = [RelationshipHelper treeNodeWithGroupInfo:groupInfo groupType:RELATIONSHIP_TYPE_MYDEPARTMENT onlineCountOfMembers:countOfGroupOLS isHiddenTalkBtn:YES isHiddenPropertiesBtn:NO isHiddenTickBtn:YES isHiddenGroupTickBtn:YES];
                [BlockUtility performBlockInMainQueue:^{
                    [safeSelf.helper.myDepartmentTree insertOrUpdateWithNode:myGroupNode inFirstLevel:YES];
                    [safeSelf.helper.myDepartmentTree sortNodesOfSameGroupWithNodeId:myGroupNode.nodeId];
                }];
            }
        }
        //个人群组
        else {
            TableTreeNode* groupNode = [RelationshipHelper treeNodeWithGroupInfo:groupInfo groupType:RELATIONSHIP_TYPE_PERSONALGROUP onlineCountOfMembers:countOfGroupOLS isHiddenTalkBtn:YES isHiddenPropertiesBtn:NO isHiddenTickBtn:YES isHiddenGroupTickBtn:YES];
            [BlockUtility performBlockInMainQueue:^{
                [safeSelf.helper.personalGroupTree insertOrUpdateWithNode:groupNode inFirstLevel:YES];
                [safeSelf.helper.personalGroupTree sortNodesOfSameGroupWithNodeId:groupNode.nodeId];
            }];
        }
        
        //深层视图响应
        for (RelationshipDeepInViewController* vc in [safeSelf relationshipDeepInViewControllers]) {
            [vc handleUpdateGroup:groupInfo onlineCountOfMembers:countOfGroupOLS fromUid:fromUid fromAccount:fromAccount];
        }
    }];
}

- (void)handleDeleteGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    __weak typeof(self) safeSelf = self;
    //企业部门
    if (groupInfo.entCode) {
        [BlockUtility performBlockInMainQueue:^{
            [safeSelf.helper.enterpriseTree removeNodeWithId:[NSString stringWithFormat:@"%llu", groupInfo.depCode] updateParentNodeLoadedState:YES];
            //更新企业架构视图标题
            [safeSelf.helper updateSelectedViewLabelOfEnterpriseView];
        }];
    }
    //个人群组
    else {
        [BlockUtility performBlockInMainQueue:^{
            [safeSelf.helper.personalGroupTree removeNodeWithId:[NSString stringWithFormat:@"%llu", groupInfo.depCode] updateParentNodeLoadedState:YES];
        }];
    }
    
    //深层视图响应
    for (RelationshipDeepInViewController* vc in [self relationshipDeepInViewControllers]) {
        [vc handleDeleteGroup:groupInfo fromUid:fromUid fromAccount:fromAccount];
    }
}

- (void)handleAddTempGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInGlobalQueue:^{
        //延迟3秒后加载在线人数并更新视图
        [NSThread sleepForTimeInterval:3.0];
        
        NSInteger countOfGroupOLS = [RelationshipHelper loadOnlineStateCountsOfGroupsWithDepCode:groupInfo.depCode];
        
        //个人群组
        if (![safeSelf.helper.personalGroupTree isNodeExists:[NSString stringWithFormat:@"%llu", groupInfo.depCode]]) {
            [safeSelf updateTree:safeSelf.helper.personalGroupTree usingMemberInfo:nil groupInfo:groupInfo groupType:RELATIONSHIP_TYPE_PERSONALGROUP onlineCountOfMembers:countOfGroupOLS isRemove:NO];
        }
        //讨论组没有深层视图
    }];
}

- (void)handleAddContactAccept:(EBContactInfo *)conactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard
{
    [self updateTree:self.helper.contactTree usingContactInfo:conactInfo isRemove:NO];
}

- (void)handleDeleteContact:(EBContactInfo *)contactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount isBothDeleted:(BOOL)isBothDeleted
{
    [self updateTree:self.helper.contactTree usingContactInfo:contactInfo isRemove:YES];
}

- (void)handleBeDeletedContact:(EBContactInfo *)contactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard isBothDeleted:(BOOL)isBothDeleted
{
    if (isBothDeleted) {
        [self updateTree:self.helper.contactTree usingContactInfo:contactInfo isRemove:YES];
    } else {
        [self updateTree:self.helper.contactTree usingContactInfo:contactInfo isRemove:NO];
    }
}

- (void)handleUserChangeLineState:(EB_USER_LINE_STATE)userLineState fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount inEntGroups:(NSArray *)entGroupIds inPersonalGroups:(NSArray *)personalGroupIds
{
    __weak typeof(self) safeSelf = self;
    
    [BlockUtility performBlockInMainQueue:^{
        //更新成员在线状态
        [safeSelf.helper.myDepartmentTree updateMemberOnlineState:userLineState forUid:fromUid];
        [safeSelf.helper.personalGroupTree updateMemberOnlineState:userLineState forUid:fromUid];
        [safeSelf.helper.enterpriseTree updateMemberOnlineState:userLineState forUid:fromUid];
        [safeSelf.helper updateSelectedViewLabelOfEnterpriseView]; //更新企业架构视图标题
        
        //更新联系人在线人数，必须在[updateMemberOnlineState:forUid]之前执行，否则不能正确更新
        [safeSelf.helper.contactTree updateOnlineStateCountOfGroupWithUserLineState:userLineState forContactUid:fromUid];
        //更新联系人在线状态
        [safeSelf.helper.contactTree updateMemberOnlineState:userLineState forUid:fromUid];
    }];
    
    //更新部门在线人数
    for (NSNumber* depCodeNum in entGroupIds) {
        uint64_t depCode = [depCodeNum unsignedLongLongValue];
        [[ENTBoostKit sharedToolKit] loadOnlineStateCountOfGroupsWithDepCode:depCode onCompletion:^(NSInteger countOfGroupOnlineState) {
            [BlockUtility performBlockInMainQueue:^{
                [safeSelf.helper.myDepartmentTree updateCountOfGroupOnlineState:countOfGroupOnlineState forGroupNodeId:[NSString stringWithFormat:@"%llu", depCode]];
                [safeSelf.helper.enterpriseTree updateCountOfGroupOnlineState:countOfGroupOnlineState forGroupNodeId:[NSString stringWithFormat:@"%llu", depCode]];
            }];
        } onFailure:^(NSError *error) {
            NSLog(@"handleUserChangeLineState->loadOnlineStateCountOfGroupsWithDepCode:%llu error, code = %@, msg = %@", depCode, @(error.code), error.localizedDescription);
        }];
    }
    
    //更新群组在线人数
    for (NSNumber* depCodeNum in personalGroupIds) {
        uint64_t depCode = [depCodeNum unsignedLongLongValue];
        [[ENTBoostKit sharedToolKit] loadOnlineStateCountOfGroupsWithDepCode:depCode onCompletion:^(NSInteger countOfGroupOnlineState) {
            [BlockUtility performBlockInMainQueue:^{
                [safeSelf.helper.personalGroupTree updateCountOfGroupOnlineState:countOfGroupOnlineState forGroupNodeId:[NSString stringWithFormat:@"%llu", depCode]];
            }];
        } onFailure:^(NSError *error) {
            NSLog(@"handleUserChangeLineState->loadOnlineStateCountOfGroupsWithDepCode:%llu error, code = %@, msg = %@", depCode, @(error.code), error.localizedDescription);
        }];
    }
    
    //深层视图响应
    for (RelationshipDeepInViewController* vc in [self relationshipDeepInViewControllers]) {
        [vc handleUserChangeLineState:userLineState fromUid:fromUid fromAccount:fromAccount inEntGroups:entGroupIds];
    }
}

@end
