//
//  UserInformationViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/8.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "UserInformationViewController.h"
#import "ENTBoostChat.h"
#import "ENTBoost.h"
#import "BlockUtility.h"
#import "ENTBoost+Utility.h"
#import "InformationCell1.h"
#import "CustomSeparator.h"
#import "RelationshipHelper.h"
#import "ButtonKit.h"
#import "ResourceKit.h"
#import "CellUtility.h"
#import "GroupInformationViewController.h"
#import "CommonTextInputViewController.h"
#import "HeadPhotoSettingViewController.h"
#import "ControllerManagement.h"
#import "FVCustomAlertView.h"

@interface UserInformationViewController ()
{
    UIStoryboard* _settingStoryboard;
}

@property(nonatomic) BOOL canEditProperty; //是否允许编辑字段属性

@property(strong, nonatomic) NSMutableArray* names1; //各项字段名
@property(strong, nonatomic) NSMutableArray* names2; //各项字段名

@property(strong, nonatomic) NSMutableArray* contents1; //各项内容
@property(strong, nonatomic) NSMutableArray* contents2; //各项内容

@property(strong, nonatomic) NSMutableDictionary* keyboardTypes1; //编辑属性使用的键盘类型
@property(strong, nonatomic) NSMutableDictionary* keyboardTypes2; //编辑属性使用的键盘类型

@property(strong, nonatomic) NSMutableDictionary* accessories1; //附加功能
@property(strong, nonatomic) NSMutableDictionary* accessories2; //附加功能


@property(strong, nonatomic) NSMutableArray* functions; //操作功能

@end

@implementation UserInformationViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self =[super initWithCoder:aDecoder]) {
        _settingStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_SETTING bundle:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.targetMemberInfo?[NSString stringWithFormat:@"%@成员资料", [GroupInformationViewController nameWithGroupType:self.targetGroupInfo.type]]:@"用户资料";
    
    //导航栏左边按钮1
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    
    //准备数据
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    uint64_t myUid = ebKit.accountInfo.uid;
    if (self.targetMemberInfo) { //部门或群组成员
        //判断是否允许开启编辑功能
        //1. 群组成员，且是当前用户(自己)
        //2. 部门成员，且有编辑成员的权限；企业创建者
        //3. 群组或部门的创建者
        
        //查询当前用所属企业资料
        __block EBEnterpriseInfo* enterpriseInfo;
        if (self.targetGroupInfo.entCode!=0) {
            __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            [ebKit loadEnterpriseInfoOnCompletion:^(EBEnterpriseInfo *loadedEnterpriseInfo) {
                enterpriseInfo = loadedEnterpriseInfo;
                dispatch_semaphore_signal(sem);
            } onFailure:^(NSError *error) {
                NSLog(@"loadEnterpriseInfo error, code = %@, msg = %@", @(error.code), error.localizedDescription);
                dispatch_semaphore_signal(sem);
            }];
            dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 3.0f * NSEC_PER_SEC));
        }

        if (!self.isReadonly) {
            if ((self.targetGroupInfo.entCode==0 && self.uid==myUid) //群组且自己
                || (self.targetGroupInfo.entCode!=0 && ( (self.myMemberInfo.managerLevel&EB_LEVEL_EMP_EDIT)==EB_LEVEL_EMP_EDIT || enterpriseInfo.creatorUid==myUid || (self.targetGroupInfo.creatorUid==myUid) ) ) //部门且(成员管理权限或企业资料创建者或部门创建者)
                /*|| (self.targetGroupInfo.creatorUid==myUid)*/) { //群主
                self.canEditProperty = YES;
            }
        }
        
        //行名称
        self.names1 = [@[@"手机", @"电话", @"邮箱", @"群(部门)", @"职务"] mutableCopy];
        [self.names1 replaceObjectAtIndex:3 withObject:[GroupInformationViewController nameWithGroupType:self.targetGroupInfo.type]];
        //附加属性定义
        self.accessories1 = [@{@0:@(UITableViewCellAccessoryDisclosureIndicator), @1:@(UITableViewCellAccessoryDisclosureIndicator), @2:@(UITableViewCellAccessoryDisclosureIndicator), @4:@(UITableViewCellAccessoryDisclosureIndicator)} mutableCopy]; //第n行xxx操作，未定义的默认none操作
        //编辑属性使用的键盘类型，未定义的默认UIKeyboardTypeDefault类型
        self.keyboardTypes1 = [@{@0:@(UIKeyboardTypePhonePad), @1:@(UIKeyboardTypePhonePad), @2:@(UIKeyboardTypeEmailAddress)} mutableCopy];
        //填充数据
        [self fillContent];
        
        //群组和讨论组不显示职务
        if (!self.targetGroupInfo || !self.targetGroupInfo.entCode) {
            [self.names1 removeLastObject];
            [self.contents1 removeLastObject];
            [self.accessories1 removeObjectForKey:@4];
        }
    } else { //单独用户
        //行名称
        self.names1 = [@[@"手机", @"电话", @"邮箱"] mutableCopy];
        //附加属性定义
        self.accessories1   = [@{} mutableCopy]; //第n行xxx操作，未定义的默认none操作
        //编辑属性使用的键盘类型，未定义的默认UIKeyboardTypeDefault类型
        self.keyboardTypes1 = [@{} mutableCopy];
        
        self.names2 = [@[@"公司", @"部门", @"职务", @"地址"] mutableCopy];
        self.accessories2   = [@{} mutableCopy];
        self.keyboardTypes2 = [@{} mutableCopy];
        
        //填充数据
        [self fillContent];
    }
    
    EBAccountInfo* accountInfo = ebKit.accountInfo;
    self.functions = [[NSMutableArray alloc] init];
    //不能给自己发送消息
    if (self.uid != accountInfo.uid && !self.isReadonly)
        [self.functions addObject:INFORMATION_FUNCTION_SHOW_TALK];
    
    //不是自己及未验证才显示验证按钮
    if (self.uid != accountInfo.uid && !self.isReadonly) {
        EBContactInfo* contactInfo = [ebKit contactInfoWithUid:self.uid];
        if (!contactInfo || (!contactInfo.verified && ebKit.isContactNeedVerification))
            [self.functions addObject:INFORMATION_FUNCTION_VERIFY_CONTACT];
    }
    
    //设置默认电子名片
    //当前成员是自己；当前成员资料还未设置为默认电子名片
    if (self.uid==accountInfo.uid && accountInfo.defaultEmpCode!=self.targetMemberInfo.empCode) {
        [self.functions addObject:INFORMATION_FUNCTION_SET_DEFAULT_EMP];
    }
    
    //1.当前用户拥有删除该所属部门或群组成员的权限
    //2.或当前用户是创建者(群主)
    if (self.targetGroupInfo && self.targetMemberInfo && !self.isReadonly) {
        if ( (self.myMemberInfo.managerLevel&EB_LEVEL_EMP_DELETE)==EB_LEVEL_EMP_DELETE || self.targetGroupInfo.creatorUid==accountInfo.uid) {
            if (self.targetGroupInfo.entCode>0) { //部门成员
                [self.functions addObject:INFORMATION_FUNCTION_DELETE_MEMBER];
            } else if (self.targetGroupInfo.creatorUid==accountInfo.uid && self.targetMemberInfo.uid!=accountInfo.uid) { //群主，而且成员不是当前用户(自己)
                [self.functions addObject:INFORMATION_FUNCTION_DELETE_MEMBER];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//填充数据
- (void)fillContent
{
    if (self.targetMemberInfo) { //部门或群组成员
        EBMemberInfo* memberInfo = self.targetMemberInfo;
        //行内容1
        self.contents1 = [@[REALVALUE(memberInfo.cellPhone), REALVALUE(memberInfo.workPhone), REALVALUE(memberInfo.email), REALVALUE(self.targetGroupInfo.depName), REALVALUE(memberInfo.jobTitle)] mutableCopy];
    } else { //单独用户
        EBVCard* vCard = self.vCard;
        //行内容1
        self.contents1 = [@[REALVALUE(vCard.phone), REALVALUE(vCard.telphone), REALVALUE(vCard.email)] mutableCopy];
        //行内容2
        self.contents2 = [@[REALVALUE(vCard.entName), REALVALUE(vCard.depName), REALVALUE(vCard.title), REALVALUE(vCard.address)] mutableCopy];
    }
}

//返回上一级
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else if (section == 1)
        return self.names1.count;
    else if (section == 2)
        return self.names2.count;
    else if (section == 3)
        return self.functions.count?1:0;
    
    return 0;
}

static NSString *CellIdentifier1 = @"subtitleInformationCell_1";
//    static NSString *LeftDetailInformationCell1 = @"leftDetailInformationCell_1";
static NSString *LeftDetailInformationCell2 = @"leftDetailInformationCell_2";
static NSString *RightDetailInformationCell1 = @"rightDetailInformationCell_1";
static NSString *ButtonCell1 = @"buttonCell_1";
static NSString *ButtonCell2 = @"buttonCell_2";
static NSString *ButtonCell3 = @"buttonCell_3";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    InformationCell1 *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        
        EBMemberInfo* memberInfo = self.targetMemberInfo;
        cell.customTextLabel.text = memberInfo?memberInfo.userName:self.vCard.name;
        cell.customDetailTextLabel.text = [NSString stringWithFormat:@"账号 : %@", memberInfo?memberInfo.empAccount:self.account];
        cell.customDetailTextLabel2.text = [NSString stringWithFormat:@"编号 : %llu", memberInfo?memberInfo.uid:self.uid];
        cell.customDetailTextLabel2.font = cell.customDetailTextLabel.font; //设置两个文本框字体相同
        
        if (self.canEditProperty) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = [self.accessories1[@(indexPath.row)] intValue];
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        //删除旧手势事件
        if (cell.customTapRecognizer)
            [cell.customImageView removeGestureRecognizer:cell.customTapRecognizer];
        
        if (!self.isReadonly && self.uid==ebKit.accountInfo.uid
            && self.myMemberInfo && self.targetMemberInfo && self.myMemberInfo.empCode==self.targetMemberInfo.empCode) {
            //添加新手势事件
            cell.customTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headPhotoSetting:)];
            [cell.customImageView addGestureRecognizer:cell.customTapRecognizer];
        }
        
        //显示头像图片
        EBResourceInfo* headPhotoInfo = memberInfo?memberInfo.headPhotoInfo:self.vCard.headPhotoInfo;
        if (headPhotoInfo) {
//            __weak typeof(self) safeSelf = self;
            [ebKit loadResourceWithResourceInfo:headPhotoInfo onCompletion:^(NSString *filePath) {
                if (filePath) {
                    [BlockUtility performBlockInMainQueue:^{
//                        [safeSelf showHeadPhotoWithFilePath:filePath inImageView:cell.customImageView];
                        [ResourceKit showUserHeadPhotoWithFilePath:filePath inImageView:cell.customImageView];
                    }];
                }
            } onFailure:^(NSError *error) {
                NSLog(@"load head photo by ResourceInfo error, code = %@, msg = %@", @(error.code), error.localizedDescription);
                [BlockUtility performBlockInMainQueue:^{ //在主线程中执行
//                    [safeSelf showHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
                    [ResourceKit showUserHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
                }];
            }];
        } else {
//            [self showHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
            [ResourceKit showUserHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
        }
        
        //设置圆角边框
        EBCHAT_UI_SET_CORNER_VIEW(cell.customImageView, 1.0f, [UIColor clearColor]);
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:RightDetailInformationCell1 forIndexPath:indexPath];
        cell.customTextLabel.text = self.names1[indexPath.row];
        cell.customDetailTextLabel.text = self.contents1[indexPath.row];
        
        if (self.canEditProperty && self.accessories1[@(indexPath.row)]) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = [self.accessories1[@(indexPath.row)] intValue];
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:LeftDetailInformationCell2 forIndexPath:indexPath];
        cell.customTextLabel.text = self.names2[indexPath.row];;
        cell.customDetailTextLabel.text = self.contents2[indexPath.row];
        
        //地址字段
        if (indexPath.row == 3) {
            cell.customDetailTextLabel.numberOfLines = 0; //不限制行数
            cell.customDetailTextLabel.lineBreakMode = NSLineBreakByWordWrapping; //设置自动换行模式
            //改变宽度约束
            NSArray* constraints = [cell.customDetailTextLabel constraints];
            for (NSLayoutConstraint* constraint in constraints) {
                if (constraint.firstAttribute == NSLayoutAttributeWidth && constraint.firstItem == cell.customDetailTextLabel) {
                    CGFloat marginX = 20.0;
                    CGFloat sepparatorX = 10.0;
                    CGFloat width = cell.contentView.bounds.size.width - marginX - sepparatorX - cell.customTextLabel.bounds.size.width;
                    constraint.constant = width;
                    break;
                }
            }
        }
    } else if (indexPath.section == 3){
        cell = [self tableView:tableView functionCellForRowAtIndexPath:indexPath];
    }
    
    if (indexPath.row==0 && [cell isKindOfClass:CustomCell.class])
        cell.hiddenCustomSeparatorTop = NO; //显示顶部分隔线
    
//    //IOS6以下设置背景色
//    if (!IOS7) {
//        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
//        backgrdView.backgroundColor = [UIColor colorWithHexString:@"#EFFAFE"];
//        cell.backgroundView = backgrdView;
//    }
    
    return cell;
}

- (InformationCell1*)tableView:(UITableView *)tableView functionCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    
    return [CellUtility tableView:tableView functionCellForRowAtIndexPath:indexPath identifier:ButtonCell3 functions:self.functions buttonBlock:^(UIButton *button, NSString* function) {
        if ([function isEqualToString:INFORMATION_FUNCTION_SHOW_TALK]) {
            [button setTitle:@"发送消息" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(showTalk) forControlEvents:UIControlEventTouchUpInside];
        } else if ([function isEqualToString:INFORMATION_FUNCTION_VERIFY_CONTACT]) {
            [button setTitle:[ebKit isContactNeedVerification]?@"邀请为好友":@"加入通讯录" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(verifyOrCreateContact) forControlEvents:UIControlEventTouchUpInside];
        } else if ([function isEqualToString:INFORMATION_FUNCTION_DELETE_MEMBER]) {
            [button setTitle:[NSString stringWithFormat:@"移除%@", self.targetGroupInfo.entCode?@"员工":@"成员"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(deleteMember) forControlEvents:UIControlEventTouchUpInside];
        } else if ([function isEqualToString:INFORMATION_FUNCTION_SET_DEFAULT_EMP]) {
            [button setTitle:@"设置为默认电子名片" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(setDefaultEmp) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

//显示聊天会话界面
- (void)showTalk
{
    EBMemberInfo*   memberInfo  = self.targetMemberInfo;
    uint64_t        uid         = memberInfo?memberInfo.uid:self.uid;
    NSString*       account     = memberInfo?memberInfo.empAccount:self.account;
    NSString*       userName    = memberInfo?memberInfo.userName:self.vCard.name;
    uint64_t        otherEmpCode= memberInfo?memberInfo.empCode:0;
    
    if (uid || account) {
        //退出当前页面
//        [self.navigationController popViewControllerAnimated:NO];
        
        //发送显示聊天界面通知
        [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_SHOW_TALK object:self userInfo:@{@"informationType":@"USER" ,@"otherUid":@(uid), @"otherAccount":account, @"otherUserName":REALVALUE(userName), @"otherEmpCode":@(otherEmpCode)}];
        
//        if ([self.delegate respondsToSelector:@selector(userInformationViewController:needExitParentController:)])
//            [self.delegate userInformationViewController:self needExitParentController:YES];
    }
}

//好友验证或加入通讯录
- (void)verifyOrCreateContact
{
    EBMemberInfo* memberInfo  = self.targetMemberInfo;
    uint64_t uid = memberInfo?memberInfo.uid:self.uid;
    
    if (![[ENTBoostKit sharedToolKit] isContactNeedVerification]) {
        //加入通讯录
        EBContactInfo* contactInfo = [[EBContactInfo alloc] init];
        contactInfo.uid = uid;
        contactInfo.account = memberInfo?memberInfo.empAccount:self.account;
        contactInfo.name = memberInfo?memberInfo.userName:self.vCard.name;
        
        [RelationshipHelper manageContact:@{@"type":@"create", @"contactInfo":contactInfo}];
    } else {
        [RelationshipHelper manageContact:@{@"type":@"verify", @"uid":@(uid)}];
    }
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:EB_CHAT_NOTIFICATION_ADD_CONTACT object:self userInfo:@{@"type":type, @"uid":@(self.uid)}];
    
//    [self goBack];
}

//删除当前群组成员
- (void)deleteMember
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"删除%@", self.targetGroupInfo.entCode?@"员工":@"成员"] message:@"真的要删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

//设置默认电子名片
- (void)setDefaultEmp
{
    ShowAlertView();
    
    __weak typeof(self) safeSelf = self;
    [[ENTBoostKit sharedToolKit] editUserDefaultEmp:self.targetMemberInfo.empCode onCompletion:^{
        //更新界面
        [BlockUtility performBlockInMainQueue:^{
            //删除操作按钮
            for (int i=0; i<safeSelf.functions.count; i++) {
                NSString* function = safeSelf.functions[i];
                if ([function isEqualToString:INFORMATION_FUNCTION_SET_DEFAULT_EMP]) {
                    [safeSelf.functions removeObjectAtIndex:i];
                    break;
                }
            }
            
            if (safeSelf.functions.count==0) //删除按钮行
                [safeSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
            else //刷新按钮行
                [safeSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
            
            if ([safeSelf.delegate respondsToSelector:@selector(userInformationViewController:needUpdateParentController:)])
                [safeSelf.delegate userInformationViewController:safeSelf needUpdateParentController:YES];
            
            CloseAlertView();
        }];
        
        [NSThread sleepForTimeInterval:1.0];
        
        [BlockUtility performBlockInMainQueue:^{
            ShowCommonAlertView(@"设置成功");
            [safeSelf performSelector:@selector(executeCloseAlertView) withObject:nil afterDelay:1.5];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"editUserDefaultEmp error, code = %@, msg = %@", @(error.code), error.localizedDescription);
        CloseAlertView();
    }];
}

//设置头像界面
- (void)headPhotoSetting:(UITapGestureRecognizer*)gesRecg
{
    HeadPhotoSettingViewController* vc = [_settingStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_HEAD_PHOTO_SETTING_CONTROLLER];
    vc.delegate = self;
    vc.memberInfo = self.targetMemberInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

//执行关闭提示窗口
- (void)executeCloseAlertView
{
    CloseAlertView();
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //发送删除成员的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:EB_CHAT_NOTIFICATION_DELETE_MEMBER object:self userInfo:@{@"empCode":@(self.targetMemberInfo.empCode), @"depCode":@(self.targetGroupInfo.depCode)}];
        [self goBack];
    }
}

#pragma mark -  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 80;
    } else if (indexPath.section == 1){
        return 36;
    } else if (indexPath.section == 2){
        if (indexPath.row==3)
            return 50;
        return 36;
    } else {
        return 50;
    }
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
    if (section == 3)
        return HEIGHT_FOR_HEADER_FOOTER;
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, HEIGHT_FOR_HEADER_FOOTER)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    return view;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; //取消选中本行
    
    if (!self.canEditProperty || self.isReadonly)
        return;
    
    UIViewController* pvc;
    if (indexPath.section==0) {
        CommonTextInputViewController* vc = [[ControllerManagement sharedInstance] fetchCommonTextInputControllerWithNavigationTitle:@"编辑名称" defaultText:self.targetMemberInfo.userName textInputViewHeight:0.f delegate:self];
        vc.customTag1 = indexPath.row;
        vc.customTag2 = indexPath.section;
        vc.returnKeyType = UIReturnKeyDone;
//        vc.keyboardType = UIKeyboardTypeDefault;
        
        pvc = vc;
    } else if (indexPath.section==1) {
        if (!self.accessories1[@(indexPath.row)] || [self.accessories1[@(indexPath.row)] intValue]==UITableViewCellAccessoryNone)
            return;
        
        CommonTextInputViewController* vc = [[ControllerManagement sharedInstance] fetchCommonTextInputControllerWithNavigationTitle:[NSString stringWithFormat:@"编辑%@", self.names1[indexPath.row]] defaultText:self.contents1[indexPath.row] textInputViewHeight:0.f delegate:self];
        vc.customTag1 = indexPath.row;
        vc.customTag2 = indexPath.section;
        vc.returnKeyType = UIReturnKeyDone;
        if (self.keyboardTypes1[@(indexPath.row)])
            vc.keyboardType = [self.keyboardTypes1[@(indexPath.row)] intValue];
        pvc = vc;
    }
    
    if(pvc)
        [self.navigationController pushViewController:pvc animated:YES];
}

#pragma mark - CommonTextInputViewControllerDelgate

- (void)commonTextInputViewController:(CommonTextInputViewController *)commonTextInputViewController wantToSaveInputText:(NSString *)text
{
    //只接受保存部门或群组成员资料编辑结果
    if (!self.targetMemberInfo) {
        NSLog(@"只接受保存部门或群组成员资料编辑结果");
        return;
    }
    
    NSString* newValue = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!newValue) newValue = @"";
    
    EBMemberInfo* newMemberInfo = [[EBMemberInfo alloc] init];
    newMemberInfo.empCode = self.targetMemberInfo.empCode;
    
    if (commonTextInputViewController.customTag2==0) {
        //@"名称"
        switch (commonTextInputViewController.customTag1) {
            case 0:
                newMemberInfo.userName = newValue;
                break;
            default:
                break;
        }
    } else if (commonTextInputViewController.customTag2==1) {
        //@"手机", @"电话", @"邮箱", @"群(部门)", @"职务"
        switch (commonTextInputViewController.customTag1) {
            case 0:
                newMemberInfo.cellPhone = newValue;
                break;
            case 1:
                newMemberInfo.workPhone = newValue;
                break;
            case 2:
                newMemberInfo.email = newValue;
                break;
            case 4:
                newMemberInfo.jobTitle = newValue;
                break;
            default:
                break;
        }
    }
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:commonTextInputViewController.customTag1 inSection:commonTextInputViewController.customTag2];
    __weak typeof(self) safeSelf = self;
    [[ENTBoostKit sharedToolKit] editMemberInfo:newMemberInfo onCompletion:^(EBMemberInfo *memberInfo) {
        [BlockUtility performBlockInMainQueue:^{
            //更新当前视图
            safeSelf.targetMemberInfo = memberInfo;
            if (safeSelf.myMemberInfo.empCode == memberInfo.empCode)
                self.myMemberInfo = memberInfo;
            
            [safeSelf fillContent];
            [safeSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            //触发事件
            if ([safeSelf.delegate respondsToSelector:@selector(userInformationViewController:updateMemberInfo:dataObject:)]) {
                [safeSelf.delegate userInformationViewController:safeSelf updateMemberInfo:memberInfo dataObject:safeSelf.dataObject];
            }
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"修改成员资料失败，code=%@, msg = %@", @(error.code), error.localizedDescription);
        [BlockUtility performBlockInMainQueue:^{
            [safeSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }];
}


#pragma mark - HeadPhotoSettingViewControllerDelegate

- (void)headPhotoSettingViewController:(HeadPhotoSettingViewController *)viewController updateHeadPhoto:(uint64_t)resId dataObject:(id)dataObject
{
    if (viewController.memberInfo) {
        self.myMemberInfo = viewController.memberInfo;
        self.targetMemberInfo = viewController.memberInfo;
    }
    
    //重载头像位置所在行
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    //回调上层
    if ([self.delegate respondsToSelector:@selector(userInformationViewController:updateMemberInfo:dataObject:)])
        [self.delegate userInformationViewController:self updateMemberInfo:self.targetMemberInfo dataObject:self.dataObject];
//        [self.delegate myInformationViewController:self updateAccountInfo:[ENTBoostKit sharedToolKit].accountInfo dataObject:self.dataObject];
}

@end
