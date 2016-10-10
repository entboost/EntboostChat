//
//  ContactInformationViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/22.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "ContactInformationViewController.h"
#import "ENTBoostChat.h"
#import "ENTBoost.h"
#import "BlockUtility.h"
#import "ENTBoost+Utility.h"
#import "InformationCell1.h"
#import "CustomSeparator.h"
#import "FVCustomAlertView.h"
#import "RelationshipHelper.h"
#import "ContactGroupViewController.h"
#import "ButtonKit.h"
#import "ResourceKit.h"
#import "CellUtility.h"
#import "CommonTextInputViewController.h"
#import "CaptionEditViewController.h"
#import "ControllerManagement.h"

@interface ContactInformationViewController () <CommonTextInputViewControllerDelgate>
{
    UIStoryboard* _contactStoryobard;
}

@property(strong, nonatomic) NSArray* names1; //各项字段名
@property(strong, nonatomic) NSArray* contents1; //各项内容
@property(strong, nonatomic) NSArray* names2; //各项字段名
@property(strong, nonatomic) NSArray* contents2; //各项内容

@property(strong, nonatomic) NSDictionary* keyboardTypes1; //编辑属性使用的键盘类型
@property(strong, nonatomic) NSDictionary* keyboardTypes2; //编辑属性使用的键盘类型
@property(strong, nonatomic) NSDictionary* accessories1; //附加功能
@property(strong, nonatomic) NSDictionary* accessories2; //附加功能
@property(strong, nonatomic) NSMutableArray* functions; //操作功能

@end

@implementation ContactInformationViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super initWithCoder:aDecoder]) {
        _contactStoryobard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_CONTACT bundle:nil];
        self.functions = [[NSMutableArray alloc] init];
        
        //注册接收通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContact:) name:EB_CHAT_NOTIFICATION_RELOAD_CONTACT object:nil]; //重新载入联系人
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //标题
    self.navigationItem.title = [NSString stringWithFormat:@"%@资料", [ENTBoostKit sharedToolKit].isContactNeedVerification?@"好友":@"联系人"];
    
    //导航栏左边按钮1
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    
    //行名称
    self.names1 = @[@"分组", @"手机", @"电话", @"邮箱"];
    //附加属性定义
    self.accessories1 = @{@0:@(UITableViewCellAccessoryDisclosureIndicator), @1:@(UITableViewCellAccessoryDisclosureIndicator), @2:@(UITableViewCellAccessoryDisclosureIndicator), @3:@(UITableViewCellAccessoryDisclosureIndicator)}; //第n行xxx操作，未定义的默认none操作
    //编辑属性使用的键盘类型，未定义的默认UIKeyboardTypeDefault类型
    self.keyboardTypes1 = @{@1:@(UIKeyboardTypePhonePad), @2:@(UIKeyboardTypePhonePad), @3:@(UIKeyboardTypeEmailAddress)};
    
    self.names2 = @[@"公司", @"职务"];
    self.accessories2 = @{@0:@(UITableViewCellAccessoryDisclosureIndicator), @1:@(UITableViewCellAccessoryDisclosureIndicator)};
    self.keyboardTypes2 = @{};
    
    //填充数据
    [self prepareData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //移除接收通知的注册
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EB_CHAT_NOTIFICATION_RELOAD_CONTACT object:nil]; //重新载入联系人
}

//重新载入联系人信息
- (void)reloadContact:(NSNotification*)notif
{
    __weak typeof(self) safeSelf = self;
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    [ebKit loadContactInfoWithId:self.contactInfo.contactId onCompletion:^(EBContactInfo *contactInfo) {
        [ebKit loadContactGroupWithId:contactInfo.groupId onCompletion:^(EBContactGroup *contactGroup) {
            [BlockUtility performBlockInMainQueue:^{
                safeSelf.contactInfo = contactInfo;
                safeSelf.contactGroup = contactGroup;
                [safeSelf prepareData];
                [safeSelf.tableView reloadData];
            }];
        } onFailure:^(NSError *error) {
            NSLog(@"重新加载联系人分组失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"重新加载联系人信息失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
    }];
}

//准备数据
- (void)prepareData
{
    EBContactInfo* contactInfo = self.contactInfo;
    uint64_t myUid = [ENTBoostKit sharedToolKit].accountInfo.uid;
    
    [self fillContent];
    
    //操作功能定义
    [self.functions removeAllObjects];
    if (contactInfo.uid!=myUid && (contactInfo.account.length>0 || contactInfo.uid>0)) //不能给自己发送消息
        [self.functions addObject:INFORMATION_FUNCTION_SHOW_TALK];
    
    [self.functions addObject:INFORMATION_FUNCTION_DELETE_CONTACT]; //删除联系人操作
    
    if ([ENTBoostKit sharedToolKit].isContactNeedVerification && !contactInfo.verified && contactInfo.uid!=myUid) //服务端为好友验证模式、不是自己、未验证才显示验证按钮
        [self.functions addObject:INFORMATION_FUNCTION_VERIFY_CONTACT];
}

- (void)fillContent
{
    EBContactInfo* contactInfo = self.contactInfo;
    //行内容1
    self.contents1 = @[REALVALUE(self.contactGroup.groupName), REALVALUE(contactInfo.phone), REALVALUE(contactInfo.tel), REALVALUE(contactInfo.email)];
    //行内容2
    self.contents2 = @[REALVALUE(contactInfo.company), REALVALUE(contactInfo.jobTitle)];
}

//返回上一级
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//好友验证
- (void)verifyContact
{
    //    [[NSNotificationCenter defaultCenter] postNotificationName:EB_CHAT_NOTIFICATION_ADD_CONTACT object:self userInfo:@{@"type":@"verify", @"uid":@(self.contactInfo.uid), @"account":self.contactInfo.account}];
    [RelationshipHelper manageContact:@{@"type":@"verify", @"uid":@(self.contactInfo.uid), @"account":self.contactInfo.account}];
    
//    [self goBack];
}

- (void)showTalk
{
//    //退出当前页面
//    [self.navigationController popViewControllerAnimated:NO];
    
    //发送显示聊天界面通知
    [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_SHOW_TALK object:self userInfo:@{@"informationType":@"USER" ,@"otherUid":@(self.contactInfo.uid), @"otherAccount":@"", @"otherUserName":REALVALUE(self.contactInfo.name)}];
    
//    if ([self.delegate respondsToSelector:@selector(contactInformationViewController:needExitParentController:)])
//        [self.delegate contactInformationViewController:self needExitParentController:YES];
}

- (void)deleteContact
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"删除%@", [ENTBoostKit sharedToolKit].isContactNeedVerification?@"好友":@"联系人"] message:@"真的要删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //退出当前页面
        [self goBack];
        
        //发送删除联系人的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:EB_CHAT_NOTIFICATION_DELETE_CONTACT object:self userInfo:@{@"contactId":@(self.contactInfo.contactId)}];
    }
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else if (section == 1)
        return self.contents1.count;
    else if (section == 2)
        return self.contents2.count;
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
    InformationCell1 *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        cell.customTextLabel.text = self.contactInfo.name;
        cell.customDetailTextLabel.text = [NSString stringWithFormat:@"账号 : %@", REALVALUE(self.contactInfo.account)];
        cell.customDetailTextLabel2.text = self.contactInfo.uid?[NSString stringWithFormat:@"编号 : %llu", self.contactInfo.uid]:nil;
        cell.customDetailTextLabel2.font = cell.customDetailTextLabel.font;
        
        //显示头像图片
        [ResourceKit showUserHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
        //设置圆角边框
        EBCHAT_UI_SET_CORNER_VIEW(cell.customImageView, 1.0f, [UIColor clearColor]);
        
        if (indexPath.row==0)
            cell.hiddenCustomSeparatorTop = NO; //显示顶部分割线
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:RightDetailInformationCell1 forIndexPath:indexPath];
        cell.customTextLabel.text = self.names1[indexPath.row];
        cell.customDetailTextLabel.text = self.contents1[indexPath.row];
        
        if (self.accessories1[@(indexPath.row)]) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = [self.accessories1[@(indexPath.row)] intValue];
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if (indexPath.row==0)
            cell.hiddenCustomSeparatorTop = NO; //显示顶部分割线
    } else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:LeftDetailInformationCell2 forIndexPath:indexPath];
        cell.customTextLabel.text = self.names2[indexPath.row];
        cell.customDetailTextLabel.text = self.contents2[indexPath.row];
        
//        cell.customDetailTextLabel.numberOfLines = 0; //不限制行数
//        cell.customDetailTextLabel.lineBreakMode = NSLineBreakByWordWrapping; //设置自动换行模式
//        //改变宽度约束
//        NSArray* constraints = [cell.customDetailTextLabel constraints];
//        for (NSLayoutConstraint* constraint in constraints) {
//            if (constraint.firstAttribute == NSLayoutAttributeWidth && constraint.firstItem == cell.customDetailTextLabel) {
//                CGFloat marginX = 20.0;
//                CGFloat sepparatorX = 10.0;
//                CGFloat width = cell.contentView.bounds.size.width - marginX - sepparatorX - cell.customTextLabel.bounds.size.width;
//                constraint.constant = width;
//                break;
//            }
//        }
        if (self.accessories2[@(indexPath.row)]) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = [self.accessories2[@(indexPath.row)] intValue];
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if (indexPath.row==0)
            cell.hiddenCustomSeparatorTop = NO; //显示顶部分割线
    } else if (indexPath.section == 3){
        cell = [self tableView:tableView functionCellForRowAtIndexPath:indexPath];
    }
    
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
            [button addTarget:self action:@selector(showTalk) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"发送消息" forState:UIControlStateNormal];
        } else if ([function isEqualToString:INFORMATION_FUNCTION_DELETE_CONTACT]) {
            [button setTitle:ebKit.isContactNeedVerification?@"删除好友":@"删除联系人" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(deleteContact) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button setTitle:@"好友验证" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(verifyContact) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

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
    
    UIViewController* pvc;
    
    if (indexPath.section==0) { //编辑名称和备注
        CommonTextInputViewController* vc = [[ControllerManagement sharedInstance] fetchCommonTextInputControllerWithNavigationTitle:@"编辑名称" defaultText:self.contactInfo.name textInputViewHeight:0.f delegate:self];
        vc.customTag1 = indexPath.row;
        vc.customTag2 = indexPath.section;
        vc.returnKeyType = UIReturnKeyDone;
        
        pvc = vc;
    } else if (indexPath.section==1) {
        if (!self.accessories1[@(indexPath.row)] || [self.accessories1[@(indexPath.row)] intValue]==UITableViewCellAccessoryNone)
            return;
        
        if ([self.names1[indexPath.row] isEqualToString:@"分组"]) { //编辑分组
            ContactGroupViewController* vc = [_contactStoryobard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_CONTACT_GROUP_CONTROLLER];
            
            vc.selectedContactGroupId = self.contactGroup.groupId;
            vc.contactInfo = self.contactInfo;
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
    
    if(pvc)
        [self.navigationController pushViewController:pvc animated:YES];
}

#pragma mark - CommonTextInputViewControllerDelgate

- (void)commonTextInputViewController:(CommonTextInputViewController *)commonTextInputViewController wantToSaveInputText:(NSString *)text
{
    NSString* newValue = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!newValue) newValue = @"";

    EBContactInfo* contactInfo = [[EBContactInfo alloc] init];
    contactInfo.contactId = self.contactInfo.contactId;
    contactInfo.groupId = self.contactInfo.groupId;
    
    if (commonTextInputViewController.customTag2==1) {
        //@"分组", @"手机", @"电话", @"邮箱"
        switch (commonTextInputViewController.customTag1) {
            case 1:
                contactInfo.phone = newValue;
                break;
            case 2:
                contactInfo.tel = newValue;
                break;
            case 3:
                contactInfo.email = newValue;
                break;
            default:
                break;
        }
    } else  if (commonTextInputViewController.customTag2==2) {
        //@"公司", @"职务"
        switch (commonTextInputViewController.customTag1) {
            case 0:
                contactInfo.company = newValue;
                break;
            case 1:
                contactInfo.jobTitle = newValue;
                break;
            default:
                break;
        }
    } else {
        contactInfo.name = newValue;
    }
    
    __weak typeof(self) safeSelf = self;
    [[ENTBoostKit sharedToolKit] editContactInfo:contactInfo onCompletion:^(EBContactInfo *newContactInfo) {
        [BlockUtility performBlockInMainQueue:^{
            //更新当前视图
            safeSelf.contactInfo = newContactInfo;
            [safeSelf fillContent];
            [safeSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:commonTextInputViewController.customTag1 inSection:commonTextInputViewController.customTag2]] withRowAnimation:UITableViewRowAnimationNone];
            
            //触发事件
            if ([safeSelf.delegate respondsToSelector:@selector(contactInformationViewController:updateContactInfo:dataObject:)]) {
                [safeSelf.delegate contactInformationViewController:safeSelf updateContactInfo:newContactInfo dataObject:safeSelf.dataObject];
            }
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"修改联系人资料失败，code=%@, msg = %@", @(error.code), error.localizedDescription);
    }];
}

@end
