//
//  RelationshipHelper.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/20.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "RelationshipHelper.h"
#import "ENTBoost+Utility.h"
#import "BlockUtility.h"
#import "CustomSeparator.h"
#import "ControllerManagement.h"
#import "UserInformationViewController.h"
#import "GroupInformationViewController.h"
#import "ContactInformationViewController.h"
#import "FVCustomAlertView.h"
#import "AppDelegate.h"

////把字符串从一种编码转换为另一种编码
//int code_convert(char *from_charset, char *to_charset, char *inbuf, size_t inlen, char *outbuf, size_t outlen) {
//    iconv_t cd;
//    char **pin = &inbuf;
//    char **pout = &outbuf;
//    
//    cd = iconv_open(to_charset, from_charset);
//    if (cd == 0)
//        return -1;
//    memset(outbuf, 0, outlen);
//    if (iconv(cd, pin, &inlen, pout, &outlen) == -1)
//        return -1;
//    iconv_close(cd);
//    *pout = '\0';
//    
//    return 0;
//}

@interface RelationshipHelper ()
{
    CGFloat _buttonWidth; //按钮宽度
    CGFloat _buttonMarginX; //按钮横边距
    CGFloat _buttonSpacing; //按钮间距
    
    BOOL _isHiddenTalkBtn;
    BOOL _isHiddenPropertiesBtn;
    BOOL _isHiddenTickBtn;
    
    CGRect _rect;
    UIColor* _treeBackgroundColor;
}

@property(nonatomic, strong) IBOutlet UIView* toolbar; //工具栏视图
@property(strong, nonatomic) CustomSeparator* toolbarBottomBorder; //工具栏下边框
@property(strong, nonatomic) UIView* treeContainer; //树结构显示的容器

@property(strong, nonatomic) UILabel* selectedViewLabel; //当前选中标签页的标题显示控件
@property(strong, nonatomic) CustomSeparator* selectedViewBottomBorder; //当前选中按钮下划线

@property(nonatomic, strong) UIButton* myDepartmentBtn; //"我的部门"按钮
@property(nonatomic, strong) UIButton* contactBtn; //"通讯录"按钮
@property(nonatomic, strong) UIButton* personalGroupBtn; //"个人群组"按钮
@property(nonatomic, strong) UIButton* enterpriseBtn; //"组织架构"按钮

@property(nonatomic, strong) UIView* floatMarkedLine; //标记线

@property(weak, nonatomic) id delegate; //回调代理

@property(atomic, strong) EBEnterpriseInfo* enterpriseInfo; //企业资料对象

@end

@implementation RelationshipHelper

- (id)initWithToolbar:(UIView*)toolbar treeContainer:(UIView*)treeContainer selectedViewLabel:(UILabel*)selectedViewLabel selectedViewBottomBorder:(CustomSeparator*)selectedViewBottomBorder toolbarBottomBorder:(CustomSeparator*)toolbarBottomBorder myDepartmentBtn:(UIButton*)myDepartmentBtn contactBtn:(UIButton*)contactBtn personalGroupBtn:(UIButton*)personalGroupBtn enterpriseBtn:(UIButton*)enterpriseBtn floatMarkedLine:(UIView*)floatMarkedLine delegate:(id)delegate
{
    if (self = [super init]) {
        self.toolbar = toolbar;
        self.toolbarBottomBorder = toolbarBottomBorder;
        self.treeContainer = treeContainer;
        
        self.selectedViewLabel = selectedViewLabel;
        self.selectedViewBottomBorder = selectedViewBottomBorder;
        
        self.myDepartmentBtn = myDepartmentBtn;
        self.contactBtn = contactBtn;
        self.personalGroupBtn = personalGroupBtn;
        self.enterpriseBtn = enterpriseBtn;
        self.floatMarkedLine = floatMarkedLine;
        
        self.delegate = delegate;
    }
    return self;
}

#define WAITTING_FOR_LOADING_TIMEOUT dispatch_time(DISPATCH_TIME_NOW, 6.0f * NSEC_PER_SEC)

- (void)fillTreesWithIsHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn
{
    _isHiddenTalkBtn = isHiddenTalkBtn;
    _isHiddenPropertiesBtn = isHiddenPropertiesBtn;
    _isHiddenTickBtn = isHiddenTickBtn;
    
//    _treeBackgroundColor = [UIColor colorWithHexString:@"#effafe"];
    _treeBackgroundColor = EBCHAT_DEFAULT_BLANK_COLOR;
    _rect = CGRectMake(0, 0, self.treeContainer.bounds.size.width, self.treeContainer.bounds.size.height);
    __weak typeof(self) safeSelf = self;
    
    //显示提示框
    ShowAlertView();
    
    [BlockUtility performBlockInGlobalQueue:^{
        //---------------------------------
        __block NSMutableDictionary* onlineCountsOfEntGroupMembers = [[NSMutableDictionary alloc] init];
        __block dispatch_semaphore_t sem0 = dispatch_semaphore_create(0);
        [[ENTBoostKit sharedToolKit] loadOnlineStateCountsOfEntGroupsOnCompletion:^(NSDictionary *countsOfGroupOnlineState) {
            [onlineCountsOfEntGroupMembers setDictionary:countsOfGroupOnlineState];
            dispatch_semaphore_signal(sem0);
        } onFailure:^(NSError *error) {
            NSLog(@"fillTrees->loadOnlineStateCountsOfGroups error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            dispatch_semaphore_signal(sem0);
        }];
        long result = dispatch_semaphore_wait(sem0, WAITTING_FOR_LOADING_TIMEOUT);
        
        __block dispatch_semaphore_t sem1 = dispatch_semaphore_create(0);
        //我的部门
        [self loadMyDepartmentNodesWithOnlineCountsOfMembers:(result==0)?onlineCountsOfEntGroupMembers:nil isHiddenTalkBtn:isHiddenTalkBtn isHiddenPropertiesBtn:isHiddenPropertiesBtn isHiddenTickBtn:isHiddenTickBtn isHiddenGroupTickBtn:isHiddenGroupTickBtn onCompletion:^(NSArray *nodes) {
            [BlockUtility performBlockInMainQueue:^{
                safeSelf.myDepartmentTree = [[TableTree alloc] initWithFrame:_rect nodes:nodes];
                safeSelf.myDepartmentTree.delegate = safeSelf.delegate;
                safeSelf.myDepartmentTree.tag = EB_RELATIONSHIPS_VC_MY_DEPARTMENT_VIEW_TAG;
                [safeSelf.myDepartmentTree setBackgroundColor:_treeBackgroundColor];
                
                //设置默认显示的视图
                safeSelf.selectedViewLabel.text = @"我的部门";
                safeSelf.selectedViewLabel.textAlignment = NSTextAlignmentCenter;
                [safeSelf.treeContainer addSubview:safeSelf.myDepartmentTree];
                
                dispatch_semaphore_signal(sem1);
            }];
        } onFailureBlock:^(NSError *error) {
            dispatch_semaphore_signal(sem1);
        }];
        dispatch_semaphore_wait(sem1, WAITTING_FOR_LOADING_TIMEOUT);
        
        //企业组织架构
        __block dispatch_semaphore_t sem2 = dispatch_semaphore_create(0);
        [self loadEnterpriseGroupNodesWithOnlineCountsOfMembers:(result==0)?onlineCountsOfEntGroupMembers:nil isHiddenTalkBtn:isHiddenTalkBtn isHiddenPropertiesBtn:isHiddenPropertiesBtn isHiddenTickBtn:isHiddenTickBtn isHiddenGroupTickBtn:isHiddenGroupTickBtn onCompletion:^(NSArray *nodes) {
            [BlockUtility performBlockInMainQueue:^{
                safeSelf.enterpriseTree = [[TableTree alloc] initWithFrame:_rect nodes:nodes];
                safeSelf.enterpriseTree.deepInLevel = 1;
                safeSelf.enterpriseTree.delegate = safeSelf.delegate;
                safeSelf.enterpriseTree.tag = EB_RELATIONSHIPS_VC_ENTERPRISE_VIEW_TAG;
                [safeSelf.enterpriseTree setBackgroundColor:_treeBackgroundColor];
            }];
            
            dispatch_semaphore_signal(sem2);
        } onFailureBlock:^(NSError *error) {
            dispatch_semaphore_signal(sem2);
        }];
        dispatch_semaphore_wait(sem2, WAITTING_FOR_LOADING_TIMEOUT);
        //---------------------------------
        
        __block NSMutableDictionary* onlineCountsOfPersonalGroupMembers = [[NSMutableDictionary alloc] init];
        __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [[ENTBoostKit sharedToolKit] loadOnlineStateCountsOfPersonalGroupsOnCompletion:^(NSDictionary *countsOfGroupOnlineState) {
            [onlineCountsOfPersonalGroupMembers setDictionary:countsOfGroupOnlineState];
            dispatch_semaphore_signal(sem);
        } onFailure:^(NSError *error) {
            NSLog(@"fillTrees->loadOnlineStateCountsOfGroups error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            dispatch_semaphore_signal(sem);
        }];
        long result1 = dispatch_semaphore_wait(sem, WAITTING_FOR_LOADING_TIMEOUT);
        
        //个人群组
        __block dispatch_semaphore_t sem3 = dispatch_semaphore_create(0);
        [self loadPersonalGroupNodesWithOnlineCountsOfMembers:(result1==0)?onlineCountsOfPersonalGroupMembers:nil isHiddenTalkBtn:isHiddenTalkBtn isHiddenPropertiesBtn:isHiddenPropertiesBtn isHiddenTickBtn:isHiddenTickBtn isHiddenGroupTickBtn:isHiddenGroupTickBtn onCompletion:^(NSArray *nodes) {
            [BlockUtility performBlockInMainQueue:^{
                safeSelf.personalGroupTree = [[TableTree alloc] initWithFrame:_rect nodes:nodes];
                safeSelf.personalGroupTree.delegate = safeSelf.delegate;
                safeSelf.personalGroupTree.tag = EB_RELATIONSHIPS_VC_PERSONALGROUP_VIEW_TAG;
                [safeSelf.personalGroupTree setBackgroundColor:_treeBackgroundColor];
            }];
            
            dispatch_semaphore_signal(sem3);
        } onFailureBlock:^(NSError *error) {
            dispatch_semaphore_signal(sem3);
        }];
        dispatch_semaphore_wait(sem3, WAITTING_FOR_LOADING_TIMEOUT);
        
        //通讯录
        __block dispatch_semaphore_t sem4 = dispatch_semaphore_create(0);
        [self loadContactNodesWithIsHiddenTalkBtn:YES/*isHiddenTalkBtn*/ isHiddenPropertiesBtn:isHiddenPropertiesBtn isHiddenTickBtn:isHiddenTickBtn onCompletion:^(NSArray *nodes) {
            [BlockUtility performBlockInMainQueue:^{
                safeSelf.contactTree = [[TableTree alloc] initWithFrame:_rect nodes:nodes];
                safeSelf.contactTree.delegate = safeSelf.delegate;
                safeSelf.contactTree.tag = EB_RELATIONSHIPS_VC_CONTACT_VIEW_TAG;
                [safeSelf.contactTree setBackgroundColor:_treeBackgroundColor];
            }];
            
            dispatch_semaphore_signal(sem4);
        } onFailureBlock:^(NSError *error) {
            dispatch_semaphore_signal(sem4);
        }];
        dispatch_semaphore_wait(sem4, WAITTING_FOR_LOADING_TIMEOUT);
        
        [BlockUtility syncPerformBlockInMainQueue:^{
            //关闭提示框
            CloseAlertView();
        }];
    }];
}

- (void)reloadContactTree
{
    //显示提示框
    ShowAlertView();
    
    __weak typeof(self) safeSelf = self;
    [self loadContactNodesWithIsHiddenTalkBtn:_isHiddenTalkBtn isHiddenPropertiesBtn:_isHiddenPropertiesBtn isHiddenTickBtn:_isHiddenTickBtn onCompletion:^(NSArray *nodes) {
        [BlockUtility performBlockInMainQueue:^{
            [safeSelf.contactTree setNodes:nodes];
            [safeSelf.contactTree reloadData];
        }];
        //关闭提示框
        CloseAlertView();
    } onFailureBlock:^(NSError *error) {
        //关闭提示框
        CloseAlertView();
    }];
}

+ (TableTreeNode*)treeNodeWithContactInfo:(EBContactInfo*)contactInfo outLeafCount:(int*)leafCount isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    
    TableTreeNode* node = [[TableTreeNode alloc] init];
    node.isDepartment = NO;
    node.isOffline = YES;
    
    NSString* parentNodeId = [NSString stringWithFormat:@"%llu", contactInfo.groupId];
    if (contactInfo.groupId) {
        node.parentNodeId = parentNodeId;
    } else {
        if (leafCount)
            (*leafCount)++;
        node.parentNodeId = parentNodeId;
    }
    
    node.nodeId = [NSString stringWithFormat:@"%llu", contactInfo.contactId];
    node.name = [NSString stringWithFormat:@"%@", contactInfo.name?contactInfo.name:contactInfo.account];
    if (!contactInfo.verified && ebKit.isContactNeedVerification)
        node.name = [NSString stringWithFormat:@"%@[%@]", node.name, @"未验证"];
    
    //隐藏按钮
    if (!isHiddenTalkBtn) {
        if (contactInfo.uid && contactInfo.uid!=ebKit.accountInfo.uid)
            node.isHiddenTalkBtn = NO;
    }
    node.isHiddenTickBtn = isHiddenTickBtn;
    
    node.data = [[NSMutableDictionary alloc] initWithCapacity:2];
    node.data[@"contactInfo"] = contactInfo;
    node.data[@"type"] = @(RELATIONSHIP_TYPE_CONTACT);
    
    return node;
}

+ (TableTreeNode*)treeNodeWithGroupInfo:(EBGroupInfo*)groupInfo groupType:(RELATIONSHIP_TYPE)groupType onlineCountOfMembers:(NSInteger)onlineCountOfMembers isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn
{
    TableTreeNode* node = [[TableTreeNode alloc] init];
    node.isDepartment = YES;
    node.parentNodeId = groupInfo.parentCode?[NSString stringWithFormat:@"%llu", groupInfo.parentCode]:nil;
    node.nodeId = [NSString stringWithFormat:@"%llu", groupInfo.depCode];
    node.name = groupInfo.depName;
    node.departmentTypeSortIndex = groupInfo.type;
//    if (groupInfo.type == EB_GROUP_TYPE_PROJECT) {
//        node.name = [NSString stringWithFormat:@"%@[项目组]", groupInfo.depName];
//    } else if (groupInfo.type == EB_GROUP_TYPE_TEMP) {
//        node.name = [NSString stringWithFormat:@"%@[讨论组]", groupInfo.depName];
//    }
    
    if (!isHiddenTalkBtn) {
        //如果当前用户存在于该部门下，则显示聊天按钮
        if (groupInfo.myEmpCode)
            node.isHiddenTalkBtn = NO;
        else
            node.isHiddenTalkBtn = YES;
    }
    
    node.isHiddenPropertiesBtn = isHiddenPropertiesBtn;
    node.isHiddenTickBtn = isHiddenGroupTickBtn;
    
    node.data = [[NSMutableDictionary alloc] initWithCapacity:4];
    node.data[@"groupInfo"] = groupInfo;
    node.data[@"leafCount"] = @(groupInfo.memberCount);
    node.data[@"onlineCount"] = @(onlineCountOfMembers);
    node.data[@"type"] = @(groupType);
    
    node.subNodes = [[NSMutableArray alloc] init];
    
    return node;
}

+ (NSMutableArray*)treeNodesDataWithGroupInfos:(NSDictionary*)groupInfos groupType:(RELATIONSHIP_TYPE)groupType onlineCountsOfMembers:(NSDictionary*)onlineCountsOfMembers isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn
{
    NSMutableArray *nodes = [[NSMutableArray alloc] init];
    for (id key in groupInfos) {
        EBGroupInfo* groupInfo = groupInfos[key];
        
        [nodes addObject:[self treeNodeWithGroupInfo:groupInfo groupType:groupType onlineCountOfMembers:[RelationshipHelper countOfGroupOnlineStateInCache:onlineCountsOfMembers forDepCode:groupInfo.depCode] isHiddenTalkBtn:isHiddenTalkBtn isHiddenPropertiesBtn:isHiddenPropertiesBtn isHiddenTickBtn:isHiddenTickBtn isHiddenGroupTickBtn:isHiddenGroupTickBtn]];
    }
    
    return nodes;
}

+ (void)loadNodesInGroup:(EBGroupInfo*)parentGroupInfo tableTree:(TableTree*)tableTree isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn onCompletion:(void(^)(NSArray *nodes))completionBlock failureBlock:(void(^)(NSError *error))failureBlock
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    uint64_t myUid = ebKit.accountInfo.uid;
    
    __weak typeof(self) safeSelf = self;
    [ebKit loadEntGroupInfosOnCompletion:^(NSDictionary *groupInfos) {
        NSMutableDictionary* subGroupInfos = [NSMutableDictionary dictionary];
        //获取顶层节点
        [safeSelf subGroupInfos:subGroupInfos inGroup:parentGroupInfo datasource:groupInfos recursive:NO];
        for (id key in subGroupInfos) {
            EBGroupInfo* groupInfo = subGroupInfos[key];
            //设置为顶层节点标记
            groupInfo.parentCode = 0;
        }
        
        //递归遍历获取下层节点
        for (id key in [subGroupInfos copy]) {
            EBGroupInfo* groupInfo = subGroupInfos[key];
            [safeSelf subGroupInfos:subGroupInfos inGroup:groupInfo datasource:groupInfos recursive:YES];
        }
        
        //获取各部门在线人数
        __block NSMutableDictionary* onlineCountsOfMembers = [[NSMutableDictionary alloc] init];
        __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [ebKit loadOnlineStateCountsOfEntGroupsOnCompletion:^(NSDictionary *countsOfGroupOnlineState) {
            [onlineCountsOfMembers setDictionary:countsOfGroupOnlineState];
            dispatch_semaphore_signal(sem);
        } onFailure:^(NSError *error) {
            NSLog(@"loadNodesInGroup->loadOnlineStateCountsOfGroupsWithDepCode error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            dispatch_semaphore_signal(sem);
        }];
        long result = dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 15.0f * NSEC_PER_SEC));
        
        //EBGroupInfo转换为node
        __block NSMutableArray* nodes = [RelationshipHelper treeNodesDataWithGroupInfos:subGroupInfos groupType:RELATIONSHIP_TYPE_ENTGROUP onlineCountsOfMembers:(result==0)?onlineCountsOfMembers:nil isHiddenTalkBtn:isHiddenTalkBtn isHiddenPropertiesBtn:isHiddenPropertiesBtn isHiddenTickBtn:isHiddenTickBtn isHiddenGroupTickBtn:isHiddenGroupTickBtn];
        
//        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES selector:@selector(localizedCompare:)];
//        //按名称排序
//        [nodes sortUsingDescriptors:@[sortDescriptor]];
        
        //获取部门内成员信息
        [ebKit loadMemberInfosWithDepCode:parentGroupInfo.depCode onCompletion:^(NSDictionary *memberInfos) {
            if (completionBlock) {
                __block BOOL isReturn = NO; //本函数是否已经执行结束
                
                NSMutableDictionary* resIdNodeMap = [[NSMutableDictionary alloc] init]; //resId与node对照表
                
                NSMutableArray* memberNodes = [[NSMutableArray alloc] init];
                //创建视图Node节点
                for (EBMemberInfo* memberInfo in [memberInfos allValues]) {
                    TableTreeNode* memberNode = [[TableTreeNode alloc] init];
                    memberNode.isDepartment = NO;
                    memberNode.parentNodeId = nil;//因为要显示在首层，所有要设置为nil //[NSString stringWithFormat:@"%llu", parentGroupInfo.depCode];
                    memberNode.nodeId = [NSString stringWithFormat:@"%llu", memberInfo.empCode];
                    memberNode.name = memberInfo.userName;
                    
                    if (!isHiddenTalkBtn) {
                        if (memberInfo.uid != myUid)
                            memberNode.isHiddenTalkBtn = NO;
                    }
//                    memberNode.isHiddenPropertiesBtn = isHiddenPropertiesBtn;
                    memberNode.isHiddenTickBtn = isHiddenTickBtn;
                    
                    memberNode.data = [[NSMutableDictionary alloc] initWithCapacity:2];
                    memberNode.data[@"memberInfo"] = memberInfo;
                    memberNode.data[@"type"] = @(RELATIONSHIP_TYPE_MEMBER);
                    memberNode.isOffline = YES;
                    
                    [memberNodes addObject:memberNode];
                    
                    //保存resId与node实例的关系，用于后面更新头像显示
                    if (memberInfo.headPhotoInfo.resId) {
                        resIdNodeMap[@(memberInfo.headPhotoInfo.resId)] = memberNode;
                    }
                }
                
//                [nodes addObjectsFromArray:[memberNodes sortedArrayUsingDescriptors:@[sortDescriptor]]];
                [nodes addObjectsFromArray:memberNodes];
                
                //排序
                [RelationshipHelper sortNodes:nodes];
                
                //加载头像文件，如超过1秒则暂时跳过设置头像步骤
                dispatch_semaphore_t sem = dispatch_semaphore_create(0);
                [ebKit loadHeadPhotosWithMemberInfos:[memberInfos allValues] onCompletion:^(NSDictionary *filePaths) {
                    NSLog(@"filePaths:%@", filePaths);
                    [BlockUtility performBlockInMainQueue:^{
                        //设置Node的头像文件路径
                        [resIdNodeMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                            NSString* filePath = filePaths[key];
                            TableTreeNode* memberNode = obj;
                            memberNode.icon = filePath;
                        }];
                        
                        //如果上级函数已经返回才需要刷新视图
                        if (isReturn)
                            [tableTree reloadData];
                    }];
                    dispatch_semaphore_signal(sem);
                } onFailure:^(NSError *error) {
                    dispatch_semaphore_signal(sem);
                }];
                dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC));
                
//                //回调返回结果集
//                [BlockUtility performBlockInMainQueue:^{
//                    completionBlock([nodes copy]);
//                    isReturn = YES; //标记本函数执行结束
//                }];
                
                //加载成员在线状态列表
                [ebKit loadOnlineStateOfMembersWithDepCode:parentGroupInfo.depCode onCompletion:^(NSDictionary *onlineStates, uint64_t depCode) {
                    [BlockUtility performBlockInMainQueue:^{
                        for (TableTreeNode* memberNode in nodes) {
                            for (NSNumber* uidObj in onlineStates) {
                                uint64_t uid = ((EBMemberInfo*)memberNode.data[@"memberInfo"]).uid;
                                if ([((NSNumber*)uidObj) unsignedLongLongValue] == uid) {
                                    int state = [(NSNumber*)onlineStates[uidObj] intValue];
                                    memberNode.isOffline = (state==EB_LINE_STATE_UNKNOWN || state==EB_LINE_STATE_OFFLINE)?YES:NO;
                                }
                            }
                        }
                        
                        [RelationshipHelper sortNodes:nodes]; //排序
                        completionBlock(nodes); //回调返回结果集
                        isReturn = YES; //标记本block执行结束
                        
                        [tableTree reloadData];
                    }];
                } onFailure:^(NSError *error) {
                    NSLog(@"加载成员在线状态失败，code = %li, msg = %@", (long)error.code, error.localizedDescription);
                }];
            }
        } onFailure:^(NSError *error) {
            NSLog(@"加载成员信息失败, code = %li, msg = %@", (long)error.code, error.localizedDescription);
            if (failureBlock)
                failureBlock(error);
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"加载企业部门失败, code = %li, msg = %@", (long)error.code, error.localizedDescription);
        if (failureBlock)
            failureBlock(error);
    }];
}

+ (void)subGroupInfos:(NSMutableDictionary*)subGroupInfos inGroup:(EBGroupInfo*)parentGroup datasource:(NSDictionary*)datasource recursive:(BOOL)recursive
{
    for (id key in datasource) {
        EBGroupInfo* tmpGroupInfo = datasource[key];
        if (tmpGroupInfo.parentCode && tmpGroupInfo.parentCode == parentGroup.depCode) {
            subGroupInfos[@(tmpGroupInfo.depCode)] = tmpGroupInfo;
            //存在下级子部门并且允许递归遍历时，继续执行递归遍历
            if (tmpGroupInfo.memberCount && recursive)
                [self subGroupInfos:subGroupInfos inGroup:tmpGroupInfo datasource:datasource recursive:recursive];
        }
    }
}

//获取成员在线人数
+ (NSInteger)countOfGroupOnlineStateInCache:(NSDictionary*)cache forDepCode:(uint64_t)depCode
{
    if (!cache)
        return 0;
    
    NSInteger countOfGroupOLS = 0;
    NSNumber* obj = [cache objectForKey:@(depCode)];
    if (obj)
        countOfGroupOLS = [obj integerValue];
    return countOfGroupOLS;
}

- (void)loadMyDepartmentNodesWithOnlineCountsOfMembers:(NSDictionary*)onlineCountsOfMembers isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn onCompletion:(void(^)(NSArray* nodes))completionBlock onFailureBlock:(void(^)(NSError *error))failureBlock
{
    if (completionBlock) {
        [[ENTBoostKit sharedToolKit] loadMyEntGroupInfosOnCompletion:^(NSDictionary *groupInfos) {
            //转换为node
            NSMutableArray* nodes = [[NSMutableArray alloc] init];
            for (id key in groupInfos) {
                EBGroupInfo* groupInfo = groupInfos[key];
                //如果当前用户存在于该部门中
                if (groupInfo.myEmpCode) {
                    TableTreeNode* node = [RelationshipHelper treeNodeWithGroupInfo:groupInfo groupType:RELATIONSHIP_TYPE_MYDEPARTMENT onlineCountOfMembers:[RelationshipHelper countOfGroupOnlineStateInCache:onlineCountsOfMembers forDepCode:groupInfo.depCode] isHiddenTalkBtn:isHiddenTalkBtn isHiddenPropertiesBtn:isHiddenPropertiesBtn isHiddenTickBtn:isHiddenTickBtn isHiddenGroupTickBtn:isHiddenGroupTickBtn];
                    node.parentNodeId = nil;
                    [nodes addObject:node];
                }
            }
            
            //排序
            [RelationshipHelper sortNodes:nodes];
            
            completionBlock(nodes);
        } onFailure:^(NSError *error) {
            NSLog(@"loadMyEntGroupInfos error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            if (failureBlock)
                failureBlock(error);
        }];
    }
}

- (void)loadPersonalGroupNodesWithOnlineCountsOfMembers:(NSDictionary*)onlineCountsOfMembers isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn onCompletion:(void(^)(NSArray* nodes))completionBlock onFailureBlock:(void(^)(NSError *error))failureBlock
{
    if (completionBlock) {
        [[ENTBoostKit sharedToolKit] loadPersonalGroupInfosOnCompletion:^(NSDictionary *groupInfos) {
            //EBGroupInfo转换为node
            NSMutableArray* nodes = [RelationshipHelper treeNodesDataWithGroupInfos:groupInfos groupType:RELATIONSHIP_TYPE_PERSONALGROUP onlineCountsOfMembers:onlineCountsOfMembers isHiddenTalkBtn:isHiddenTalkBtn isHiddenPropertiesBtn:isHiddenPropertiesBtn isHiddenTickBtn:isHiddenTickBtn isHiddenGroupTickBtn:isHiddenGroupTickBtn];
            //排序
            [RelationshipHelper sortNodes:nodes];
            
            completionBlock(nodes);
        } onFailure:^(NSError *error) {
            NSLog(@"loadEnterpriseGroupNodes error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
            if (failureBlock)
                failureBlock(error);
        }];
    }
}

- (void)loadEnterpriseGroupNodesWithOnlineCountsOfMembers:(NSDictionary*)onlineCountsOfMembers isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn onCompletion:(void(^)(NSArray* nodes))completionBlock onFailureBlock:(void(^)(NSError *error))failureBlock
{
    if (completionBlock) {
        [[ENTBoostKit sharedToolKit] loadEntGroupInfosOnCompletion:^(NSDictionary *groupInfos) {
            //EBGroupInfo转换为node
            NSMutableArray* nodes = [RelationshipHelper treeNodesDataWithGroupInfos:groupInfos groupType:RELATIONSHIP_TYPE_ENTGROUP onlineCountsOfMembers:onlineCountsOfMembers isHiddenTalkBtn:isHiddenTalkBtn isHiddenPropertiesBtn:isHiddenPropertiesBtn isHiddenTickBtn:isHiddenTickBtn isHiddenGroupTickBtn:isHiddenGroupTickBtn];
//            int i=0;
//            for (TableTreeNode* node in nodes) {
//                if ([node.parentNodeId isEqualToString:@"999114"]) {
//                    NSLog(@"111");
//                }
//                i++;
//            }
            
            //按名称排序
//            NSArray* sortedNodes = [nodes sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES selector:@selector(localizedCompare:)]]];
//            [nodes sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES selector:@selector(localizedCompare:)]]];
            [RelationshipHelper sortNodes:nodes];
            
            completionBlock(nodes);
        } onFailure:^(NSError *error) {
            NSLog(@"loadEnterpriseGroupNodes error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
            if (failureBlock)
                failureBlock(error);
        }];
    }
}

- (void)loadContactNodesWithIsHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn onCompletion:(void(^)(NSArray* nodes))completionBlock onFailureBlock:(void(^)(NSError *error))failureBlock
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
//    uint64_t myUid = ebKit.accountInfo.uid;
    
    NSMutableArray *nodes = [[NSMutableArray alloc] init];
    
    //获取通讯录分组
    [ebKit loadContactGroupsOnCompletion:^(NSDictionary *groups) {
        //建立分组数据
        [groups enumerateKeysAndObjectsUsingBlock:^(id key, EBContactGroup* group, BOOL *stop) {
            TableTreeNode* node = [[TableTreeNode alloc] init];
            node.isDepartment = YES;
            node.parentNodeId = nil;
            node.nodeId = [NSString stringWithFormat:@"%llu", group.groupId];
            node.name = group.groupName;
            node.isLoadedSubNodes = YES;
            
            node.data = [[NSMutableDictionary alloc] initWithCapacity:4];
            node.data[@"contactGroup"] = group;
            
            [nodes addObject:node];
        }];

        //排序
        [RelationshipHelper sortNodes:nodes];
//        //按名称排序
//        [nodes sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES selector:@selector(localizedCompare:)]]];
        
        //加载全部联系人
        [ebKit loadContactInfosOnCompletion:^(NSDictionary *contactInfos) {
            //计算每分组成员数量
            for (TableTreeNode* node in nodes) {
                int leafCount = 0;
                for (id key in contactInfos) {
                    EBContactInfo* contactInfo = contactInfos[key];
                    if ([[NSString stringWithFormat:@"%llu", contactInfo.groupId] isEqualToString:node.nodeId])
                        leafCount++;
                }
                
                node.data[@"leafCount"] = @(leafCount);
                node.data[@"onlineCount"] = [ebKit isContactNeedVerification]?@0:@(-1);
                node.data[@"type"] = @(RELATIONSHIP_TYPE_CONTACTGROUP);
            }
            
            NSString* NoGroupName = ebKit.isContactNeedVerification?@"未分组好友":@"未分组联系人";
            
            //获取通讯录中联系人
            __block int leafCount = 0;
            NSMutableArray* contactNodes = [[NSMutableArray alloc] init];
            [contactInfos enumerateKeysAndObjectsUsingBlock:^(id key, EBContactInfo* contactInfo, BOOL *stop) {
//                TableTreeNode* node = [[TableTreeNode alloc] init];
//                node.isDepartment = NO;
//                node.isOffline = YES;
//                
//                NSString* parentNodeId = [NSString stringWithFormat:@"%llu", contactInfo.groupId];
//                if (contactInfo.groupId) {
//                    node.parentNodeId = parentNodeId;
//                } else {
//                    leafCount++;
//                    node.parentNodeId = parentNodeId;
//                }
//                
//                node.nodeId = [NSString stringWithFormat:@"%llu", contactInfo.contactId];
//                node.name = [NSString stringWithFormat:@"%@", contactInfo.name?contactInfo.name:contactInfo.account];
//                if (!contactInfo.verified && ebKit.isContactNeedVerification)
//                    node.name = [NSString stringWithFormat:@"%@[%@]", node.name, @"未验证"];
//                
//                //隐藏按钮
//                if (!isHiddenTalkBtn) {
//                    if (contactInfo.uid && contactInfo.uid!=myUid)
//                        node.isHiddenTalkBtn = NO;
//                }
//                node.isHiddenTickBtn = isHiddenTickBtn;
//                
//                node.data = [[NSMutableDictionary alloc] initWithCapacity:2];
//                node.data[@"contactInfo"] = contactInfo;
//                node.data[@"type"] = @(RELATIONSHIP_TYPE_CONTACT);
                
                TableTreeNode* node = [RelationshipHelper treeNodeWithContactInfo:contactInfo outLeafCount:&leafCount isHiddenTalkBtn:isHiddenTalkBtn isHiddenTickBtn:isHiddenTickBtn];
                
                [contactNodes addObject:node];
            }];
            
            //建立未分组的临时组
            EBContactGroup* group = [[EBContactGroup alloc] initWithId:0 groupName:NoGroupName];
            TableTreeNode* node = [[TableTreeNode alloc] init];
            node.isDepartment = YES;
            node.parentNodeId = nil;
            node.nodeId = [NSString stringWithFormat:@"%llu", group.groupId];
            node.name = group.groupName;
            node.isLoadedSubNodes = YES; //通讯录不执行动态加载，默认一次全加载完
            
            node.data = [[NSMutableDictionary alloc] initWithCapacity:3];
            node.data[@"contactGroup"] = group;
            node.data[@"leafCount"] = @(leafCount);
            node.data[@"onlineCount"] = ebKit.isContactNeedVerification?@0:@(-1);
            node.data[@"type"] = @(RELATIONSHIP_TYPE_CONTACTGROUP);
            [nodes addObject:node];
            
            //按名称排序
//            NSArray* sortedNodes = [contactNodes sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES selector:@selector(localizedCompare:)]]];
            
            
            if (ebKit.isContactNeedVerification) {
                static NSString* lock = @"lock";
                __block BOOL isReturn = NO;
                
                //获取联系人在线状态
                __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
                [ebKit loadOnlineStateOfContactsOnCompletion:^(NSDictionary *onlineStates) {
                    for (TableTreeNode* tmpNode in contactNodes) {
                        if (!tmpNode.isDepartment) {
                            EBContactInfo* contactInfo = tmpNode.data[@"contactInfo"];
                            if (contactInfo && onlineStates[@(contactInfo.uid)]) {
                                EB_USER_LINE_STATE lineState = [onlineStates[@(contactInfo.uid)] intValue];
                                if (lineState!=EB_LINE_STATE_OFFLINE && lineState!=EB_LINE_STATE_UNKNOWN)
                                    tmpNode.isOffline = NO;
                            }
                        }
                    }
                
                    @synchronized(lock) {
                        if (!isReturn) {
                            //统计各分组在线人数
                            for (TableTreeNode* groupNode in nodes) {
                                for (TableTreeNode* contactNode in contactNodes) {
                                    if (!contactNode.isOffline) {
                                        if ( ([groupNode.nodeId isEqualToString:@"0"] && !contactNode.parentNodeId) || [contactNode.parentNodeId isEqualToString:groupNode.nodeId])
                                            groupNode.data[@"onlineCount"] = @([groupNode.data[@"onlineCount"] intValue]+1);
                                    }
                                }
                            }
                            
                            isReturn = YES;
                            [RelationshipHelper sortNodes:contactNodes]; //排序
                            [nodes addObjectsFromArray:contactNodes];
                            
                            if (completionBlock)
                                completionBlock(nodes);
                            
                            dispatch_semaphore_signal(sem);
                        }
                    }
                } onFailure:^(NSError *error) {
                    NSLog(@"loadOnlineStateOfContacts error, code = %@, msg = %@", @(error.code), error.localizedDescription);
                    if (failureBlock)
                        failureBlock(error);
                    
                    dispatch_semaphore_signal(sem);
                }];
                
                long result = dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 6.0f * NSEC_PER_SEC));
                if (result) {
                    @synchronized(lock) {
                        if (!isReturn) {
                            isReturn = YES;
                            [RelationshipHelper sortNodes:contactNodes]; //排序
                            [nodes addObjectsFromArray:contactNodes];
                            
                            if (completionBlock)
                                completionBlock(nodes);
                        }
                    }
                }
            } else {
                for (TableTreeNode* tmpNode in contactNodes) {
                    tmpNode.isOffline = NO;
                }
                
                //排序
                [RelationshipHelper sortNodes:contactNodes];
                [nodes addObjectsFromArray:contactNodes];
                
                if (completionBlock)
                    completionBlock(nodes);
            }
        } onFailure:^(NSError *error) {
            NSLog(@"loadContactInfos error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            if (failureBlock)
                failureBlock(error);
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"loadContactGroups error, code = %@, msg = %@", @(error.code), error.localizedDescription);
        if (failureBlock)
            failureBlock(error);
    }];
}

+ (NSInteger)loadOnlineStateCountsOfGroupsWithDepCode:(uint64_t)depCode
{
    __block NSInteger countOfGroupOLS = 0;
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [[ENTBoostKit sharedToolKit] loadOnlineStateCountOfGroupsWithDepCode:depCode onCompletion:^(NSInteger countsOfGroupOnlineState) {
        countOfGroupOLS = (countsOfGroupOnlineState==-1?0:countsOfGroupOnlineState);
        dispatch_semaphore_signal(sem);
    } onFailure:^(NSError *error) {
        NSLog(@"loadOnlineStateCountsOfGroupsWithDepCode error, code = %@, msg = %@", @(error.code), error.localizedDescription);
        dispatch_semaphore_signal(sem);
    }];
    
    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 15.0f * NSEC_PER_SEC)); //最长等待15秒
    
    return countOfGroupOLS;
}

+ (void)loadTotalMemberCountOfEntGroupsOnCompletion:(void(^)(NSInteger totalMemberCount))completionBlock
{
    [[ENTBoostKit sharedToolKit] loadEntGroupInfosOnCompletion:^(NSDictionary *groupInfos) {
        NSInteger totalMemberCount = 0;
        for (EBGroupInfo* groupInfo in [groupInfos allValues]) {
            totalMemberCount+=groupInfo.memberCount;
        }
        [BlockUtility performBlockInMainQueue:^{
            if (completionBlock)
                completionBlock(totalMemberCount);
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"loadEntGroupInfos error, code = %@, msg = %@", @(error.code), error.localizedDescription);
    }];
}

+ (void)loadTotalOnlineStateCountOfEntGroupsOnCompletion:(void(^)(NSInteger totalOnlineStateCount))completionBlock
{
    [[ENTBoostKit sharedToolKit] loadOnlineStateCountsOfEntGroupsOnCompletion:^(NSDictionary *countsOfGroupOnlineState) {
        NSInteger totalOnlineStateCount = 0;
        for (NSNumber* count in [countsOfGroupOnlineState allValues]) {
            totalOnlineStateCount+=[count integerValue];
        }
        [BlockUtility performBlockInMainQueue:^{
            if (completionBlock)
                completionBlock(totalOnlineStateCount);
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"loadOnlineStateCountsOfEntGroups error, code = %@, msg = %@", @(error.code), error.localizedDescription);
    }];
}

#pragma mark -

//设置工具栏
- (void)initToolbar:(UIView*)superView
{
//    UIColor* borderColor = [UIColor colorWithHexString:@"#c5e1ec"]; //定义边框颜色
    self.toolbarBottomBorder.color1 = EBCHAT_DEFAULT_BORDER_CORLOR; //设置仿工具栏下边框颜色
    self.toolbarBottomBorder.lineHeight1 = 1.0f; //设置仿工具栏下边框高度
    
    NSString* contactBtnTitle = [ENTBoostKit sharedToolKit].isContactNeedVerification?@"我的好友":@"通讯录";
    UILabel* label = (UILabel*)[self.contactBtn viewWithTag:101];
    label.text = contactBtnTitle;
    
    //添加触发事件处理方法
    [self.myDepartmentBtn addTarget:self action:@selector(switchToMyDepartmentView) forControlEvents:UIControlEventTouchUpInside];
    [self.contactBtn addTarget:self action:@selector(switchToContactView) forControlEvents:UIControlEventTouchUpInside];
    [self.personalGroupBtn addTarget:self action:@selector(switchToPersonalGroupView) forControlEvents:UIControlEventTouchUpInside];
    [self.enterpriseBtn addTarget:self action:@selector(switchToEnterpriseView) forControlEvents:UIControlEventTouchUpInside];
    
    //均匀分布图标按钮间距
    _buttonMarginX = 20.0f; //左右缩进量
    _buttonWidth = self.myDepartmentBtn.bounds.size.width; //单个按钮宽度
    NSDictionary* buttons = @{[NSString stringWithFormat:@"%p", self.myDepartmentBtn]:self.myDepartmentBtn, [NSString stringWithFormat:@"%p", self.contactBtn]:self.contactBtn, [NSString stringWithFormat:@"%p", self.personalGroupBtn]:self.personalGroupBtn, [NSString stringWithFormat:@"%p", self.enterpriseBtn]:self.enterpriseBtn};
    //调整间距约束
    _buttonSpacing = ceil((superView.bounds.size.width - _buttonMarginX*2 - buttons.count*_buttonWidth)/(buttons.count-1));
    
    NSArray* constraints = [self.toolbar constraints]; //获取约束
    //遍历检查相关的间距约束
    for (int i=0; i<constraints.count; i++) {
        NSLayoutConstraint* constraint = constraints[i];
        if (constraint.firstItem != nil && constraint.secondItem != nil && constraint.firstAttribute == NSLayoutAttributeLeading && constraint.secondAttribute == NSLayoutAttributeTrailing) {
            UIButton* button1 = buttons[[NSString stringWithFormat:@"%p", constraint.firstItem]];
            UIButton* button2 = buttons[[NSString stringWithFormat:@"%p", constraint.secondItem]];
            if (button1 && button2)
                constraint.constant = _buttonSpacing;
        }
    }
}

//设置选中视图的属性
- (void)initSelectedView
{
//    UIColor* borderColor = [UIColor colorWithHexString:@"#c5e1ec"]; //定义边框颜色
    self.selectedViewBottomBorder.color1 = EBCHAT_DEFAULT_BORDER_CORLOR; //设置下边框颜色
    self.selectedViewBottomBorder.lineHeight1 = 1.0f; //设置下边框高度
}

//设置当前选中标记线位置
- (void)setSelectedButtonAtIndex:(NSUInteger)index
{
    //    CGFloat lineWidth = self.view.bounds.size.width/4;
    //左边间距约束
    NSArray* constraints = [self.floatMarkedLine constraintsAffectingLayoutForAxis:UILayoutConstraintAxisHorizontal];
    for (NSLayoutConstraint* constraint in constraints) {
        if (constraint.firstAttribute==NSLayoutAttributeLeading && constraint.firstItem==self.floatMarkedLine && constraint.secondAttribute==NSLayoutAttributeLeading && constraint.secondItem== self.toolbar) {
            if (index==0)
                constraint.constant = 0;
            else
                constraint.constant = _buttonMarginX + _buttonWidth*index + _buttonSpacing*(index-1) + _buttonSpacing/2;
            break;
        }
    }
    
    //宽度约束
    constraints = [self.floatMarkedLine constraints];
    for (NSLayoutConstraint* constraint in constraints) {
        if (constraint.firstItem==self.floatMarkedLine && constraint.firstAttribute==NSLayoutAttributeWidth) {
            if (index==0 || index==3)
                constraint.constant = _buttonMarginX + _buttonWidth + _buttonSpacing/2;
            else
                constraint.constant = _buttonWidth + _buttonSpacing;
            break;
        }
    }
}

//移除指定视图
- (void)removeViewWithTag:(NSArray*)tags
{
    for (NSNumber *tagNumber in tags) {
        UIView* view = [self.treeContainer viewWithTag:tagNumber.integerValue];
        [view removeFromSuperview];
    }
}

#define TagOfSelectedViewLabel_Other 0
#define TagOfSelectedViewLabel_Enterprise 101

- (void)updateSelectedViewLabelOfEnterpriseView
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        if (!safeSelf.enterpriseInfo) {
            [[ENTBoostKit sharedToolKit] loadEnterpriseInfoOnCompletion:^(EBEnterpriseInfo *enterpriseInfo) {
                safeSelf.enterpriseInfo = enterpriseInfo;
                dispatch_semaphore_signal(sem);
            } onFailure:^(NSError *error) {
                NSLog(@"loadEnterpriseInfo error, code = %@, msg = %@", @(error.code), error.localizedDescription);
                dispatch_semaphore_signal(sem);
            }];
            
            dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 2.0f * NSEC_PER_SEC));
        }
        
        NSString* entName = safeSelf.enterpriseInfo?safeSelf.enterpriseInfo.entName:@"";
        
        //只有处于企业架构页面才执行更新描述
        NSRange range = [safeSelf.selectedViewLabel.text rangeOfString:entName];
        if (safeSelf.selectedViewLabel.tag==TagOfSelectedViewLabel_Enterprise && range.location==NSNotFound) {
            safeSelf.selectedViewLabel.text = entName;
        }
        
        //加载显示企业总人数和在线总人数
        [RelationshipHelper loadTotalMemberCountOfEntGroupsOnCompletion:^(NSInteger totalMemberCount) {
            [RelationshipHelper loadTotalOnlineStateCountOfEntGroupsOnCompletion:^(NSInteger totalOnlineStateCount) {
                //只有处于企业架构页面才执行更新描述
                if (safeSelf.selectedViewLabel.tag==TagOfSelectedViewLabel_Enterprise) {
                    safeSelf.selectedViewLabel.text = [NSString stringWithFormat:@"%@ [%@/%@]", entName, @(totalOnlineStateCount), @(totalMemberCount)];
                }
            }];
        }];
    }];
}

//切换到企业架构视图
- (void)switchToEnterpriseView
{
//    self.navigationItem.title = @"联系人-企业架构";
    //设置特殊标记值
    self.selectedViewLabel.tag = TagOfSelectedViewLabel_Enterprise;
    self.selectedViewLabel.textAlignment = NSTextAlignmentLeft;
    
    //更新标题
    [self updateSelectedViewLabelOfEnterpriseView];
    
    //更新tree视图
    [self removeViewWithTag:@[@EB_RELATIONSHIPS_VC_PERSONALGROUP_VIEW_TAG, @EB_RELATIONSHIPS_VC_CONTACT_VIEW_TAG, @EB_RELATIONSHIPS_VC_MY_DEPARTMENT_VIEW_TAG]];
    [self.treeContainer addSubview:_enterpriseTree];
    [self setSelectedButtonAtIndex:3];
}

//切换到个人群组视图
- (void)switchToPersonalGroupView
{
    //设置默认标记值
    self.selectedViewLabel.tag = TagOfSelectedViewLabel_Other;
    
    //    self.navigationItem.title = @"联系人-个人群组";
    self.selectedViewLabel.text = @"个人群组";
    self.selectedViewLabel.textAlignment = NSTextAlignmentCenter;
    
    [self removeViewWithTag:@[@EB_RELATIONSHIPS_VC_ENTERPRISE_VIEW_TAG, @EB_RELATIONSHIPS_VC_CONTACT_VIEW_TAG, @EB_RELATIONSHIPS_VC_MY_DEPARTMENT_VIEW_TAG]];
    [self.treeContainer addSubview:_personalGroupTree];
    [self setSelectedButtonAtIndex:2];
}

//切换到通讯录视图
- (void)switchToContactView
{
    //设置默认标记值
    self.selectedViewLabel.tag = TagOfSelectedViewLabel_Other;
    
    //    self.navigationItem.title = @"联系人-通讯录";
    self.selectedViewLabel.text = [[ENTBoostKit sharedToolKit] isContactNeedVerification]?@"我的好友":@"通讯录";
    self.selectedViewLabel.textAlignment = NSTextAlignmentCenter;
    
    [self removeViewWithTag:@[@EB_RELATIONSHIPS_VC_ENTERPRISE_VIEW_TAG, @EB_RELATIONSHIPS_VC_PERSONALGROUP_VIEW_TAG, @EB_RELATIONSHIPS_VC_MY_DEPARTMENT_VIEW_TAG]];
    [self.treeContainer addSubview:_contactTree];
    [self setSelectedButtonAtIndex:1];
}

//切换到我的部门视图
- (void)switchToMyDepartmentView
{
    //设置默认标记值
    self.selectedViewLabel.tag = TagOfSelectedViewLabel_Other;
    
    //    self.navigationItem.title = @"联系人-我的部门";
    self.selectedViewLabel.text = @"我的部门";
    self.selectedViewLabel.textAlignment = NSTextAlignmentCenter;
    
    [self removeViewWithTag:@[@EB_RELATIONSHIPS_VC_ENTERPRISE_VIEW_TAG, @EB_RELATIONSHIPS_VC_PERSONALGROUP_VIEW_TAG, @EB_RELATIONSHIPS_VC_CONTACT_VIEW_TAG]];
    [self.treeContainer addSubview:_myDepartmentTree];
    [self setSelectedButtonAtIndex:0];
}

//显示属性界面
+ (void)showPropertiesWithNode:(TableTreeNode *)node navigationController:(UINavigationController*)navigationController delegate:(id)delegate
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    RELATIONSHIP_TYPE type = [node.data[@"type"] shortValue];
    switch (type) {
        case RELATIONSHIP_TYPE_ENTGROUP:
        case RELATIONSHIP_TYPE_PERSONALGROUP:
        case RELATIONSHIP_TYPE_MYDEPARTMENT:
        {
            uint64_t myUid = ebKit.accountInfo.uid;
            EBGroupInfo* groupInfo = node.data[@"groupInfo"];
            [[ControllerManagement sharedInstance] fetchGroupControllerWithDepCode:groupInfo.depCode onCompletion:^(GroupInformationViewController *gvc) {
                [ebKit loadMemberInfoWithUid:myUid depCode:groupInfo.depCode onCompletion:^(EBMemberInfo *memberInfo) {
                    [BlockUtility performBlockInMainQueue:^{
                        gvc.delegate = delegate;
                        gvc.dataObject = node;
                        gvc.myMemberInfo = memberInfo;
                        [navigationController pushViewController:gvc animated:YES];
                    }];
                } onFailure:^(NSError *error) {
                    [BlockUtility performBlockInMainQueue:^{
                        gvc.delegate = delegate;
                        gvc.dataObject = node;
                        [navigationController pushViewController:gvc animated:YES];
                    }];
                }];
            } onFailure:nil];
        }
            break;
        case RELATIONSHIP_TYPE_MEMBER:
        {
            if (node.data[@"memberInfo"]) {
                EBMemberInfo* memberInfo = node.data[@"memberInfo"];
                [[ControllerManagement sharedInstance] fetchUserControllerWithUid:memberInfo.uid orAccount:memberInfo.empAccount checkVCard:NO onCompletion:^(UserInformationViewController *uvc) {
                    uvc.targetMemberInfo = memberInfo;
                    uvc.targetGroupInfo = [ebKit groupInfoWithDepCode:memberInfo.depCode];
                    uvc.delegate = delegate;
                    uvc.dataObject = node;
                    
                    if (uvc.targetGroupInfo.myEmpCode) {
                        //获取当前用户在该群组下的成员信息
                        [ebKit loadMemberInfoWithEmpCode:uvc.targetGroupInfo.myEmpCode onCompletion:^(EBMemberInfo *myMemberInfo) {
                            [BlockUtility performBlockInMainQueue:^{
                                uvc.delegate = delegate;
                                uvc.myMemberInfo = myMemberInfo;
                                [navigationController pushViewController:uvc animated:YES];
                            }];
                        } onFailure:^(NSError *error) {
                            NSLog(@"加载当前用户的成员信息失败, code = %@, msg = %@", @(error.code), error.localizedDescription);
                            [BlockUtility performBlockInMainQueue:^{
                                uvc.delegate = delegate;
                                [navigationController pushViewController:uvc animated:YES];
                            }];
                        }];
                    } else {
                        [BlockUtility performBlockInMainQueue:^{
                            uvc.delegate = delegate;
                            [navigationController pushViewController:uvc animated:YES];
                        }];
                    }
                } onFailure:nil];
            }
        }
            break;
        case RELATIONSHIP_TYPE_CONTACT:
        {
            if (node.data[@"contactInfo"]) {
                EBContactInfo* contactInfo = node.data[@"contactInfo"];
                [[ControllerManagement sharedInstance] fetchContactControllerWithContactInfo:contactInfo onCompletion:^(ContactInformationViewController *cvc) {
                    cvc.delegate = delegate;
                    cvc.dataObject = node;
                    [navigationController pushViewController:cvc animated:YES];
                } onFailure:nil];
            }
        }
            break;
        default:
            break;
    }
}

+ (void)manageContact:(NSDictionary*)parameters
{
    NSString* type = parameters[@"type"];
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    
    if ([type isEqualToString:@"verify"]) { //验证
        uint64_t contactUid = [parameters[@"uid"] unsignedLongLongValue];
        NSString* contactAccount = parameters[@"account"];
        [ebKit verifyContactInfoWithContactUid:contactUid orContactAccount:contactAccount description:@"请加我好友" onVerificationSent:^{
            NSLog(@"发起验证联系人成功，contactUid = %llu", contactUid);
            //操作结果提示
            [BlockUtility performBlockInMainQueue:^{
                ShowCommonAlertView(@"已发出邀请");
            }];
            [NSThread sleepForTimeInterval:1.5];
            [BlockUtility performBlockInMainQueue:^{
                CloseAlertView();
            }];
        } onFailure:^(NSError *error) {
            NSLog(@"发起验证联系人失败, code = %@, msg = %@", @(error.code), error.localizedDescription);
        }];
    } else if ([type isEqualToString:@"edit"]) { //编辑信息
        [ebKit editContactInfo:parameters[@"contactInfo"] onCompletion:^(EBContactInfo *newContactInfo) {
            NSLog(@"编辑联系人成功，contactId = %llu, contactUid = %llu, name = %@", newContactInfo.contactId, newContactInfo.uid, newContactInfo.name);
        } onFailure:^(NSError *error) {
            NSLog(@"编辑联系人失败, code = %@, msg = %@", @(error.code), error.localizedDescription);
        }];
    } else if ([type isEqualToString:@"create"]) {
        //新增
        [ebKit createContactInfo:parameters[@"contactInfo"] onCompletion:^(EBContactInfo *newContactInfo) {
            NSLog(@"新增联系人成功，contactId = %llu, contactUid = %llu, name = %@", newContactInfo.contactId, newContactInfo.uid, newContactInfo.name);
            //操作结果提示
            [BlockUtility performBlockInMainQueue:^{
                ShowCommonAlertView(@"新增联系人成功");
            }];
            [NSThread sleepForTimeInterval:1.5];
            [BlockUtility performBlockInMainQueue:^{
                CloseAlertView();
            }];
//            NSLog(@"新增联系人的虚拟事件, contactId = %llu, uid = %llu", newContactInfo.contactId, newContactInfo.uid);
//            AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//            [appDelegate onAddContactAccept:newContactInfo fromUid:newContactInfo.uid fromAccount:newContactInfo.account vCard:nil];
        } onFailure:^(NSError *error) {
            NSLog(@"新增联系人失败, code = %@, msg = %@", @(error.code), error.localizedDescription);
        }];
    }
}

+ (void)deleteContact:(uint64_t)contactId onCompletion:(void(^)(void))completionBlock onFailureBlock:(void(^)(NSError* error))failureBlock
{
    [[ENTBoostKit sharedToolKit] deleteContactWithId:contactId orContactUid:0 deleteAnother:YES onCompletion:^{
        NSLog(@"删除联系人成功，contactId = %llu", contactId);
        if (completionBlock)
            completionBlock();
    } onFailure:^(NSError *error) {
        NSLog(@"deleteContact error, code = %@, msg = %@", @(error.code), error.localizedDescription);
        if (failureBlock)
            failureBlock(error);
    }];
}

+ (void)sortNodes:(NSMutableArray*)nodes
{
    //按先部门后成员排序
    NSSortDescriptor* sortDescriptorDepartment = [[NSSortDescriptor alloc] initWithKey:@"_isDepartment" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber * n1 = obj1;
        NSNumber * n2 = obj2;
        return [n1 compare:n2];
    }];
    
    NSSortDescriptor* sortDescriptorDepartmentTypeSortIndex = [[NSSortDescriptor alloc] initWithKey:@"_departmentTypeSortIndex" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber * n1 = obj1;
        NSNumber * n2 = obj2;
        return [n1 compare:n2];
    }];
    
    //按排序数值排序
    NSSortDescriptor* sortDescriptorSortIndex = [[NSSortDescriptor alloc] initWithKey:@"_sortIndex" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber * n1 = obj1;
        NSNumber * n2 = obj2;
        return [n1 compare:n2];
    }];
    
    //按上下线状态排序
    NSSortDescriptor* sortDescriptorOffline = [[NSSortDescriptor alloc] initWithKey:@"_isOffline" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber * n1 = obj1;
        NSNumber * n2 = obj2;
        return [n1 compare:n2];
    }];
    
    //按名称排序
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000); //中文字符编码；注意gb2312字符集，ASCII字符排在中文字符前面；gbk则相反
    NSSortDescriptor* sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        /* OK
         NSData* sd1 = [obj1 dataUsingEncoding:NSUTF8StringEncoding];
         NSData* sd2 = [obj2 dataUsingEncoding:NSUTF8StringEncoding];
         
         size_t outlen1 =sd1.length+1;
         char chs1[outlen1];
         code_convert("utf-8", "gbk", (char*)[sd1 bytes], sd1.length, chs1, outlen1);
         
         size_t outlen2 =sd2.length+1;
         char chs2[outlen2];
         code_convert("utf-8", "gbk", (char*)[sd2 bytes], sd2.length, chs2, outlen2);
         */
        
        const char* chs1 = [obj1 cStringUsingEncoding:enc];
        const char* chs2 = [obj2 cStringUsingEncoding:enc];
        
        int result = strcmp(chs1, chs2);
        if (result<0)
            return NSOrderedAscending;
        else if (result >0)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    
    //执行排序
    [nodes sortUsingDescriptors:@[sortDescriptorDepartment, sortDescriptorDepartmentTypeSortIndex, sortDescriptorSortIndex, sortDescriptorOffline, sortDescriptorName]];
}

#pragma mark -

- (NSArray*)tickCheckedNodes
{
    NSMutableArray* nodes = [[NSMutableArray alloc] init];
    //我的部门
    if (self.myDepartmentTree) {
        [nodes addObjectsFromArray:[self.myDepartmentTree tickCheckedNodes]];
    }
    //联系人(好友)
    if (self.contactTree) {
        [nodes addObjectsFromArray:[self.contactTree tickCheckedNodes]];
    }
    //个人群组
    if (self.personalGroupTree) {
        [nodes addObjectsFromArray:[self.personalGroupTree tickCheckedNodes]];
    }
    //企业架构
    if (self.enterpriseTree) {
        [nodes addObjectsFromArray:[self.enterpriseTree tickCheckedNodes]];
    }
    
    return nodes;
}

#pragma mark - 事件代理

+ (BOOL)tableTree:(TableTree *)tableTree deepInToNode:(TableTreeNode *)node groupInfo:(EBGroupInfo**)groupInfo
{
    (*groupInfo) = node.data[@"groupInfo"];
    NSInteger leafCount = [node.data[@"leafCount"] integerValue];
    BOOL deepIn = NO;
    if (leafCount)
        deepIn = YES;
    else {
        NSUInteger countOfSubGroupInfos = [[ENTBoostKit sharedToolKit] countOfSubGroupInfos:(*groupInfo).depCode];
        if (countOfSubGroupInfos)
            deepIn = YES;
    }
    
    return deepIn;
}

+ (void)tableTree:(TableTree *)tableTree loadLeavesUnderNode:(TableTreeNode *)parentNode isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn onCompletion:(void(^)(NSArray *))completionBlock
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    EBGroupInfo* groupInfo = parentNode.data[@"groupInfo"];
    uint64_t myUid = ebKit.accountInfo.uid;
    
    //加载企业资料
    __block EBEnterpriseInfo* enterpriseInfo;
    if (groupInfo.entCode) {
        __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [ebKit loadEnterpriseInfoOnCompletion:^(EBEnterpriseInfo *loadedEnterpriseInfo) {
            enterpriseInfo = loadedEnterpriseInfo;
            dispatch_semaphore_signal(sem);
        } onFailure:^(NSError *error) {
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 3.0f * NSEC_PER_SEC));
    }
    
    //显示提示框
    ShowAlertView();
    
    //加载成员列表
    [ebKit loadMemberInfosWithDepCode:groupInfo.depCode onCompletion:^(NSDictionary *memberInfos) {
        if (completionBlock) {
            __block BOOL isReturn = NO; //本函数是否已经执行结束
            
            NSMutableArray* returnMemberNodes = [[NSMutableArray alloc] init]; //返回结果集
            NSMutableDictionary* resIdNodeMap = [[NSMutableDictionary alloc] init]; //resId与node对照表
            NSArray* memberInfoArray = [memberInfos allValues];
            uint64_t creatorUid = groupInfo.creatorUid;
            
            //创建视图Node节点
            for (EBMemberInfo* memberInfo in memberInfoArray) {
                TableTreeNode* memberNode = [[TableTreeNode alloc] init];
                memberNode.isDepartment = NO;
                memberNode.parentNodeId = parentNode.nodeId;
                memberNode.nodeId = [NSString stringWithFormat:@"%llu", memberInfo.empCode];
                memberNode.name = memberInfo.userName;
                
                if(!isHiddenTalkBtn) {
                    if (memberInfo.uid != myUid)
                        memberNode.isHiddenTalkBtn = NO;
                }
//                memberNode.isHiddenPropertiesBtn = isHiddenPropertiesBtn;
                memberNode.isHiddenTickBtn = isHiddenTickBtn;
                
                memberNode.data = [[NSMutableDictionary alloc] initWithCapacity:2];
                memberNode.data[@"memberInfo"] = memberInfo;
                memberNode.data[@"type"] = @(RELATIONSHIP_TYPE_MEMBER);
                memberNode.isOffline = YES;
                
                [returnMemberNodes addObject:memberNode];
                
                //保存resId与node实例的关系，用于后面更新头像显示
                if (memberInfo.headPhotoInfo.resId) {
                    resIdNodeMap[@(memberInfo.headPhotoInfo.resId)] = memberNode;
                }
                
                //识别该成员是否当前登录用户
                if (myUid == memberInfo.uid) {
                    memberNode.sortIndex = 3;
                    memberNode.textColor = [UIColor blueColor];
                }
                //识别群组(部门)管理员
                if ((memberInfo.managerLevel&EB_LEVEL_DEP_ADMIN)!=0) { //只要有其中任何一项管理权限，就视为管理员
                    memberNode.sortIndex = 2;
                }
                //识别群组(部门)创建者
                if (creatorUid==memberInfo.uid) {
                    memberNode.sortIndex = 1;
                }
                //识别企业资料创建者
                if (enterpriseInfo.creatorUid==memberInfo.uid) {
                    memberNode.sortIndex = 0;
                }
                //用颜色标记特殊成员
                if (memberNode.sortIndex<kTableTreeNode_NormalSortIndex && memberNode.sortIndex!=3) {
                    memberNode.textColor = [UIColor colorWithHexString:@"#FF0060"];
                }
            }
            
            //加载头像文件，如超过1秒则暂时跳过设置头像步骤
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            [ebKit loadHeadPhotosWithMemberInfos:memberInfoArray onCompletion:^(NSDictionary *filePaths) {
                NSLog(@"filePaths:%@", filePaths);
                [BlockUtility performBlockInMainQueue:^{
                    //设置Node的头像文件路径
                    [resIdNodeMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        NSString* filePath = filePaths[key];
                        TableTreeNode* memberNode = obj;
                        memberNode.icon = filePath;
                    }];
                    
                    //如果上级函数已经返回才需要刷新视图
                    if (isReturn) {
                        [tableTree reloadSubNodesUnderParentNodeId:parentNode.nodeId];
                        //[tableTree reloadData];
                    }
                }];
                dispatch_semaphore_signal(sem);
            } onFailure:^(NSError *error) {
                dispatch_semaphore_signal(sem);
            }];
            dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC));
            
            //加载成员在线状态列表
            [ebKit loadOnlineStateOfMembersWithDepCode:groupInfo.depCode onCompletion:^(NSDictionary *onlineStates, uint64_t depCode) {
                [BlockUtility performBlockInMainQueue:^{
                    for (TableTreeNode* memberNode in returnMemberNodes) {
                        for (NSNumber* uidObj in onlineStates) {
                            uint64_t uid = ((EBMemberInfo*)memberNode.data[@"memberInfo"]).uid;
                            if ([uidObj unsignedLongLongValue] == uid) {
                                int state = [(NSNumber*)onlineStates[uidObj] intValue];
                                memberNode.isOffline = (state==EB_LINE_STATE_UNKNOWN || state==EB_LINE_STATE_OFFLINE)?YES:NO;
                            }
                        }
                    }

                    [RelationshipHelper sortNodes:returnMemberNodes]; //排序
                    completionBlock(returnMemberNodes); //回调返回结果集
                    isReturn = YES; //标记本block执行结束
                    
                    //重载tableview
//                    [tableTree reloadData];
                }];
            } onFailure:^(NSError *error) {
                NSLog(@"加载成员在线状态失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
            }];
        }
        
        //关闭提示框
        [BlockUtility performBlockInMainQueue:^{
            CloseAlertView();
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"加载成员信息失败, code = %@, msg = %@", @(error.code), error.localizedDescription);
        //关闭提示框
        [BlockUtility performBlockInMainQueue:^{
            CloseAlertView();
        }];
    }];
}

@end
