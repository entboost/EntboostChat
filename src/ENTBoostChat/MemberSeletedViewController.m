//
//  MemberSeletedViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/20.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "MemberSeletedViewController.h"
#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "RelationshipHelper.h"
#import "TableTreeNode.h"
#import "BlockUtility.h"
#import "ENTBoost+Utility.h"
#import "CustomSeparator.h"
#import "FVCustomAlertView.h"
#import "MemberSelectedDeepInViewController.h"
#import "ButtonKit.h"
#import "AppDelegate.h"


@interface MemberSeletedViewController ()
{
    BOOL _isInited; //是否已经执行过初始化
    UIStoryboard* _contactStoryobard;
}

@property(nonatomic, strong) RelationshipHelper* helper; //联系人视图辅助实例

@property(nonatomic, strong) IBOutlet UIView* toolbar; //顶上仿工具栏视图
@property(nonatomic, strong) IBOutlet CustomSeparator* toolbarBottomBorder; //仿工具栏下边框
@property(nonatomic, strong) IBOutlet UIView* treeContainer; //树显示容器

@property(nonatomic, strong) IBOutlet UIButton* myDepartmentBtn; //"我的部门"按钮
@property(nonatomic, strong) IBOutlet UIButton* contactBtn; //"通讯录"按钮
@property(nonatomic, strong) IBOutlet UIButton* personalGroupBtn; //"个人群组"按钮
@property(nonatomic, strong) IBOutlet UIButton* enterpriseBtn; //"组织架构"按钮
@property(nonatomic, strong) IBOutlet UIView* floatMarkedLine; //标记线

@property(nonatomic, strong) IBOutlet CustomSeparator* selectedViewBottomBorder; //当前选中
@property(nonatomic, strong) IBOutlet UILabel* selectedViewLabel; //当前选中视图标题显示控件

@end

@implementation MemberSeletedViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _contactStoryobard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_CONTACT bundle:nil];
        
        //注册接收通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inviteMembers:) name:EB_CHAT_NOTIFICATION_INVITE_MEMBER object:nil]; //邀请成员加入群组
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏
    [self initNavigationBar];
    
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
        [self.helper fillTreesWithIsHiddenTalkBtn:YES isHiddenPropertiesBtn:YES isHiddenTickBtn:NO isHiddenGroupTickBtn:YES];
        //设置当前选中标记线位置
        [self.helper setSelectedButtonAtIndex:0];
    }
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //移除接收通知的注册
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EB_CHAT_NOTIFICATION_INVITE_MEMBER object:nil]; //邀请成员加入群组
}

//设置导航栏
- (void)initNavigationBar
{
    //设置标题
    self.navigationItem.title = @"选择成员";
    
    self.navigationItem.leftBarButtonItem   = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    self.navigationItem.rightBarButtonItem  = [ButtonKit saveBarButtonItemWithTarget:self action:@selector(saveMembers)];
}

//返回上一级
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveMembers
{
    NSMutableArray* nodes = [[NSMutableArray alloc] init];
    //获取深层界面勾选的成员
    NSArray* controllers = [self.navigationController viewControllers];
    for (NSUInteger i=0; i< controllers.count; i++) {
        UIViewController* controller = controllers[i];
        if ([controller isMemberOfClass:[MemberSelectedDeepInViewController class]]) {
            [nodes addObjectsFromArray:[((MemberSelectedDeepInViewController*)controller) tickCheckedNodes]];
        }
    }
    //获取当前界面勾选的成员
    [nodes addObjectsFromArray:[self.helper tickCheckedNodes]];
    
    NSMutableDictionary* members = [[NSMutableDictionary alloc] init];
    //过滤重复的UID
    for (TableTreeNode* node in nodes) {
        RELATIONSHIP_TYPE type = ((NSNumber*)node.data[@"type"]).shortValue;
        if (type==RELATIONSHIP_TYPE_MEMBER) {
            EBMemberInfo* memberInfo = node.data[@"memberInfo"];
            members[@(memberInfo.uid)] = memberInfo.userName;
        } else if (type==RELATIONSHIP_TYPE_CONTACT) {
            EBContactInfo* contactInfo = node.data[@"contactInfo"];
            if (contactInfo.uid)
                members[@(contactInfo.uid)] = contactInfo.name?contactInfo.name:contactInfo.account;
        }
    }
    
    [self.navigationController popToViewController:self animated:NO];
    
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    EBGroupInfo* targetGroupInfo = self.targetGroupInfo;
    EBAccountInfo* accountInfo = ebKit.accountInfo;
    
    //显示提示框
    ShowAlertView();
    
    //发起邀请
    __weak typeof(self) weakSelf = self;
    __weak id delegate = self.delegate;
    NSLog(@"邀请%@人加入群组", @(members.count));
    for (NSNumber* uidNum in members) {
        uint64_t uid = [uidNum unsignedLongLongValue];
        NSString* name = members[uidNum];
        NSString* prefix = [NSString stringWithFormat:@"邀请'%@'[%@]", name, uidNum];
        
        if (targetGroupInfo.type==EB_GROUP_TYPE_DEPARTMENT || targetGroupInfo.type==EB_GROUP_TYPE_PROJECT) { //部门或项目组
            EBMemberInfo* memberInfo = [[EBMemberInfo alloc] initWithEmpCode:0 depCode:targetGroupInfo.depCode uid:uid empAccount:nil userName:name gender:EB_GENDER_UNKNOWN birthday:nil jobTitle:nil jobPosition:0 cellPhone:nil fax:nil workPhone:nil email:nil address:nil descri:nil managerLevel:0 csExt:0 csId:0];
            [ebKit createMemberInfo:memberInfo onCompletion:^(uint64_t empCode, uint64_t empUid, EB_USER_LINE_STATE userLineState) {
                NSLog(@"%@成功, empCode = %llu, empUid = %llu, userLineState = %i", prefix, empCode, empUid, userLineState);
                //加载目标成员信息
                [ebKit loadMemberInfoWithEmpCode:empCode onCompletion:^(EBMemberInfo *memberInfo) {
                    NSLog(@"创建部门或项目组新成员的虚拟事件, empCode = %llu, depCode = %llu", empCode, targetGroupInfo.depCode);
                    [appDelegate onAddMember:memberInfo toGroup:[ebKit groupInfoWithDepCode:targetGroupInfo.depCode] fromUid:accountInfo.uid fromAccount:accountInfo.account];
                    
                    //触发上层事件
                    [BlockUtility performBlockInMainQueue:^{
//                        __strong typeof(weakSelf) safeSelf = weakSelf;
                        if ([delegate respondsToSelector:@selector(memberSeletedViewController:saveInvitedMember:)])
                            [delegate memberSeletedViewController:weakSelf saveInvitedMember:memberInfo];
                    }];
                } onFailure:^(NSError *error) {
                    NSLog(@"加载成员失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
                }];
            } onFailure:^(NSError *error) {
                NSLog(@"创建成员失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
            }];
        } else if (targetGroupInfo.type==EB_GROUP_TYPE_GROUP || targetGroupInfo.type==EB_GROUP_TYPE_TEMP) { //个人群组或临时讨论组
            [ebKit inviteMemberWithAccount:nil orUid:uid toGroup:targetGroupInfo.depCode description:ebKit.isInviteAdd2GroupNeedVerification?[NSString stringWithFormat:@"请加入'%@'",targetGroupInfo.depName]:nil onCompletion:^(uint64_t empCode, uint64_t empUid, EB_USER_LINE_STATE userLineState) {
                NSLog(@"%@成功, empCode = %llu, empUid = %llu, userLineState = %i", prefix, empCode, empUid, userLineState);
                //加载目标成员信息
                [ebKit loadMemberInfoWithEmpCode:empCode onCompletion:^(EBMemberInfo *memberInfo) {
                    NSLog(@"创建个人群组或临时讨论组新成员的虚拟事件, empCode = %llu, depCode = %llu", empCode, targetGroupInfo.depCode);
                    [appDelegate onAddMember:memberInfo toGroup:[ebKit groupInfoWithDepCode:targetGroupInfo.depCode] fromUid:accountInfo.uid fromAccount:accountInfo.account];
                    
//                    [NSThread sleepForTimeInterval:10.0]; //测试
                    //触发上层事件
                    [BlockUtility performBlockInMainQueue:^{
//                        __strong typeof(weakSelf) safeSelf = weakSelf;
                        if ([delegate respondsToSelector:@selector(memberSeletedViewController:saveInvitedMember:)])
                            [delegate memberSeletedViewController:weakSelf saveInvitedMember:memberInfo];
                    }];
                } onFailure:^(NSError *error) {
                    NSLog(@"加载成员失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
                }];
            } inviteSent:^{
                NSLog(@"已发出%@", prefix);
            } onFailure:^(NSError *error) {
                NSLog(@"%@失败，code = %@, msg = %@", prefix, @(error.code), error.localizedDescription);
            }];
        }
        
        [NSThread sleepForTimeInterval:0.1];
    }
    
    [self goBack];
    //关闭提示框
    CloseAlertView();
}

//邀请成员
- (void)inviteMembers:(NSNotification*)notif
{
    [self saveMembers];
}

#pragma mark - TableTreeDelegate
- (void)tableTree:(TableTree *)tableTree deepInToNode:(TableTreeNode *)node
{
    EBGroupInfo* groupInfo;
    if ([RelationshipHelper tableTree:tableTree deepInToNode:node groupInfo:&groupInfo]) {
        MemberSelectedDeepInViewController* mdvc = [_contactStoryobard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_MEMBER_SELECTED_DEEPIN_CONTROLLER];
        mdvc.parentGroupInfo = groupInfo;
        mdvc.targetGroupInfo = self.targetGroupInfo;
        [self.navigationController pushViewController:mdvc animated:YES];
    }
}

- (void)tableTree:(TableTree *)tableTree loadLeavesUnderNode:(TableTreeNode *)parentNode onCompletion:(void(^)(NSArray *))completionBlock
{
    if ([RelationshipHelper respondsToSelector:@selector(tableTree:loadLeavesUnderNode:isHiddenTalkBtn:isHiddenPropertiesBtn:isHiddenTickBtn:onCompletion:)]) {
        [RelationshipHelper tableTree:tableTree loadLeavesUnderNode:parentNode isHiddenTalkBtn:YES isHiddenPropertiesBtn:YES isHiddenTickBtn:NO onCompletion:completionBlock];
    }
}

@end
