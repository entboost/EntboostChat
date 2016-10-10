//
//  MyInformationViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/6.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "MyInformationViewController.h"
#import "ENTBoostChat.h"
#import "ENTBoost.h"
#import "BlockUtility.h"
#import "ENTBoost+Utility.h"
#import "ResourceKit.h"
#import "InformationCell1.h"
#import "CustomSeparator.h"
#import "ButtonKit.h"
#import "ResourceKit.h"
#import "ControllerManagement.h"
#import "CommonTextInputViewController.h"
#import "HeadPhotoSettingViewController.h"
#import "AreaPickerKit.h"
#import <objc/runtime.h>

@interface MyInformationViewController () <CommonTextInputViewControllerDelgate, UIActionSheetDelegate, AreaPickerDelegate, HeadPhotoSettingViewControllerDelegate>
{
    UIStoryboard* _settingStoryboard;
}

@property (nonatomic, strong) AreaPickerKit *areaPickerKit; //地区选择器
@property (nonatomic, strong) NSDateFormatter* dateFormatter; //时间格式化工具

@property(strong, nonatomic) EBAccountInfo* accountInfo; //当前用户资料缓存

@property(strong, nonatomic) NSArray* names1; //各项字段名
@property(strong, nonatomic) NSArray* names2; //各项字段名
@property(strong, nonatomic) NSArray* names3; //各项字段名
@property(strong, nonatomic) NSArray* contents1; //各项内容
@property(strong, nonatomic) NSArray* contents2; //各项内容
@property(strong, nonatomic) NSArray* contents3; //各项内容

@property(strong, nonatomic) NSDictionary* keyboardTypes1; //编辑属性使用的键盘类型
@property(strong, nonatomic) NSDictionary* keyboardTypes2; //编辑属性使用的键盘类型
@property(strong, nonatomic) NSDictionary* keyboardTypes3; //编辑属性使用的键盘类型
@property(strong, nonatomic) NSDictionary* accessories1; //附加功能
@property(strong, nonatomic) NSDictionary* accessories2; //附加功能
@property(strong, nonatomic) NSDictionary* accessories3; //附加功能

@end

@implementation MyInformationViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self =[super initWithCoder:aDecoder]) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        _settingStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_SETTING bundle:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的信息";
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    
    self.accountInfo = [ENTBoostKit sharedToolKit].accountInfo;
    
    //行名称
    self.names1 = @[@"头像", @"名称", @"账号", @"编号", @"类型", @"个性签名"];
    //附加属性定义
    self.accessories1 = @{@0:@(UITableViewCellAccessoryDisclosureIndicator),@1:@(UITableViewCellAccessoryDisclosureIndicator), @5:@(UITableViewCellAccessoryDisclosureIndicator)}; //第n行xxx操作，未定义的默认none操作
    //编辑属性使用的键盘类型，未定义的默认UIKeyboardTypeDefault类型
    self.keyboardTypes1 = @{};
    
    self.names2 = @[@"主页", @"性别", @"生日"];
    self.accessories2 = @{@0:@(UITableViewCellAccessoryDisclosureIndicator), @2:@(UITableViewCellAccessoryDisclosureIndicator)};
    self.keyboardTypes2 = @{@1:@(UIKeyboardTypeURL)};
    
    self.names3 = @[@"地区", @"邮编", @"电话", @"手机", @"邮件", @"地址"];
    self.accessories3 = @{@0:@(UITableViewCellAccessoryDisclosureIndicator), @1:@(UITableViewCellAccessoryDisclosureIndicator), @2:@(UITableViewCellAccessoryDisclosureIndicator), @3:@(UITableViewCellAccessoryDisclosureIndicator), @4:@(UITableViewCellAccessoryDisclosureIndicator), @5:@(UITableViewCellAccessoryDisclosureIndicator)};
    self.keyboardTypes3 = @{@1:@(UIKeyboardTypeNumberPad), @2:@(UIKeyboardTypePhonePad), @3:@(UIKeyboardTypePhonePad), @4:@(UIKeyboardTypeEmailAddress)};
    
    //填充数据
    [self fillContentWithAccountInfo:self.accountInfo];
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

- (void)fillContentWithAccountInfo:(EBAccountInfo*)accountInfo
{
    //生日
    NSString* birthday = @"";
    if (accountInfo.birthday) {
        birthday = [self.dateFormatter stringFromDate:accountInfo.birthday];
    }
//    //性别
//    NSString* gender = @"";
//    if (accountInfo.gender==EB_GENDER_FEMALE)
//        gender = @"女";
//    else if (accountInfo.gender==EB_GENDER_MALE)
//        gender = @"男";
    //地区
    NSString* area = [NSString stringWithFormat:@"%@ %@ %@ %@", REALVALUE(accountInfo.area.strField0), REALVALUE(accountInfo.area.strField1), REALVALUE(accountInfo.area.strField2), REALVALUE(accountInfo.area.strField3)];
    
    //行内容1
    self.contents1 = @[@"", REALVALUE(accountInfo.userName), REALVALUE(accountInfo.account), [NSString stringWithFormat:@"%llu", accountInfo.uid], accountInfo.isVisitor?@"游客":@"注册用户", REALVALUE(accountInfo.descri)];
    //行内容2
    self.contents2 = @[REALVALUE(accountInfo.url), @(accountInfo.gender), birthday];
    //行内容3
    self.contents3 = @[area, REALVALUE(accountInfo.zipcode), REALVALUE(accountInfo.tel), REALVALUE(accountInfo.mobile), REALVALUE(accountInfo.email), REALVALUE(accountInfo.address)];
}

//显示地区选择器
- (void)showAreaPickerWithIndexPath:(NSIndexPath*)indexPath
{
    //占位字符
    NSString* title = @"\n\n\n\n\n\n\n\n\n\n\n";
    //创建日期选择器
//    if (!self.areaPickerKit) {
    self.areaPickerKit = [[AreaPickerKit alloc] initWithArea:self.accountInfo.area?[self.accountInfo.area copy]:nil delegate:self];
    self.areaPickerKit.tag = 302;
//    }
    UIPickerView* pickerView = self.areaPickerKit.pickerView;
    
//    //设置初始值
//    if (self.accountInfo.area)
//        self.areaPickerKit.selectedArea = [self.accountInfo.area copy];
    
    if (IOS8) { //IOS8以上，包括IOS8
        UIAlertController* alertVc=[UIAlertController alertControllerWithTitle:title message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
        [alertVc.view addSubview:pickerView];
//        NSLog(@"pickerView1:%@", NSStringFromCGRect(pickerView.frame));
        pickerView.frame = CGRectMake(0, 0, alertVc.view.bounds.size.width, pickerView.bounds.size.height);
//        NSLog(@"pickerView2:%@", NSStringFromCGRect(pickerView.frame));
        
//        self.areaPickerKit.pickerView.frame = CGRectMake(0, 0, alertVc.view.bounds.size.width, alertVc.view.bounds.size.height-110);
//        self.areaPickerKit.pickerView.center = alertVc.view.center;
        
        //"确定"动作
        [alertVc addAction:[UIAlertAction actionWithTitle:@"确认" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            EBArea* area = self.areaPickerKit.selectedArea;
            [self saveArea:area forIndexPath:indexPath];
        }]];
        //"取消"动作
        [alertVc addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:nil]];
        //弹出界面
        [self presentViewController:alertVc animated:YES completion:nil];
    } else { //IOS7以下，包括IOS7
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
        actionSheet.tag = 402;
        actionSheet.userInteractionEnabled = YES;
        [actionSheet addSubview:pickerView];
        [actionSheet showInView:self.view];
//        areaPickerView.frame = CGRectMake(0, 0, actionSheet.bounds.size.width-50, actionSheet.bounds.size.height-110);
        //        actionSheet.bounds = CGRectMake(0, 0, 320, 516);
        
        //关联数据
        objc_setAssociatedObject(actionSheet, @"indexPath", indexPath, OBJC_ASSOCIATION_RETAIN);
    }
}

// 显示生日选择器
- (void)showBirthdayPickerWithIndexPath:(NSIndexPath*)indexPath
{
    //占位字符
    NSString* title = @"\n\n\n\n\n\n\n\n\n\n\n";
    //创建日期选择器
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.tag = 301;
    datePicker.datePickerMode = UIDatePickerModeDate;
    //设置初始值
    if (self.accountInfo.birthday)
        datePicker.date = self.accountInfo.birthday;
    
    if (IOS8) { //IOS8以上，包括IOS8
        UIAlertController* alertVc=[UIAlertController alertControllerWithTitle:title message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
        [alertVc.view addSubview:datePicker];
        
        //"确定"动作
        [alertVc addAction:[UIAlertAction actionWithTitle:@"确认" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            NSString *dateString = [self.dateFormatter stringFromDate:datePicker.date];
            [self saveBirthdayWithDateString:dateString forIndexPath:indexPath];
        }]];
        //"取消"动作
        [alertVc addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:nil]];
        //弹出界面
        [self presentViewController:alertVc animated:YES completion:nil];
    } else { //IOS7以下，包括IOS7
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
        actionSheet.tag = 401;
        actionSheet.userInteractionEnabled = YES;
        [actionSheet addSubview:datePicker];
        [actionSheet showInView:self.view];
        //        actionSheet.bounds = CGRectMake(0, 0, 320, 516);
        
        //关联数据
        objc_setAssociatedObject(actionSheet, @"indexPath", indexPath, OBJC_ASSOCIATION_RETAIN);
    }
}

//保存地区
- (void)saveArea:(EBArea*)area forIndexPath:(NSIndexPath*)indexPath
{
    EBAccountInfo* newAccountInfo = [[EBAccountInfo alloc] init];
    newAccountInfo.uid = [ENTBoostKit sharedToolKit].accountInfo.uid;
    newAccountInfo.area = area;
    
    [self saveAccount:newAccountInfo ForIndexPath:indexPath];
}

//保存生日
- (void)saveBirthdayWithDateString:(NSString*)dateString forIndexPath:(NSIndexPath*)indexPath
{
    EBAccountInfo* newAccountInfo = [[EBAccountInfo alloc] init];
    newAccountInfo.uid = [ENTBoostKit sharedToolKit].accountInfo.uid;
    newAccountInfo.birthday = [self.dateFormatter dateFromString:dateString];
    
    [self saveAccount:newAccountInfo ForIndexPath:indexPath];
}

//执行保存当前用户资料
- (void)saveAccount:(EBAccountInfo*)newAccountInfo ForIndexPath:(NSIndexPath*)indexPath
{
    __weak typeof(self) safeSelf = self;
    [[ENTBoostKit sharedToolKit] editUserInfoWithAccountInfo:newAccountInfo onCompletion:^{
        [BlockUtility performBlockInMainQueue:^{
            //更新当前视图
            safeSelf.accountInfo = [ENTBoostKit sharedToolKit].accountInfo;
            [safeSelf fillContentWithAccountInfo:safeSelf.accountInfo];
            [safeSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            //触发事件
            if ([safeSelf.delegate respondsToSelector:@selector(myInformationViewController:updateAccountInfo:dataObject:)]) {
                [safeSelf.delegate myInformationViewController:safeSelf updateAccountInfo:safeSelf.accountInfo dataObject:safeSelf.dataObject];
            }
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"修改当前用户资料失败，code=%@, msg = %@", @(error.code), error.localizedDescription);
        [BlockUtility performBlockInMainQueue:^{
            [safeSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }];
}

//性别选择事件处理
-(void)segmentAction:(UISegmentedControl*)segCtrl
{
    if (segCtrl.tag==301) { //保存生日
        NSIndexPath* indexPath = objc_getAssociatedObject(segCtrl, @"indexPath"); //取出关联数据
        EBAccountInfo* newAccountInfo = [[EBAccountInfo alloc] init];
        newAccountInfo.uid = [ENTBoostKit sharedToolKit].accountInfo.uid;
        newAccountInfo.gender = (EB_GENDER_TYPE)(segCtrl.selectedSegmentIndex+1);
        [self saveAccount:newAccountInfo ForIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return self.names1.count;
    else if (section == 1)
        return self.names2.count;
    else
        return self.names3.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"MyInformationCell_1";
    static NSString *CellIdentifier2 = @"MyInformationCell_2";
    static NSString *CellIdentifier3 = @"MyInformationCell_3";
    static NSString *CellIdentifier4 = @"MyInformationCell_4";
    static NSString *CellIdentifier5 = @"MyInformationCell_5";
    
    InformationCell1 *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
            cell.customTextLabel.text = @"头像";
            
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
                    [BlockUtility performBlockInMainQueue:^{
//                        [safeSelf showHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
                        [ResourceKit showUserHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
                    }];
                }];
            } else {
//                [self showHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
                [ResourceKit showUserHeadPhotoWithFilePath:nil inImageView:cell.customImageView];
            }
            
            //设置圆角边框
            EBCHAT_UI_SET_CORNER_VIEW(cell.customImageView, 1.0f, [UIColor clearColor]);
        } else if (indexPath.row == 5) { //个性签名
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4 forIndexPath:indexPath];
            
            cell.customDetailTextLabel.numberOfLines = 0; //不限制行数
            cell.customDetailTextLabel.lineBreakMode = NSLineBreakByWordWrapping; //设置自动换行模式
            //改变宽度约束
            NSArray* constraints = [cell.customDetailTextLabel constraints];
            for (NSLayoutConstraint* constraint in constraints) {
                if (constraint.firstAttribute == NSLayoutAttributeWidth && constraint.firstItem == cell.customDetailTextLabel) {
                    CGFloat marginX = 20.0 + (cell.contentView.bounds.size.width>320?50:30);
                    CGFloat sepparatorX = 10.0;
                    CGFloat width = cell.contentView.bounds.size.width - marginX - sepparatorX - cell.customTextLabel.bounds.size.width;
                    constraint.constant = width;
                    break;
                }
            }
            
            cell.customTextLabel.text = self.names1[indexPath.row];
            cell.customDetailTextLabel.text = self.contents1[indexPath.row];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
            cell.customTextLabel.text = self.names1[indexPath.row];
            cell.customDetailTextLabel.text = self.contents1[indexPath.row];
        }
        
        if (self.accessories1[@(indexPath.row)]) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = [self.accessories1[@(indexPath.row)] intValue];
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 1) { //性别
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3 forIndexPath:indexPath];
            cell.customTextLabel.text = self.names2[indexPath.row];
            //分段宽度
            [cell.customSegmentedCtrl setWidth:60.0 forSegmentAtIndex:0];
            [cell.customSegmentedCtrl setWidth:60.0 forSegmentAtIndex:1];
            //分段颜色
            [cell.customSegmentedCtrl setTintColor:[UIColor colorWithHexString:@"#60B1CE"]];
            //选中
            EB_GENDER_TYPE gender = [self.contents2[indexPath.row] intValue];
            if (gender>0)
                cell.customSegmentedCtrl.selectedSegmentIndex = gender-1;
            else
                cell.customSegmentedCtrl.selectedSegmentIndex = -1;
            //点选改变事件
            [cell.customSegmentedCtrl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
            //关联数据
            objc_setAssociatedObject(cell.customSegmentedCtrl , @"indexPath", indexPath, OBJC_ASSOCIATION_RETAIN);
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
            cell.customTextLabel.text = self.names2[indexPath.row];
            cell.customDetailTextLabel.text = self.contents2[indexPath.row];
            
            if (self.accessories2[@(indexPath.row)]) {
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = [self.accessories2[@(indexPath.row)] intValue];
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row==0 || indexPath.row==5) { //地区、地址
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4 forIndexPath:indexPath];
            
            cell.customDetailTextLabel.numberOfLines = 0; //不限制行数
            cell.customDetailTextLabel.lineBreakMode = NSLineBreakByWordWrapping; //设置自动换行模式
            //改变宽度约束
            NSArray* constraints = [cell.customDetailTextLabel constraints];
            for (NSLayoutConstraint* constraint in constraints) {
                if (constraint.firstAttribute == NSLayoutAttributeWidth && constraint.firstItem == cell.customDetailTextLabel) {
                    CGFloat marginX = 30.0;
                    CGFloat sepparatorX = 10.0;
                    CGFloat width = cell.contentView.bounds.size.width - marginX - sepparatorX - cell.customTextLabel.bounds.size.width;
                    constraint.constant = width;
                    break;
                }
            }
        } else { //其它
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier5 forIndexPath:indexPath];
        }
        
        cell.customTextLabel.text = self.names3[indexPath.row];
        cell.customDetailTextLabel.text = self.contents3[indexPath.row];
        
        if (self.accessories3[@(indexPath.row)]) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = [self.accessories3[@(indexPath.row)] intValue];
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    //显示顶部分割线
    if (indexPath.row==0)
        cell.hiddenCustomSeparatorTop = NO;
    
    //IOS6以下设置背景色
    if (!IOS7) {
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        backgrdView.backgroundColor = EBCHAT_DEFAULT_BACKGROUND_COLOR;
        cell.backgroundView = backgrdView;
    }
    
    return cell;
}

#pragma mark -  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0 && indexPath.row==0) {
        return 100;
    } else if (indexPath.section==2 && (indexPath.row==0 || indexPath.row==5)) {
        return 60;
    } else if (indexPath.section==0 && indexPath.row==5) {
        return 60;
    } else {
        return 44;
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
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; //取消选中本行
    
    UIViewController* pvc;
    UINavigationController* navigationController = self.navigationController;
    
    if (indexPath.section==0) {
        if (!self.accessories1[@(indexPath.row)] || [self.accessories1[@(indexPath.row)] intValue]==UITableViewCellAccessoryNone)
            return;
        
        if(indexPath.row ==0) {
            HeadPhotoSettingViewController* vc = [_settingStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_HEAD_PHOTO_SETTING_CONTROLLER];
            vc.delegate = self;
            pvc = vc;
            
            //查询获取成员资料对象
            ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
            if (ebKit.havingDefaultHeadPhoto) {
                uint64_t empCode = ebKit.accountInfo.defaultEmpCode;
                [ebKit loadMemberInfoWithEmpCode:empCode onCompletion:^(EBMemberInfo *memberInfo) {
                    [BlockUtility performBlockInMainQueue:^{
                        vc.memberInfo = memberInfo;
                        [navigationController pushViewController:pvc animated:YES];
                    }];
                } onFailure:^(NSError *error) {
                    NSLog(@"loadMemberInfoWithEmpCode error, empCode = %llu, code = %@, msg = %@", empCode, @(error.code), error.localizedDescription);
                    [BlockUtility performBlockInMainQueue:^{
                        [navigationController pushViewController:pvc animated:YES];
                    }];
                }];
                
                return;
            }
        } else {
            CommonTextInputViewController* vc = [[ControllerManagement sharedInstance] fetchCommonTextInputControllerWithNavigationTitle:[NSString stringWithFormat:@"编辑%@", self.names1[indexPath.row]] defaultText:self.contents1[indexPath.row] textInputViewHeight:0.f delegate:self];
            vc.customTag1 = indexPath.row;
            vc.customTag2 = indexPath.section;
            vc.returnKeyType = UIReturnKeyDone;
            
            if (self.keyboardTypes1[@(indexPath.row)])
                vc.keyboardType = [self.keyboardTypes1[@(indexPath.row)] intValue];
            
            pvc = vc;
        }
    } else if (indexPath.section==1) {
        if (!self.accessories2[@(indexPath.row)] || [self.accessories2[@(indexPath.row)] intValue]==UITableViewCellAccessoryNone)
            return;
        
        if (indexPath.row==2) { //生日
            [self showBirthdayPickerWithIndexPath:indexPath];
        } else {
            CommonTextInputViewController* vc = [[ControllerManagement sharedInstance] fetchCommonTextInputControllerWithNavigationTitle:[NSString stringWithFormat:@"编辑%@", self.names2[indexPath.row]] defaultText:self.contents2[indexPath.row] textInputViewHeight:0.f delegate:self];
            vc.customTag1 = indexPath.row;
            vc.customTag2 = indexPath.section;
            vc.returnKeyType = UIReturnKeyDone;
            if (self.keyboardTypes2[@(indexPath.row)])
                vc.keyboardType = [self.keyboardTypes2[@(indexPath.row)] intValue];
            pvc = vc;
        }
    } else if (indexPath.section==2) {
        if (!self.accessories3[@(indexPath.row)] || [self.accessories3[@(indexPath.row)] intValue]==UITableViewCellAccessoryNone)
            return;
        
        if (indexPath.row==0) { //地区
            [self showAreaPickerWithIndexPath:indexPath];
        } else {
            CommonTextInputViewController* vc = [[ControllerManagement sharedInstance] fetchCommonTextInputControllerWithNavigationTitle:[NSString stringWithFormat:@"编辑%@", self.names3[indexPath.row]] defaultText:self.contents3[indexPath.row] textInputViewHeight:0.f delegate:self];
            vc.customTag1 = indexPath.row;
            vc.customTag2 = indexPath.section;
            vc.returnKeyType = UIReturnKeyDone;
            if (self.keyboardTypes3[@(indexPath.row)])
                vc.keyboardType = [self.keyboardTypes3[@(indexPath.row)] intValue];
            
            pvc = vc;
        }
    }
    
    if(pvc)
        [navigationController pushViewController:pvc animated:YES];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSIndexPath* indexPath = objc_getAssociatedObject(actionSheet, @"indexPath"); //取出关联数据
        
        if (actionSheet.tag==401) { //选择生日
            UIDatePicker* datePicker = (UIDatePicker*)[actionSheet viewWithTag:301];
            NSString *dateString = [self.dateFormatter stringFromDate:datePicker.date];
            [self saveBirthdayWithDateString:dateString forIndexPath:indexPath];
        } else if (actionSheet.tag==402) { //选择地区
//            AreaPickerKit* pickerKit = (AreaPickerKit*)[actionSheet viewWithTag:302];
            EBArea* area =  self.areaPickerKit.selectedArea;
            [self saveArea:area forIndexPath:indexPath];
        }
    }
}

#pragma mark - CommonTextInputViewControllerDelgate

- (void)commonTextInputViewController:(CommonTextInputViewController *)commonTextInputViewController wantToSaveInputText:(NSString *)text
{
    NSString* newValue = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!newValue) newValue = @"";
    
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    EBAccountInfo* newAccountInfo = [[EBAccountInfo alloc] init];
    newAccountInfo.uid = ebKit.accountInfo.uid;
    
    if (commonTextInputViewController.customTag2==0) {
        //@"头像", @"名称", @"账号", @"编号", @"类型", @"个性签名"
        switch (commonTextInputViewController.customTag1) {
            case 1:
                newAccountInfo.userName = newValue;
                break;
            case 5:
                newAccountInfo.descri = newValue;
                break;
            default:
                break;
        }
    } else if (commonTextInputViewController.customTag2==1) {
        //@"主页", @"性别", @"生日"
        switch (commonTextInputViewController.customTag1) {
            case 0:
                newAccountInfo.url = newValue;
                break;
            case 1:
                break;
            case 2:
                
                break;
            default:
                break;
        }
    } else if (commonTextInputViewController.customTag2==2) {
        //@"地区", @"邮编", @"电话", @"手机", @"邮件", @"地址"
        switch (commonTextInputViewController.customTag1) {
            case 1:
                newAccountInfo.zipcode = newValue;
                break;
            case 2:
                newAccountInfo.tel = newValue;
                break;
            case 3:
                newAccountInfo.mobile = newValue;
                break;
            case 4:
                newAccountInfo.email = newValue;
                break;
            case 5:
                newAccountInfo.address = newValue;
                break;
            default:
                break;
        }
    }

    [self saveAccount:newAccountInfo ForIndexPath:[NSIndexPath indexPathForRow:commonTextInputViewController.customTag1 inSection:commonTextInputViewController.customTag2]];
}

#pragma mark - AreaPickerDelegate

- (NSArray*)areaPickerData:(AreaPickerKit *)pickerKit parentAreaId:(uint64_t)parentAreaId
{
    //按名称排序
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES comparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
        return [obj1 compare:obj2];
    }];
    
    __block NSMutableArray* results;
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [[ENTBoostKit sharedToolKit] loadAreaDictionaryWithParentId:parentAreaId onCompletion:^(NSDictionary *areas) {
        if (areas) {
            results = [[NSMutableArray alloc] init];
            [results addObject:[[EBAreaField alloc] init]]; //最前面插入一个默认对象
            [results addObjectsFromArray:[[areas allValues] sortedArrayUsingDescriptors:@[sortDescriptor]]];
        }
        dispatch_semaphore_signal(sem);
    } onFailure:^(NSError *error) {
        dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 20.0f * NSEC_PER_SEC));
    
    return results;
}

#pragma mark - HeadPhotoSettingViewControllerDelegate

- (void)headPhotoSettingViewController:(HeadPhotoSettingViewController *)viewController updateHeadPhoto:(uint64_t)resId dataObject:(id)dataObject
{
    //重载头像
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    //回调上层
    if ([self.delegate respondsToSelector:@selector(myInformationViewController:updateAccountInfo:dataObject:)])
        [self.delegate myInformationViewController:self updateAccountInfo:[ENTBoostKit sharedToolKit].accountInfo dataObject:self.dataObject];
}

@end
