//
//  RelationshipDeepInViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/25.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "RelationshipDeepInViewController.h"
#import "ENTBoostChat.h"
#import "ENTBoost.h"
#import "RelationshipHelper.h"
#import "ENTBoost+Utility.h"
#import "BlockUtility.h"
#import "CustomSeparator.h"
#import "FVCustomAlertView.h"
#import "ControllerManagement.h"
#import "UserInformationViewController.h"
#import "GroupInformationViewController.h"
#import "ButtonKit.h"

@interface RelationshipDeepInViewController () <GroupInformationViewControllerDelegate, UserInformationViewControllerDelegate>
{
    BOOL _isInited; //是否已经执行过初始化
    TableTree *_enterpriseTree; //企业组织架构
    UIStoryboard* _mainStoryobard;
}

@property(nonatomic, strong) IBOutlet UIView* toolbar; //顶上仿工具栏视图
@property(nonatomic, strong) IBOutlet CustomSeparator* toobarVerticalBorder; //竖线
@property(nonatomic, strong) IBOutlet CustomSeparator* toolbarBottomBorder; //仿工具栏下边框
@property(nonatomic, strong) IBOutlet UIView* treeContainer; //树显示容器

@property(nonatomic, strong) IBOutlet UIButton* gotoLastButton; //返回上一级按钮
@property(nonatomic, strong) IBOutlet UIButton* gotoTopButton; //返回最顶级按钮
@end

@implementation RelationshipDeepInViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _mainStoryobard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_MAIN bundle:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航栏
    [self initNavigationBar];
    //设置工具栏
    [self initToolbar];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //保证只执行一次初始化
    if (!_isInited) {
        //显示提示框
        ShowAlertView();
        
        _isInited = YES;
        __weak typeof(self) safeSelf = self;
        [RelationshipHelper loadNodesInGroup:self.parentGroupInfo tableTree:_enterpriseTree isHiddenTalkBtn:YES isHiddenPropertiesBtn:NO isHiddenTickBtn:YES isHiddenGroupTickBtn:YES onCompletion:^(NSArray *nodes) {
//            UIColor* backgroundColor = [UIColor colorWithHexString:@"#effafe"];
            CGRect rect = CGRectMake(0, 0, safeSelf.treeContainer.bounds.size.width, safeSelf.treeContainer.bounds.size.height);
            
            _enterpriseTree = [[TableTree alloc] initWithFrame:rect nodes:nodes];
            _enterpriseTree.deepInLevel = 0;
            _enterpriseTree.delegate = safeSelf;
            [_enterpriseTree setBackgroundColor:EBCHAT_DEFAULT_BLANK_COLOR];
            [safeSelf.treeContainer addSubview:_enterpriseTree];
            
            //关闭提示框
            CloseAlertView();
        } failureBlock:^(NSError *error) {
            //关闭提示框
            CloseAlertView();
        }];
    }
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置导航栏
- (void)initNavigationBar
{
    //设置标题
    self.navigationItem.title = self.parentGroupInfo.depName;
    
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
//    self.navigationItem.rightBarButtonItems = @[rightButton2, rightButton1];
}

//设置工具栏
- (void)initToolbar
{
    UIColor* borderColor = EBCHAT_DEFAULT_BORDER_CORLOR; //[UIColor colorWithHexString:@"#c5e1ec"]; //定义边框颜色
    self.toolbarBottomBorder.color1 = borderColor; //设置仿工具栏下边框颜色
    self.toolbarBottomBorder.lineHeight1 = 1.0f; //设置仿工具栏下边框高度
    self.toobarVerticalBorder.color1 = borderColor; //工具栏中间竖线颜色
    self.toobarVerticalBorder.lineHeight1 = self.toolbar.bounds.size.height; //工具栏中间竖线高度
    
    //添加触发事件处理方法
    [self.gotoLastButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.gotoTopButton addTarget:self action:@selector(goTop) forControlEvents:UIControlEventTouchUpInside];
}

//返回上一级
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//返回最顶级
- (void)goTop
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//- (void)search
//{
//    
//}
//
//- (void)showMenu
//{
//    
//}

#pragma mark - Update Tree

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
    
    //构造上层部门节点
    TableTreeNode* groupNode = [RelationshipHelper treeNodeWithGroupInfo:groupInfo groupType:groupType onlineCountOfMembers:onlineCountOfMembers isHiddenTalkBtn:NO isHiddenPropertiesBtn:NO isHiddenTickBtn:YES isHiddenGroupTickBtn:YES];
    BOOL inFirstLevel = (groupInfo.parentCode==self.parentGroupInfo.depCode)?YES:NO;
    
    if (!isRemove) {
        //新增或更新群组(部门)节点
        [BlockUtility performBlockInMainQueue:^{
            [tree insertOrUpdateWithNode:groupNode inFirstLevel:inFirstLevel];
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
            
            __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            [[ENTBoostKit sharedToolKit] loadHeadPhotoWithMemberInfo:memberInfo onCompletion:^(NSString *filePath) {
                NSLog(@"head photo filePath:%@", filePath);
                [BlockUtility performBlockInMainQueue:^{
                    //设置Node的头像文件路径
                    memberNode.icon = filePath;
                    //如果上级函数已经返回才需要刷新视图
                    if (isReturn) {
                        [tree reloadData];
                    }
                }];
                dispatch_semaphore_signal(sem);
            } onFailure:^(NSError *error) {
//                NSLog(@"loadHeadPhotoWithMemberInfo error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            }];
            
            dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC));
            
            //回调返回结果集
            [BlockUtility performBlockInMainQueue:^{
                [tree insertOrUpdateWithNode:memberNode inFirstLevel:YES];
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

#pragma mark - TableTreeDelegate

- (void)tableTree:(TableTree *)tableTree deepInToNode:(TableTreeNode *)node
{
    EBGroupInfo* groupInfo;
    if ([RelationshipHelper tableTree:tableTree deepInToNode:node groupInfo:&groupInfo]) {
        RelationshipDeepInViewController* rdvc = [_mainStoryobard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_RELATIONSHIP_DEEPIN_CONTROLLER];
        rdvc.parentGroupInfo = groupInfo;
        [self.navigationController pushViewController:rdvc animated:YES];
    }
}

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

- (void)tableTree:(TableTree *)tableTree loadLeavesUnderNode:(TableTreeNode *)parentNode onCompletion:(void(^)(NSArray *))completionBlock
{
    if ([RelationshipHelper respondsToSelector:@selector(tableTree:loadLeavesUnderNode:isHiddenTalkBtn:isHiddenPropertiesBtn:isHiddenTickBtn:onCompletion:)]) {
        [RelationshipHelper tableTree:tableTree loadLeavesUnderNode:parentNode isHiddenTalkBtn:YES isHiddenPropertiesBtn:YES isHiddenTickBtn:YES onCompletion:completionBlock];
    }
}

- (void)tableTree:(TableTree *)tableTree sortNodes:(NSMutableArray *)nodes
{
    [RelationshipHelper sortNodes:nodes];
}

#pragma mark - UserInformationViewControllerDelegate

- (void)userInformationViewController:(UserInformationViewController *)viewController updateMemberInfo:(EBMemberInfo *)memberInfo dataObject:(id)dataObject
{
    TableTreeNode* srcNode = dataObject;
    
    if (srcNode && memberInfo) {
        srcNode.data[@"memberInfo"] = memberInfo;
        srcNode.name = memberInfo.userName;
        if ([ENTBoostKit sharedToolKit].accountInfo.uid == memberInfo.uid)
            srcNode.name = [NSString stringWithFormat:@"%@[自己]", memberInfo.userName];
        
        BOOL inFirstLevel = (srcNode.parentNodeId.length)?NO:YES;
        
        [self executeUpdateWithNode:srcNode inFirstLevel:inFirstLevel inTree:_enterpriseTree];
    }
}

#pragma mark - GroupInformationViewControllerDelegate

- (void)groupInformationViewController:(GroupInformationViewController *)viewController updateGroup:(EBGroupInfo *)groupInfo dataObject:(id)dataObject
{
    TableTreeNode* srcNode = dataObject;
    
    if (srcNode && groupInfo && [srcNode.data objectForKey:@"type"] && [srcNode.data objectForKey:@"onlineCount"]) {
        TableTreeNode* groupNode = [RelationshipHelper treeNodeWithGroupInfo:groupInfo groupType:[srcNode.data[@"type"] intValue] onlineCountOfMembers:[srcNode.data[@"onlineCount"] intValue] isHiddenTalkBtn:srcNode.isHiddenTalkBtn isHiddenPropertiesBtn:srcNode.isHiddenPropertiesBtn isHiddenTickBtn:srcNode.isHiddenTickBtn isHiddenGroupTickBtn:srcNode.isHiddenTickBtn];
        
        BOOL inFirstLevel = (srcNode.parentNodeId.length)?NO:YES;
        
        [self executeUpdateWithNode:groupNode inFirstLevel:inFirstLevel inTree:_enterpriseTree];
    }
}


#pragma mark - handleEvent
- (void)handleLogonCompletion:(EBAccountInfo *)accountInfo
{
    //更新成员在线状态
    [[ENTBoostKit sharedToolKit] loadOnlineStateOfMembersWithDepCode:self.parentGroupInfo.depCode onCompletion:^(NSDictionary *onlineStates, uint64_t depCode) {
        [BlockUtility performBlockInMainQueue:^{
            [_enterpriseTree updateMemberOnlineStates:onlineStates];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"加载成员状态失败，depCode = %llu, code = %@, msg = %@", self.parentGroupInfo.depCode, @(error.code), error.localizedDescription);
    }];

    //更新在线人数
    [[ENTBoostKit sharedToolKit] loadOnlineStateCountsOfEntGroupsOnCompletion:^(NSDictionary *countsOfGroupOnlineState) {
        [BlockUtility performBlockInMainQueue:^{
            [_enterpriseTree updateCountsOfGroupOnlineState:countsOfGroupOnlineState];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"deepin handleLogonCompletion->loadOnlineStateCountsOfEntGroups error, code = %@, msg = %@", @(error.code), error.localizedDescription);
    }];
}

- (void)handleAddMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo onlineCountOfMembers:(NSInteger)onlineCountOfMembers fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    if (groupInfo.depCode == self.parentGroupInfo.depCode) {
        [self updateTree:_enterpriseTree usingMemberInfo:memberInfo groupInfo:groupInfo groupType:RELATIONSHIP_TYPE_ENTGROUP onlineCountOfMembers:onlineCountOfMembers isRemove:NO];
    }
    
    //如果已经存在该群组，则更新该群组资料
    NSString* groupNodeId = [NSString stringWithFormat:@"%llu", groupInfo.depCode];
    if ([_enterpriseTree isNodeExists:groupNodeId]) {
        TableTreeNode* groupNode = [RelationshipHelper treeNodeWithGroupInfo:groupInfo groupType:RELATIONSHIP_TYPE_ENTGROUP onlineCountOfMembers:onlineCountOfMembers isHiddenTalkBtn:NO isHiddenPropertiesBtn:NO isHiddenTickBtn:YES isHiddenGroupTickBtn:YES];
        [BlockUtility performBlockInMainQueue:^{
            [_enterpriseTree insertOrUpdateWithNode:groupNode inFirstLevel:YES];
        }];
    }
}

- (void)handleExitMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo onlineCountOfMembers:(NSInteger)onlineCountOfMembers fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount passive:(BOOL)passive
{
    NSString* groupCode = [NSString stringWithFormat:@"%llu", groupInfo.depCode];
    if ([_enterpriseTree isNodeExists:groupCode] || self.parentGroupInfo.depCode == groupInfo.depCode) {
        [self updateTree:_enterpriseTree usingMemberInfo:memberInfo groupInfo:groupInfo groupType:RELATIONSHIP_TYPE_ENTGROUP onlineCountOfMembers:onlineCountOfMembers isRemove:YES];
    }
}

- (void)handleUpdateGroup:(EBGroupInfo *)groupInfo onlineCountOfMembers:(NSInteger)onlineCountOfMembers fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    if (groupInfo.parentCode == self.parentGroupInfo.depCode) {
        TableTreeNode* groupNode = [RelationshipHelper treeNodeWithGroupInfo:groupInfo groupType:RELATIONSHIP_TYPE_ENTGROUP onlineCountOfMembers:onlineCountOfMembers isHiddenTalkBtn:YES isHiddenPropertiesBtn:NO isHiddenTickBtn:YES isHiddenGroupTickBtn:YES];
        [BlockUtility performBlockInMainQueue:^{
            [_enterpriseTree insertOrUpdateWithNode:groupNode inFirstLevel:YES];
            [_enterpriseTree sortNodesOfSameGroupWithNodeId:groupNode.nodeId];
        }];
    }
}

- (void)handleDeleteGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    if (groupInfo.parentCode == self.parentGroupInfo.depCode) {
        [BlockUtility performBlockInMainQueue:^{
            [_enterpriseTree removeNodeWithId:[NSString stringWithFormat:@"%llu", groupInfo.depCode] updateParentNodeLoadedState:YES];
        }];
    }
}

- (void)handleUserChangeLineState:(EB_USER_LINE_STATE)userLineState fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount inEntGroups:(NSArray *)entGroupIds
{
    //更新成员在线状态
    [BlockUtility performBlockInMainQueue:^{
        [_enterpriseTree updateMemberOnlineState:userLineState forUid:fromUid];
    }];
    
    //更新部门在线人数
    for (NSNumber* depCodeNum in entGroupIds) {
        uint64_t depCode = [depCodeNum unsignedLongLongValue];
        [[ENTBoostKit sharedToolKit] loadOnlineStateCountOfGroupsWithDepCode:depCode onCompletion:^(NSInteger countOfGroupOnlineState) {
            [BlockUtility performBlockInMainQueue:^{
                [_enterpriseTree updateCountOfGroupOnlineState:countOfGroupOnlineState forGroupNodeId:[NSString stringWithFormat:@"%llu", depCode]];
            }];
        } onFailure:^(NSError *error) {
            NSLog(@"handleUserChangeLineState->loadOnlineStateCountOfGroupsWithDepCode:%llu error, code = %@, msg = %@", depCode, @(error.code), error.localizedDescription);
        }];
    }
}

@end
