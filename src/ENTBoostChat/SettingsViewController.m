//
//  SettingsViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-10-15.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "LogonViewController.h"
#import "MyInformationViewController.h"
#import "VCardSettingsViewController.h"
#import "SecritySettingsViewController.h"
#import "SettingsCell.h"
#import "CustomSeparator.h"
#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "ENTBoost+Utility.h"
#import "BlockUtility.h"
#import "ResourceKit.h"

@interface SettingsViewController () <MyInformationViewControllerDelegate, VCardSettingsViewControllerDelegate>
{
//    MyInformationViewController* _myInformationViewController;
    UIStoryboard* _settingStoryboard;
}

@property(nonatomic, strong) NSArray* settingConfigs;

@end

@implementation SettingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _settingStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_SETTING bundle:nil];
        self.settingConfigs = @[
//                                @{@"title":@"消息提醒通知", @"image":@"setting_notification", @"controller_id":@"SettingNotificationController_id"},
                                @{@"title":@"电子名片", @"image":@"setting_notification", @"controller_id":EBCHAT_STORYBOARD_ID_SECRITY_SETTINGS_CONTROLLER},
                                @{@"title":@"隐私与安全", @"image":@"setting_security", @"controller_id":EBCHAT_STORYBOARD_ID_SECRITY_SETTINGS_CONTROLLER},
                                @{@"title":@"聊天对话", @"image":@"setting_talk", @"controller_id":EBCHAT_STORYBOARD_ID_TALK_SETTING_CONTROLLER}
                                ];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
//    //设置分割线
//    if (IOS7)
//        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
//    [self.tableView setSeparatorColor:[UIColor colorWithHexString:@"#c1dce5"]];
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 2)
        return 1;
    if (section == 1)
        return 3;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"SettingCell1";
    static NSString *CellIdentifier2 = @"SettingCell2";
    SettingsCell *cell;
    
    if (indexPath.section == 0)
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
    
//    if (IOS7)
//        [cell setBackgroundColor:[UIColor colorWithHexString:@"#EFFAFE"]];
//    else {
//        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
//        backgrdView.backgroundColor = [UIColor colorWithHexString:@"#EFFAFE"];
//        cell.backgroundView = backgrdView;
//    }
    
    if (indexPath.row==0)
        cell.hiddenCustomSeparatorTop = NO; //显示顶部分割线
    
    switch (indexPath.section) {
        case 0:
        {
            //显示头像图片
            ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
            if (ebKit.havingDefaultHeadPhoto) {
//                __weak typeof(self) safeSelf = self;
                [ebKit loadMyDefaultHeadPhotoOnCompletion:^(NSString *filePath) {
                    [BlockUtility performBlockInMainQueue:^{ //在主线程中执行
//                        [safeSelf showHeadPhotoWithFilePath:filePath inImageView:cell.customImageView];
                        [ResourceKit showUserHeadPhotoWithFilePath:filePath inImageView:cell.customImageView];
                    }];
                } onFailure:^(NSError *error) {
                    NSLog(@"load my default headphoto error, code = %@, msg = %@", @(error.code), error.localizedDescription);
                    [BlockUtility performBlockInMainQueue:^{ //在主线程中执行
//                        [safeSelf showHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
                        [ResourceKit showUserHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
                    }];
                }];
            } else {
//                [self showHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
                [ResourceKit showUserHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
            }
            //设置头像图片圆角边框
            EBCHAT_UI_SET_CORNER_VIEW(cell.customImageView, 5.0f, [UIColor clearColor]);
            //显示标题
            cell.customTextLabel.text = ebKit.accountInfo.isVisitor?@"游客":ebKit.accountInfo.userName;
            cell.customDetailTextLabel.text = ebKit.accountInfo.descri; //@"fjkjfiksdjikdfjsakjdksj f 房价肯定是减\n肥快圣诞节kg fksdfkjdskfjkdsjfkhf f8984384834837疯狂的时间飞cmcmmxskfdskfs开发街道上空房间的开始交罚款多少积分开始点击付款的时间是";
            cell.customDetailTextLabel.numberOfLines = 0; //多行
            cell.customDetailTextLabel.lineBreakMode = NSLineBreakByCharWrapping; //设置自动换行模式
            
            //改变宽度约束
            NSArray* constraints = [cell.customDetailTextLabel constraints];
            for (NSLayoutConstraint* constraint in constraints) {
                if (constraint.firstAttribute == NSLayoutAttributeWidth && constraint.firstItem == cell.customDetailTextLabel) {
                    CGFloat marginX = 20.0+30.0;
                    CGFloat sepparatorX = 10.0;
                    CGFloat width = cell.contentView.bounds.size.width - marginX - sepparatorX - cell.customImageView.bounds.size.width;
                    constraint.constant = width;
                    break;
                }
            }
//            //计算尺寸
//            UIFont* font = cell.customDetailTextLabel.font;
//            NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//            paragraphStyle.lineBreakMode = cell.customDetailTextLabel.lineBreakMode;
//            NSDictionary* attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
//            
//            CGSize textSize = [cell.customDetailTextLabel.text sizeWithAttributes:attributes];
//            if (!IOS7)
//                textSize = [cell.customDetailTextLabel.text sizeWithFont:font];
//            //变更尺寸
//            CGRect rect = cell.customDetailTextLabel.frame;
//            rect.size.width = textSize.width;
//            rect.size.height = textSize.height;
//            cell.customDetailTextLabel.frame = rect;
            
            //附加属性
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 1:
        {
            NSDictionary* settingConfig = self.settingConfigs[indexPath.row];
            cell.customImageView.image = [UIImage imageNamed:settingConfig[@"image"]];
            cell.customTextLabel.text = settingConfig[@"title"];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 2:
        {
            cell.customImageView.image = [UIImage imageNamed:@"setting_logoff"];
            cell.customTextLabel.text = @"注销登录";
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma - mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return 60.0f;
    else
        return 44.0f;
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
    if (section == 2)
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
    [tableView deselectRowAtIndexPath:indexPath animated:NO]; //取消选中
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
//                if (!_myInformationViewController)
                MyInformationViewController* myInformationViewController = [_settingStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_MY_INFORMATION_CONTROLLER];
                myInformationViewController.delegate = self;
//                _myInformationViewController.dataObject = indexPath;
                [self.navigationController pushViewController:myInformationViewController animated:YES];
            }
        }
            break;
        case 1:
        {
            //SecritySettingsViewController
            UIViewController* vc;
            if (indexPath.row==0) //电子名片设置
                vc = [_settingStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_VCARD_SETTINGS_CONTROLLER];
            else if (indexPath.row==1) //安全设置
                vc = [_settingStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_SECRITY_SETTINGS_CONTROLLER];
            else if (indexPath.row==2) //聊天设置
                vc = [_settingStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_TALK_SETTING_CONTROLLER];
            
            if (vc)
                [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            if (indexPath.row == 0) { //注销登录
                NSString* message = @"真得要注销吗？";
                if ([[[ENTBoostKit sharedToolKit] accountInfo] isVisitor])
                    message = [NSString stringWithFormat:@"注销动作将会清空当前用户的聊天记录，%@", message];
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"注销" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
            }
        }
            break;
        default:
            break;
    }
}

//注销登录提示处理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_MANUAL_LOGOFF object:self userInfo:nil];
    }
}

#pragma mark - MyInformationViewControllerDelegate
- (void)myInformationViewController:(MyInformationViewController *)viewController updateAccountInfo:(EBAccountInfo *)accountInfo dataObject:(id)dataObject
{
    //刷新第一行内容(头像、名称等)
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - VCardSettingsViewControllerDelegate
- (void)vCardSettingsViewController:(VCardSettingsViewController *)viewController updateDefaultEmp:(uint64_t)defaultEmp dataObject:(id)dataObject
{
    //刷新第一行内容(头像、名称等)
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

@end
