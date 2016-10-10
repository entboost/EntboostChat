//
//  GroupInformationViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/10.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "GroupInformationViewController.h"
#import "MemberSeletedViewController.h"
#import "CommonTextInputViewController.h"
#import "CaptionEditViewController.h"
#import "MemberListViewController.h"
#import "ControllerManagement.h"
#import "ENTBoostChat.h"
#import "BlockUtility.h"
#import "ENTBoost+Utility.h"
#import "InformationCell1.h"
#import "CustomSeparator.h"
#import "ButtonKit.h"
#import "CellUtility.h"
#import "ResourceKit.h"

@interface GroupInformationViewController () <CommonTextInputViewControllerDelgate, MemberSeletedViewControllerDelegate>
{
    UIStoryboard* _contactStoryobard;
    UIStoryboard* _otherStoryboard;
    UIStoryboard* _settingStoryboard;
}

@property(strong, nonatomic) NSMutableArray* names1; //各项字段名
@property(strong, nonatomic) NSMutableArray* contents1; //各项内容
@property(strong, nonatomic) NSMutableArray* names2; //各项字段名
@property(strong, nonatomic) NSMutableArray* contents2; //各项内容

@property(strong, nonatomic) NSDictionary* keyboardTypes1; //编辑属性使用的键盘类型
@property(strong, nonatomic) NSDictionary* keyboardTypes2; //编辑属性使用的键盘类型
@property(strong, nonatomic) NSDictionary* accessories1; //附加功能
@property(strong, nonatomic) NSDictionary* accessories2; //附加功能

@property(strong, nonatomic) NSMutableArray* functions; //操作功能

@end

@implementation GroupInformationViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _contactStoryobard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_CONTACT bundle:nil];
        _otherStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_OTHER bundle:nil];
        _settingStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_SETTING bundle:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@资料", [GroupInformationViewController nameWithGroupType:self.groupInfo.type]];//self.groupInfo.entCode?@"部门资料":@"群组资料";
    
    //导航栏左边按钮1
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    
    //行名称
    self.names1 = [@[@"人数", @"电话", @"传真", @"邮箱"] mutableCopy];
    
    //附加属性定义
    self.accessories1 = @{@0:@(UITableViewCellAccessoryDisclosureIndicator), @1:@(UITableViewCellAccessoryDisclosureIndicator), @2:@(UITableViewCellAccessoryDisclosureIndicator), @3:@(UITableViewCellAccessoryDisclosureIndicator)}; //第n行xxx操作，未定义的默认none操作
    //编辑属性使用的键盘类型，未定义的默认UIKeyboardTypeDefault类型
    self.keyboardTypes1 = @{@1:@(UIKeyboardTypePhonePad), @2:@(UIKeyboardTypePhonePad), @3:@(UIKeyboardTypeEmailAddress)};
    
    self.names2 = [@[@"公司", @"主页", @"地址"] mutableCopy];
    self.accessories2 = @{@1:@(UITableViewCellAccessoryDisclosureIndicator), @2:@(UITableViewCellAccessoryDisclosureIndicator)};
    self.keyboardTypes2 = @{};
    //如果非企业则不显示“公司”字段
    if (!self.enterpriseInfo) {
        [self.names2 removeObjectAtIndex:0];
        self.accessories2 = @{@0:@(UITableViewCellAccessoryDisclosureIndicator), @1:@(UITableViewCellAccessoryDisclosureIndicator)};
        
        self.keyboardTypes2 = @{@0:@(UIKeyboardTypeURL)};
    } else {
        self.keyboardTypes2 = @{@1:@(UIKeyboardTypeURL)};
    }
    
    //填充数据
    [self prepareData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回上一级
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//是否拥有编辑群组资料权限
- (BOOL)canEditGroupInfo
{
    uint64_t myUid = [ENTBoostKit sharedToolKit].accountInfo.uid;
    EB_MANAGER_LEVEL mgrLevel = self.myMemberInfo.managerLevel;
    
    return ((mgrLevel&EB_LEVEL_DEP_EDIT)==EB_LEVEL_DEP_EDIT || self.groupInfo.creatorUid==myUid || (self.groupInfo.entCode && self.enterpriseInfo.creatorUid==myUid));
}

//准备数据
- (void)prepareData
{
    [self fillContent];
    
    //定义功能按钮
    self.functions = [[NSMutableArray alloc] init];
    
    uint64_t myUid = [ENTBoostKit sharedToolKit].accountInfo.uid;
    EB_MANAGER_LEVEL mgrLevel = self.myMemberInfo.managerLevel;
    
    //当前用户属于该群组的成员才允许发送消息
    if (self.groupInfo.myEmpCode)
        [self.functions addObject:INFORMATION_FUNCTION_SHOW_TALK];
    
    //拥有管理成员的权限或群主
    if ((mgrLevel&EB_LEVEL_EMP_EDIT)==EB_LEVEL_EMP_EDIT || self.groupInfo.creatorUid==myUid || (self.groupInfo.entCode && self.enterpriseInfo.creatorUid==myUid))
        [self.functions addObject:INFORMATION_FUNCTION_INVITE_MEMBER];
    
    //0.不允许退出部门
    //1.当前用户在群组内才需要退出群组功能
    //2.在个人群组和临时讨论组情况下，不是群主才可以退出群组
    //3.在部门和项目组情况下，需要有管理成员功能或创建者才可以退出群组
    if (self.groupInfo.entCode==0) {
        if (self.groupInfo.myEmpCode && (self.groupInfo.creatorUid!=myUid))
            [self.functions addObject:INFORMATION_FUNCTION_EXIT_GROUP];
    }
//    if (self.groupInfo.entCode==0) {
//        if (self.groupInfo.myEmpCode
//            && ((!self.groupInfo.entCode && self.groupInfo.creatorUid!=myUid) || (self.groupInfo.entCode && ((mgrLevel&EB_LEVEL_DEP_ADMIN)==EB_LEVEL_DEP_ADMIN || self.groupInfo.creatorUid==myUid))))
//            [self.functions addObject:INFORMATION_FUNCTION_EXIT_GROUP];
//    }
    
    //有删除群组或部门权限功能可以解散
    //创建者(群主)可以解散
    //企业创建者可以解散
    if ((mgrLevel&EB_LEVEL_DEP_DELETE)==EB_LEVEL_DEP_DELETE || self.groupInfo.creatorUid==myUid || (self.groupInfo.entCode && self.enterpriseInfo.creatorUid==myUid))
        [self.functions addObject:INFORMATION_FUNCTION_DELETE_GROUP];
}

- (void)fillContent
{
    EBGroupInfo* gInfo = self.groupInfo;
    self.contents1 = [@[[NSString stringWithFormat:@"%@人", @(gInfo.memberCount)], gInfo.phone?gInfo.phone:@"", gInfo.fax?gInfo.fax:@"", gInfo.email?gInfo.email:@""] mutableCopy];
    
    self.contents2 = [@[self.enterpriseInfo.entName?self.enterpriseInfo.entName:@"", gInfo.url?gInfo.url:@"",gInfo.address?gInfo.address:@""] mutableCopy];
    if (!self.enterpriseInfo)
        [self.contents2 removeObjectAtIndex:0];
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

+ (NSString*)nameWithGroupType:(EB_GROUP_TYPE)groupType
{
    switch (groupType) {
        case EB_GROUP_TYPE_DEPARTMENT:
            return @"部门";
            break;
        case EB_GROUP_TYPE_PROJECT:
            return @"项目组";
            break;
        case EB_GROUP_TYPE_GROUP:
            return @"群组";
            break;
        case EB_GROUP_TYPE_TEMP:
            return @"讨论组";
            break;
        default:
            break;
    }
    
    return nil;
}

static NSString *CellIdentifier1 = @"subtitleInformationCell_1";
//    //    static NSString *LeftDetailInformationCell1 = @"leftDetailInformationCell_1";
static NSString *LeftDetailInformationCell2 = @"leftDetailInformationCell_2";
static NSString *RightDetailInformationCell1 = @"rightDetailInformationCell_1";
static NSString *ButtonCell1 = @"buttonCell_1";
static NSString *ButtonCell2 = @"buttonCell_2";
static NSString *ButtonCell3 = @"buttonCell_3";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EBGroupInfo* gInfo = self.groupInfo;
    InformationCell1 *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        
        //判断是否有编辑权限
        if ([self canEditGroupInfo]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.customTextLabel.text = gInfo.depName;
        cell.customDetailTextLabel.text = (gInfo.type==EB_GROUP_TYPE_TEMP)?@"":[NSString stringWithFormat:@"编号:%llu", gInfo.depCode];
        
        cell.customDetailTextLabel2.text = self.groupInfo.descri.length>0?self.groupInfo.descri:((gInfo.type==EB_GROUP_TYPE_TEMP)?@"没有留下任何备注信息！":@""); //@"fjk疯狂的时间飞快的，jdk sjfkdsj 是空间打开手机发快递 sjfkd看风景的手机发的dsjdsjfkdjsdkfdfjkdsfjkdjfkdsjfkdsfdssfjdksfjdk";
        cell.customDetailTextLabel2.numberOfLines = 2; //2行
        cell.customDetailTextLabel2.lineBreakMode = NSLineBreakByTruncatingTail; //设置自动换行模式
        
        //改变宽度约束
        NSArray* constraints = [cell.customDetailTextLabel2 constraints];
        for (NSLayoutConstraint* constraint in constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeWidth && constraint.firstItem == cell.customDetailTextLabel2) {
                CGFloat marginX = 20.0;
                CGFloat sepparatorX = 10.0;
                CGFloat width = cell.contentView.bounds.size.width - marginX - sepparatorX - cell.customImageView.bounds.size.width;
                constraint.constant = width;
                break;
            }
        }
        
        //显示头像图片
        [ResourceKit showGroupHeadPhotoWithFilePath:nil inImageView:cell.customImageView forGroupType:gInfo.type];
//        [self showHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
        
        //设置圆角边框
        EBCHAT_UI_SET_CORNER_VIEW(cell.customImageView, 1.0f, [UIColor clearColor]);
    } else if (indexPath.section == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:RightDetailInformationCell1 forIndexPath:indexPath];
        cell.customTextLabel.text = self.names1[indexPath.row];
        cell.customDetailTextLabel.text = self.contents1[indexPath.row];
        
        //点击编辑功能
        if ([self canEditGroupInfo]) {
            if (self.accessories1[@(indexPath.row)]) {
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = [self.accessories1[@(indexPath.row)] intValue];
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        //始终允许进入查看"成员人数"
        if (indexPath.row==0) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = [self.accessories1[@(indexPath.row)] intValue];
        }
    } else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:LeftDetailInformationCell2 forIndexPath:indexPath];
        
        cell.customTextLabel.text = self.names2[indexPath.row];
        
        cell.customDetailTextLabel.text = self.contents2[indexPath.row];
        
        if (indexPath.row==(self.groupInfo.entCode>0?2:1)) //部门页面比群组页面多一行
            cell.customDetailTextLabel.numberOfLines = 2; //2行 //地址字段特殊处理
        else
            cell.customDetailTextLabel.numberOfLines = 0; //不限制行数
        
        cell.customDetailTextLabel.lineBreakMode = NSLineBreakByWordWrapping; //设置自动换行模式
        
        //点击编辑功能
        if ([self canEditGroupInfo]) {
            if (self.accessories2[@(indexPath.row)]) {
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = [self.accessories2[@(indexPath.row)] intValue];
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
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
    return [CellUtility tableView:tableView functionCellForRowAtIndexPath:indexPath identifier:ButtonCell3 functions:self.functions buttonBlock:^(UIButton *button, NSString* function) {
        if ([function isEqualToString:INFORMATION_FUNCTION_SHOW_TALK]) {
            [button setTitle:@"发送消息" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(showTalk) forControlEvents:UIControlEventTouchUpInside];
        } else if([function isEqualToString:INFORMATION_FUNCTION_INVITE_MEMBER]) {
            [button setTitle:[NSString stringWithFormat:@"%@", self.groupInfo.entCode?@"添加员工":@"邀请成员"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(inviteMember) forControlEvents:UIControlEventTouchUpInside];
        } else if([function isEqualToString:INFORMATION_FUNCTION_EXIT_GROUP]) {
            [button setTitle:[NSString stringWithFormat:@"退出%@", [GroupInformationViewController nameWithGroupType:self.groupInfo.type]] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(exitGroup) forControlEvents:UIControlEventTouchUpInside];
        } else if([function isEqualToString:INFORMATION_FUNCTION_DELETE_GROUP]) {
            [button setTitle:[NSString stringWithFormat:@"解散%@", [GroupInformationViewController nameWithGroupType:self.groupInfo.type]] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(deleteGroup) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

//显示聊天界面
- (void)showTalk
{
//    //退出当前页面
//    [self.navigationController popViewControllerAnimated:YES];
    
    //发送显示聊天界面通知
    [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_SHOW_TALK object:self userInfo:@{@"informationType":@"GROUP" ,@"depCode":@(self.groupInfo.depCode)}];
    
//    if ([self.delegate respondsToSelector:@selector(groupInformationViewController:needExitParentController:)])
//        [self.delegate groupInformationViewController:self needExitParentController:YES];
}

//邀请成员
- (void)inviteMember
{
    MemberSeletedViewController* msvc = [_contactStoryobard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_MEMBER_SELECTED_CONTROLLER];
    msvc.delegate = self;
    msvc.targetGroupInfo = self.groupInfo;
    [self.navigationController pushViewController:msvc animated:YES];
}

#define EB_CHAT_INFORMATION_EXIT_GROUP_TAG 111
#define EB_CHAT_INFORMATION_DELETE_GROUP_TAG 112

//退出部门/群组
- (void)exitGroup
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"真的要退出这个%@吗?", self.groupInfo.entCode?@"部门":@"群组"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alertView setTag:EB_CHAT_INFORMATION_EXIT_GROUP_TAG];
    [alertView show];
}

//解散部门/群组
- (void)deleteGroup
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"真的要解散这个%@吗?", self.groupInfo.entCode?@"部门":@"群组"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alertView setTag:EB_CHAT_INFORMATION_DELETE_GROUP_TAG];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.tag == EB_CHAT_INFORMATION_EXIT_GROUP_TAG) { //退出部门/群组
            [[NSNotificationCenter defaultCenter] postNotificationName:EB_CHAT_NOTIFICATION_EXIT_GROUP object:self userInfo:@{@"depCode":@(self.groupInfo.depCode), @"empCode":@(self.groupInfo.myEmpCode)}];
        } else if (alertView.tag == EB_CHAT_INFORMATION_DELETE_GROUP_TAG) { //解散部门/群组
            [[NSNotificationCenter defaultCenter] postNotificationName:EB_CHAT_NOTIFICATION_DELETE_GROUP object:self userInfo:@{@"depCode":@(self.groupInfo.depCode)}];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
//        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark -  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 90;
    } else if (indexPath.section==1) {
        return 36;
    } else if (indexPath.section==2){
        if (indexPath.row==(self.groupInfo.entCode>0?2:1))
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

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; //取消选中本行
    
    UIViewController* pvc;
    if ([self canEditGroupInfo]) {
        if (indexPath.section==0) { //编辑名称
            CaptionEditViewController* vc = [_otherStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_CAPTION_EDIT_CONTROLLER];
            vc.customName = self.groupInfo.depName;
            vc.customDescription = self.groupInfo.descri;
            vc.delegate = self;
            
            pvc = vc;
        } else if (indexPath.section==1) {
            if (!self.accessories1[@(indexPath.row)] || [self.accessories1[@(indexPath.row)] intValue]==UITableViewCellAccessoryNone)
                return;
            
            if (indexPath.section==1 && indexPath.row==0) { //始终允许进入查看"成员人数"
                MemberListViewController* vc = [_settingStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_MEMBER_LIST_CONTROLLER];
                vc.groupInfo = self.groupInfo;
                pvc = vc;
            } else {
                CommonTextInputViewController* vc = [[ControllerManagement sharedInstance] fetchCommonTextInputControllerWithNavigationTitle:[NSString stringWithFormat:@"编辑%@", self.names1[indexPath.row]] defaultText:self.contents1[indexPath.row] textInputViewHeight:0.f delegate:self];
                vc.customTag1 = indexPath.row;
                vc.customTag2 = indexPath.section;
                vc.returnKeyType = UIReturnKeyDone;
                if (self.keyboardTypes1[@(indexPath.row)])
                    vc.keyboardType = [self.keyboardTypes1[@(indexPath.row)] intValue];
                pvc = vc;
            }
        } else if (indexPath.section==2) {
            if (!self.accessories2[@(indexPath.row)] || [self.accessories2[@(indexPath.row)] intValue]==UITableViewCellAccessoryNone)
                return;
            
            CommonTextInputViewController* vc = [[ControllerManagement sharedInstance] fetchCommonTextInputControllerWithNavigationTitle:[NSString stringWithFormat:@"编辑%@", self.names2[indexPath.row]] defaultText:self.contents2[indexPath.row] textInputViewHeight:0.f delegate:self];
            vc.customTag1 = indexPath.row;
            vc.customTag2 = indexPath.section;
            vc.returnKeyType = UIReturnKeyDone;
            if (self.keyboardTypes2[@(indexPath.row)])
                vc.keyboardType = [self.keyboardTypes2[@(indexPath.row)] intValue];
            
            pvc = vc;
        }
    } else if (indexPath.section==1 && indexPath.row==0) { //始终允许进入查看"成员人数"
        MemberListViewController* vc = [_settingStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_MEMBER_LIST_CONTROLLER];
        vc.groupInfo = self.groupInfo;
        pvc = vc;
    }
    
    if(pvc)
        [self.navigationController pushViewController:pvc animated:YES];
}

#pragma mark - CommonTextInputViewControllerDelgate

- (void)commonTextInputViewController:(CommonTextInputViewController *)commonTextInputViewController wantToSaveInputText:(NSString *)text
{
    NSString* newValue = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (newValue) {
        EBGroupInfo* groupInfo = [[EBGroupInfo alloc] init];
        groupInfo.depCode = self.groupInfo.depCode;
        groupInfo.type = self.groupInfo.type;
        
        if (commonTextInputViewController.customTag2==1) {
            //@"人数", @"电话", @"传真", @"邮箱"
            switch (commonTextInputViewController.customTag1) {
                case 1:
                    groupInfo.phone = newValue;
                    break;
                case 2:
                    groupInfo.fax = newValue;
                    break;
                case 3:
                    groupInfo.email = newValue;
                    break;
                default:
                    break;
            }
        } else  if (commonTextInputViewController.customTag2==2) {
            //@"公司", @"主页", @"地址"
            switch (commonTextInputViewController.customTag1) {
                case 0:
                {
                    if (!self.enterpriseInfo)
                        groupInfo.url = newValue;
                }
                    break;
                case 1:
                {
                    if (self.enterpriseInfo)
                        groupInfo.url = newValue;
                    else
                        groupInfo.address = newValue;
                }
                    break;
                case 2:
                {
                    if (self.enterpriseInfo)
                        groupInfo.address = newValue;
                }
                    break;
                default:
                    break;
            }
        } else {
            groupInfo.depName = text;
        }

        
        __weak typeof(self) safeSelf = self;
        [[ENTBoostKit sharedToolKit] editGroup:groupInfo onCompletion:^(EBGroupInfo* newGroupInfo){
            [BlockUtility performBlockInMainQueue:^{
                //更新当前视图
                safeSelf.groupInfo = newGroupInfo;
                [safeSelf fillContent];
                [safeSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:commonTextInputViewController.customTag1 inSection:commonTextInputViewController.customTag2]] withRowAnimation:UITableViewRowAnimationNone];
                
                //触发事件
                if ([self.delegate respondsToSelector:@selector(groupInformationViewController:updateGroup:dataObject:)]) {
                    [self.delegate groupInformationViewController:safeSelf updateGroup:newGroupInfo dataObject:safeSelf.dataObject];
                }
            }];
        } onFailure:^(NSError *error) {
            NSLog(@"修改部门或群组名称失败，code=%@, msg = %@", @(error.code), error.localizedDescription);
        }];
    }
}

#pragma mark - CaptionEditViewControllerDelegate

- (void)captionEditViewController:(CaptionEditViewController*)captionEditViewController wantToSaveInputName:(NSString*)name inputDescription:(NSString*)description
{
    NSString* newName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* newDescription = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!newName) newName = @"";
    if (!newDescription) newDescription = @"";
    
    EBGroupInfo* groupInfo = [[EBGroupInfo alloc] init];
    groupInfo.depCode = self.groupInfo.depCode;
    groupInfo.type = self.groupInfo.type;
    groupInfo.depName = newName;
    groupInfo.descri = newDescription;
    
    __weak typeof(self) safeSelf = self;
    [[ENTBoostKit sharedToolKit] editGroup:groupInfo onCompletion:^(EBGroupInfo* newGroupInfo){
        [BlockUtility performBlockInMainQueue:^{
            //更新当前视图
            safeSelf.groupInfo = newGroupInfo;
            [safeSelf fillContent];
            [safeSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
            //触发事件
            if ([self.delegate respondsToSelector:@selector(groupInformationViewController:updateGroup:dataObject:)]) {
                [self.delegate groupInformationViewController:safeSelf updateGroup:newGroupInfo dataObject:safeSelf.dataObject];
            }
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"修改部门或群组名称失败，code=%@, msg = %@", @(error.code), error.localizedDescription);
    }];
}

#pragma mark - MemberSeletedViewControllerDelegate

- (void)memberSeletedViewController:(MemberSeletedViewController *)viewController saveInvitedMember:(EBMemberInfo *)memberInfo
{
    EBGroupInfo* groupInfo = [[ENTBoostKit sharedToolKit] groupInfoWithDepCode:self.groupInfo.depCode];
    if (groupInfo) {
        self.groupInfo = groupInfo;
        [self prepareData];
        [self.tableView reloadData];
    }
}

@end
