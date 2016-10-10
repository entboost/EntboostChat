//
//  ContactGroupViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/30.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "ContactGroupViewController.h"
#import "ContactGroupCell.h"
#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "BlockUtility.h"
#import "ButtonKit.h"
#import "ENTBoost+Utility.h"
#import "ContactInformationViewController.h"
#import <objc/runtime.h>

@interface ContactGroupViewController ()
{
    uint64_t _currentGroupId; //当前正在编辑的分组编号
}

@property(nonatomic, strong) UITapGestureRecognizer* tapGesRecognizer; //点击名称手势事件

@property(nonatomic, strong) NSMutableArray* contactGroups; //联系人分组

@end

@implementation ContactGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"分组";
    
    //导航栏左边按钮1
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    //加载分组信息列表
    [self loadGroupDatas];
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

//加载分组信息列表
- (void)loadGroupDatas
{
    __weak typeof(self) safeSelf = self;
    [[ENTBoostKit sharedToolKit] loadContactGroupsOnCompletion:^(NSDictionary *contactGroups) {
        //排序
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000); //中文字符编码；注意gb2312字符集，ASCII字符排在中文字符前面；gbk则相反
        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"_groupName" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
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
        NSArray* sortedContactGroups = [[contactGroups allValues] sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        //更新视图
        [BlockUtility performBlockInMainQueue:^{
            safeSelf.contactGroups = [sortedContactGroups mutableCopy];
            [safeSelf.contactGroups addObject:[[EBContactGroup alloc] initWithId:0 groupName:@"未分组"]]; //默认分组
            
            [safeSelf.tableView reloadData];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"loadContactGroups error, code = %@, msg = %@", @(error.code), error.localizedDescription);
    }];
    
    [self postContactInfoNotification];
}

//发送更新联系人信息视图通知
- (void)postContactInfoNotification
{
    //发送更新联系人视图的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:EB_CHAT_NOTIFICATION_RELOAD_CONTACT object:self userInfo:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else if (section == 1)
        return self.contactGroups.count;
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ContactGroupCell1 = @"contactGroupCell_1";
    static NSString *ContactGroupCell2 = @"contactGroupCell_2";
    
    ContactGroupCell* cell;
    if (indexPath.section==0) {
        cell = (ContactGroupCell*)[tableView dequeueReusableCellWithIdentifier:ContactGroupCell1 forIndexPath:indexPath];
        cell.customLabel.text = @"添加新分组";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.hiddenCustomSeparatorTop = NO; //显示顶分隔线
    } else if (indexPath.section==1) {
        cell = (ContactGroupCell*)[tableView dequeueReusableCellWithIdentifier:ContactGroupCell2 forIndexPath:indexPath];
        
        EBContactGroup* contactGroup = self.contactGroups[indexPath.row];
        cell.customLabel.text = contactGroup.groupName;
        
        //编辑分组名称的功能
        if (self.tapGesRecognizer)
            [cell.customLabel removeGestureRecognizer:self.tapGesRecognizer];
        self.tapGesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editGroup:)];
        [cell.customLabel addGestureRecognizer:self.tapGesRecognizer];
        //关联数据
        objc_setAssociatedObject(self.tapGesRecognizer , @"groupId", @(contactGroup.groupId), OBJC_ASSOCIATION_RETAIN);
        
//        cell.propertyButton.tag = indexPath.row;
//        if (contactGroup.groupId)
//            [cell.propertyButton addTarget:self action:@selector(editGroup:) forControlEvents:UIControlEventTouchUpInside];
        
        //勾选按钮
        cell.tickButton.tag = indexPath.row;
        [cell.tickButton addTarget:self action:@selector(tickClicked:) forControlEvents:UIControlEventTouchUpInside];
        //设置是否选中状态
        if (contactGroup.groupId==self.selectedContactGroupId)
            [cell.tickButton setImage:[UIImage imageNamed:@"tick"] forState:UIControlStateNormal];
        else
            [cell.tickButton setImage:nil forState:UIControlStateNormal];
        
        if (indexPath.row==0)
            cell.hiddenCustomSeparatorTop = NO; //显示顶分隔线
    }
    
//    //IOS6以下设置背景色
//    if (!IOS7) {
//        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
//        backgrdView.backgroundColor = [UIColor colorWithHexString:@"#EFFAFE"];
//        cell.backgroundView = backgrdView;
//    }
    
    return cell;
}

#define EB_CONTACT_GROUP_ADD_TAG 101
#define EB_CONTACT_GROUP_EDIT_TAG 102

//编辑分组属性
- (void)editGroup:(UITapGestureRecognizer*)recognizer
{
    uint64_t groupId = [objc_getAssociatedObject(recognizer, @"groupId") unsignedLongLongValue]; //取出关联数据
    EBContactGroup* contactGroup;
    for (EBContactGroup* tmpContactGroup in self.contactGroups) {
        if (tmpContactGroup.groupId==groupId)
            contactGroup = tmpContactGroup;
    }

    if (contactGroup) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入分组名称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"修改", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = EB_CONTACT_GROUP_EDIT_TAG;
        _currentGroupId = contactGroup.groupId;

        UITextField* textField = [alert textFieldAtIndex:0];
        textField.text = contactGroup.groupName;

        [alert show];
    }
}

//勾选按钮事件
- (void)tickClicked:(UIButton*)sender
{
    //暂时禁用按钮
    sender.enabled = NO;
    
    EBContactGroup* contactGroup = ((EBContactGroup*)self.contactGroups[sender.tag]);
    
    //更新联系人所属分组
    if (contactGroup.groupId == self.selectedContactGroupId) {
        NSLog(@"当前已经选中，忽略");
        sender.enabled = YES; //启用按钮
        return;
    }
    
    __weak typeof(self) safeSelf = self;
    [[ENTBoostKit sharedToolKit] changeContactGroupWithContactId:self.contactInfo.contactId orContactUid:0 groupId:contactGroup.groupId onCompletion:^(EBContactInfo *contactInfo) {
        [BlockUtility performBlockInMainQueue:^{
            safeSelf.contactInfo = contactInfo;
            safeSelf.selectedContactGroupId = contactGroup.groupId;
            
//            //刷新当前行
//            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:1];
//            [safeSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //刷新视图
            [safeSelf.tableView reloadData];
            //发送更新联系人视图的通知
            [safeSelf postContactInfoNotification];
            sender.enabled = YES; //启用按钮
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"修改联系人所属分组失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
        [BlockUtility performBlockInMainQueue:^{
            sender.enabled = YES; //启用按钮
        }];
    }];
}

#pragma - mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
        return 44;
    else
        return 60;
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
    if (section == 1)
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
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section==0) { //添加新分组
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入分组名称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"添加", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = EB_CONTACT_GROUP_ADD_TAG;
        [alert show];
    }
}

//输入分组名称确认处理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //确定添加新分组
    if (buttonIndex==1) {
        UITextField* textField = [alertView textFieldAtIndex:0];
        NSString* groupName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (groupName.length>0) {
            __weak typeof(self) safeSelf = self;
            if (alertView.tag==EB_CONTACT_GROUP_ADD_TAG) {
                [[ENTBoostKit sharedToolKit] createContactGroupWithGroupName:groupName onCompletion:^(uint64_t groupId) {
                    //重新加载分组信息列表
                    [safeSelf loadGroupDatas];
                } onFailure:^(NSError *error) {
                    NSLog(@"创建联系人分组:'%@' 失败， code = %@, msg = %@", groupName, @(error.code), error.localizedDescription);
                }];
            } else if (alertView.tag==EB_CONTACT_GROUP_EDIT_TAG) {
                [[ENTBoostKit sharedToolKit] editContactGroupWithId:_currentGroupId groupName:groupName onCompletion:^ {
                    //重新加载分组信息列表
                    [safeSelf loadGroupDatas];
                } onFailure:^(NSError *error) {
                    NSLog(@"编辑联系人分组:'%@' 失败， code = %@, msg = %@", groupName, @(error.code), error.localizedDescription);
                }];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EBContactGroup* contactGroup = [self.contactGroups objectAtIndex:indexPath.row];
        __weak typeof(self) safeSelf = self;
        [[ENTBoostKit sharedToolKit] deleteContactGroupWithId:contactGroup.groupId onCompletion:^{
            //重新加载分组信息列表
            [safeSelf loadGroupDatas];
        } onFailure:^(NSError *error) {
            NSLog(@"删除分组失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

@end
