//
//  MemberSelectedDeepInViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/20.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "MemberSelectedDeepInViewController.h"
#import "MemberSeletedViewController.h"
#import "ENTBoostChat.h"
#import "ENTBoost.h"
#import "ENTBoost+Utility.h"
#import "BlockUtility.h"
#import "CustomSeparator.h"
#import "FVCustomAlertView.h"
#import "RelationshipHelper.h"
#import "ButtonKit.h"

@interface MemberSelectedDeepInViewController ()
{
    BOOL _isInited; //是否已经执行过初始化
    
    TableTree *_enterpriseTree; //企业组织架构
    UIStoryboard* _contactStoryobard;
}

@property(nonatomic, strong) IBOutlet UIView* toolbar; //顶上仿工具栏视图
@property(nonatomic, strong) IBOutlet CustomSeparator* toobarVerticalBorder; //竖线
@property(nonatomic, strong) IBOutlet CustomSeparator* toolbarBottomBorder; //仿工具栏下边框
@property(nonatomic, strong) IBOutlet UIView* treeContainer; //树显示容器

@property(nonatomic, strong) IBOutlet UIButton* gotoLastButton; //返回上一级按钮
@property(nonatomic, strong) IBOutlet UIButton* gotoTopButton; //返回最顶级按钮
@end

@implementation MemberSelectedDeepInViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _contactStoryobard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_CONTACT bundle:nil];
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
        [RelationshipHelper loadNodesInGroup:self.parentGroupInfo tableTree:_enterpriseTree isHiddenTalkBtn:YES isHiddenPropertiesBtn:YES isHiddenTickBtn:NO isHiddenGroupTickBtn:YES onCompletion:^(NSArray *nodes) {
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
    self.navigationItem.title = [NSString stringWithFormat:@"%@[选择成员]", self.parentGroupInfo.depName];
//    CGRect btnFrame = CGRectMake(0, 0, 30, 24);
    
//    //左边按钮1
//    UIButton* lBtn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 24)];
//    [lBtn1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//    [lBtn1 setImage:[UIImage imageNamed:@"navigation_goback"] forState:UIControlStateNormal];
//    UIBarButtonItem * leftButton1 = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
//    leftButton1.customView = lBtn1;
    
//    //右边按钮1
//    UIButton* rbtn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 24)];
//    [rbtn1 addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
//    [rbtn1 setImage:[UIImage imageNamed:@"navigation_search"] forState:UIControlStateNormal];
//    UIBarButtonItem * rightButton1 = [[UIBarButtonItem alloc] initWithTitle:@"查找" style:UIBarButtonItemStylePlain target:nil action:nil];
//    rightButton1.customView = rbtn1;
    
//    //右边按钮1
//    UIButton* rbtn1 = [[UIButton alloc] initWithFrame:btnFrame];
//    [rbtn1 addTarget:self action:@selector(saveMembers) forControlEvents:UIControlEventTouchUpInside];
//    [rbtn1 setImage:[UIImage imageNamed:@"navigation_save"] forState:UIControlStateNormal];
//    UIBarButtonItem * rightButton1 = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:nil action:nil];
//    rightButton1.customView = rbtn1;
    
    self.navigationItem.leftBarButtonItem   = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    self.navigationItem.rightBarButtonItem  = [ButtonKit saveBarButtonItemWithTarget:self action:@selector(saveMembers)];
    
//    self.navigationItem.rightBarButtonItems = @[rightButton1];
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
    NSArray* controllers = [self.navigationController viewControllers];
    for (UIViewController* controller in controllers) {
        if ([controller isMemberOfClass:[MemberSeletedViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSArray*)tickCheckedNodes
{
    return [_enterpriseTree tickCheckedNodes];
}

//保存成员
- (void)saveMembers
{
    //发送保存邀请成员的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:EB_CHAT_NOTIFICATION_INVITE_MEMBER object:self userInfo:nil];
//    //返回顶层界面
//    [self goTop];
}

#pragma mark - TableTreeDelegate
- (void)tableTree:(TableTree *)tableTree deepInToNode:(TableTreeNode *)node
{
    EBGroupInfo* groupInfo;
    if ([RelationshipHelper tableTree:tableTree deepInToNode:node groupInfo:&groupInfo]) {
        MemberSelectedDeepInViewController* mdvc = [_contactStoryobard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_MEMBER_SELECTED_DEEPIN_CONTROLLER];
        mdvc.parentGroupInfo = groupInfo;
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
