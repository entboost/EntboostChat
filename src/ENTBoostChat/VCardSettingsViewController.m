//
//  VCardSettingsViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/12/21.
//  Copyright © 2015年 EB. All rights reserved.
//

#import "VCardSettingsViewController.h"
#import "InformationCell1.h"
#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "ButtonKit.h"
#import "BlockUtility.h"
#import "ControllerManagement.h"
#import "UserInformationViewController.h"
#import "FVCustomAlertView.h"
#import <objc/runtime.h>

@interface  VCardGroupInfo: NSObject

@property(nonatomic) uint64_t empCode;  //成员编号
@property(nonatomic, strong) NSString* name; //名称
@property(nonatomic) BOOL isEntGroup;   //是否部门(项目组)
@property(nonatomic, strong) EBGroupInfo* groupInfo;    //群组(部门)资料
@property(nonatomic, strong) EBMemberInfo* memberInfo;  //成员资料

- (id)initWithMemberInfo:(EBMemberInfo*)memberInfo groupInfo:(EBGroupInfo*)groupInfo;

@end

@implementation VCardGroupInfo

- (id)initWithMemberInfo:(EBMemberInfo*)memberInfo groupInfo:(EBGroupInfo*)groupInfo
{
    if (self=[super init]) {
        self.empCode = memberInfo.empCode;
        self.isEntGroup = groupInfo.isEntGroup;
        self.memberInfo = memberInfo;
        self.groupInfo = groupInfo;
        self.name = [NSString stringWithFormat:@"%@-%@[%@]", self.memberInfo.userName, self.groupInfo.depName, self.isEntGroup?@"部门":@"群组"];
    }
    return self;
}

@end


@interface VCardSettingsViewController () <UserInformationViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray* myGroups; //我所属的部门和群组列表

@end

@implementation VCardSettingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)]; //导航栏左边按钮1
    
    [self loadMyGroups:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

//返回上一级
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//排序当前用户所属部门和群组列表
- (void)sortMyGroups
{
    //按先部门后群组排序
    NSSortDescriptor* sortDescriptorIsEntGroup = [[NSSortDescriptor alloc] initWithKey:@"_isEntGroup" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber * n1 = obj1;
        NSNumber * n2 = obj2;
        return [n1 compare:n2];
    }];
    
    //按名称排序
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000); //中文字符编码；注意gb2312字符集，ASCII字符排在中文字符前面；gbk则相反
    NSSortDescriptor* sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
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
    [self.myGroups sortUsingDescriptors:@[sortDescriptorIsEntGroup, sortDescriptorName]];
}

//加载当前用户所属部门和群组列表
- (void)loadMyGroups:(BOOL)reload
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    __weak typeof(self) safeSelf = self;
    
    ShowAlertView();
    
    [BlockUtility performBlockInGlobalQueue:^{
        //加载所属部门列表
        [ebKit loadMyEntGroupInfosOnCompletion:^(NSDictionary *groupInfos) {
            NSMutableDictionary* myGroupInfos = [[NSMutableDictionary alloc] init];
            NSMutableArray* empCodes = [[NSMutableArray alloc] init];
            
            for (id key in groupInfos) {
                EBGroupInfo* groupInfo = groupInfos[key];
                //如果当前用户存在于该部门
                if (groupInfo.myEmpCode) {
                    myGroupInfos[@(groupInfo.depCode)] = groupInfo;
                    [empCodes addObject:@(groupInfo.myEmpCode)];
                }
            }
            
            //加载所属个人群组列表
            [ebKit loadPersonalGroupInfosOnCompletion:^(NSDictionary *groupInfos) {
                for (id key in groupInfos) {
                    EBGroupInfo* groupInfo = groupInfos[key];
                    //如果当前用户存在于该部门
                    if (groupInfo.myEmpCode) {
                        myGroupInfos[@(groupInfo.depCode)] = groupInfo;
                        [empCodes addObject:@(groupInfo.myEmpCode)];
                    }
                }
                
                //加载相关成员资料
                [ebKit loadMemberInfosWithEmpCodes:empCodes onCompletion:^(NSDictionary *memberInfos) {
                    [BlockUtility performBlockInMainQueue:^{
                        safeSelf.myGroups = [[NSMutableArray alloc] initWithCapacity:memberInfos.count];
                        for (EBMemberInfo* memberInfo in [memberInfos allValues]) {
                            VCardGroupInfo* vGroupInfo = [[VCardGroupInfo alloc] initWithMemberInfo:memberInfo groupInfo:myGroupInfos[@(memberInfo.depCode)]];
                            [safeSelf.myGroups addObject:vGroupInfo];
                            
                            //排序
                            [safeSelf sortMyGroups];
                            //更新界面
                            if (reload)
                                [safeSelf.tableView reloadData];
                        }
                    }];
                    
                    CloseAlertView();
                } onFailure:^(NSError *error) {
                    NSLog(@"loadMemberInfo error, code = %@, msg = %@", @(error.code), error.localizedDescription);
                    CloseAlertView();
                }];
            } onFailure:^(NSError *error) {
                NSLog(@"loadPersonalGroupInfos error, code = %@, msg = %@", @(error.code), error.localizedDescription);
                CloseAlertView();
            }];
            
        } onFailure:^(NSError *error) {
            NSLog(@"loadMyEntGroupInfos error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            CloseAlertView();
        }];
    }];
}

#pragma mark - UserInformationViewControllerDelegate
- (void)userInformationViewController:(UserInformationViewController *)userInformationViewController needUpdateParentController:(BOOL)needUpdate
{
    if (needUpdate)
        [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.myGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InformationCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"InformationCell_1" forIndexPath:indexPath];
    
    //设置标题
    VCardGroupInfo* vGroupInfo = self.myGroups[indexPath.row];
    cell.customTextLabel.text = vGroupInfo.name;
    
    //清除残余视图内容
    UIView* boxView = [cell viewWithTag:101];
    for (UIView* tickView in boxView.subviews) {
        [tickView removeFromSuperview];
    }
    //清除旧手势事件
    if (cell.customTapRecognizer) {
        [boxView removeGestureRecognizer:cell.customTapRecognizer];
        cell.customTapRecognizer = nil;
    }
    
    //判断是否默认电子名片
    EBAccountInfo* accountInfo = [ENTBoostKit sharedToolKit].accountInfo;
    if (accountInfo.defaultEmpCode==vGroupInfo.empCode) {
        UIImageView* tickView = [[UIImageView alloc] initWithFrame:(CGRect){0, 0, 30, 30}];
        tickView.image = [UIImage imageNamed:@"tick"];
        [boxView addSubview:tickView];
    } else {
        //添加点击事件
        cell.customTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTickViewTap:)];
        [boxView addGestureRecognizer:cell.customTapRecognizer];
        //关联数据
        objc_setAssociatedObject(cell.customTapRecognizer , @"indexPath", indexPath, OBJC_ASSOCIATION_RETAIN);
    }
    
    return cell;
}

//处理点击打钩图标手势
- (void)didTickViewTap:(id)sender
{
    NSIndexPath* indexPath = objc_getAssociatedObject(sender, @"indexPath"); //取出关联数据
    VCardGroupInfo* vGroupInfo = self.myGroups[indexPath.row];
    
    ShowAlertView();
    __weak typeof(self) weakSelf = self;
    [[ENTBoostKit sharedToolKit] editUserDefaultEmp:vGroupInfo.empCode onCompletion:^{
        [BlockUtility performBlockInMainQueue:^{
            typeof(self) safeSelf = weakSelf;
            //刷新视图
           [safeSelf.tableView reloadData];
            //回调上层
            if ([safeSelf.delegate respondsToSelector:@selector(vCardSettingsViewController:updateDefaultEmp:dataObject:)])
                [safeSelf.delegate vCardSettingsViewController:safeSelf updateDefaultEmp:vGroupInfo.empCode  dataObject:nil];
        }];
        CloseAlertView();
    } onFailure:^(NSError *error) {
        NSLog(@"editUserDefaultEmp error, code = %@, msg = %@", @(error.code), error.localizedDescription);
        CloseAlertView();
    }];
}

#define HEIGHT_FOR_HEADER_FOOTER 20.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return HEIGHT_FOR_HEADER_FOOTER;
//}
//
//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, HEIGHT_FOR_HEADER_FOOTER)];
//    [view setBackgroundColor:[UIColor clearColor]];
//    
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return HEIGHT_FOR_HEADER_FOOTER;
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
    
    VCardGroupInfo* vGroupInfo = self.myGroups[indexPath.row];
    EBMemberInfo* memberInfo = vGroupInfo.memberInfo;
    
    __weak typeof(self) safeSelf = self;
    [[ControllerManagement sharedInstance] fetchUserControllerWithUid:memberInfo.uid orAccount:memberInfo.empAccount checkVCard:NO onCompletion:^(UserInformationViewController *uvc) {
        uvc.targetMemberInfo = memberInfo;
        uvc.targetGroupInfo = vGroupInfo.groupInfo;
        uvc.myMemberInfo = memberInfo;
        uvc.delegate = safeSelf;
        uvc.isReadonly = YES;
//        uvc.dataObject = node;
        
        [self.navigationController pushViewController:uvc animated:YES];
    } onFailure:nil];
}

@end
