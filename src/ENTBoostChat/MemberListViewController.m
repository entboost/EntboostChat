//
//  MemberListViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 16/1/17.
//  Copyright © 2016年 EB. All rights reserved.
//

#import "MemberListViewController.h"
#import "UserInformationViewController.h"
#import "InformationCell1.h"
#import "ENTBoostChat.h"
#import "ENTBoost.h"
#import "ButtonKit.h"
#import "ResourceKit.h"
#import "BlockUtility.h"
#import "ENTBoost+Utility.h"
#import "ControllerManagement.h"
#import <objc/runtime.h>

@interface MemberListViewController ()

@property(nonatomic, strong) NSArray* memberInfos; //成员列表
@property(nonatomic, strong) NSMutableDictionary* headPhotoLoadedCache;

@end

@implementation MemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"所有成员";
    
    //导航栏左边按钮1
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    
    self.headPhotoLoadedCache = [[NSMutableDictionary alloc] init];
    
    __weak typeof(self) safeSelf = self;
    [[ENTBoostKit sharedToolKit] loadMemberInfosWithDepCode:self.groupInfo.depCode onCompletion:^(NSDictionary *memberInfos) {
        //按名称排序
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000); //中文字符编码；注意gb2312字符集，ASCII字符排在中文字符前面；gbk则相反
        NSSortDescriptor* sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"_userName" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
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
        NSArray* sortedMemberInfos = [[memberInfos allValues] sortedArrayUsingDescriptors:@[sortDescriptorName]];
        [BlockUtility performBlockInMainQueue:^{
            safeSelf.memberInfos = sortedMemberInfos;
            [safeSelf.tableView reloadData];
        }];
    } onFailure:^(NSError *error) {
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

//返回上一级
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.memberInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *InformationCell1Identifier = @"informationCell1";
    InformationCell1 *cell = [tableView dequeueReusableCellWithIdentifier:InformationCell1Identifier forIndexPath:indexPath];
    
    EBMemberInfo* memberInfo = self.memberInfos[indexPath.row];
    
    cell.customTextLabel.text = memberInfo.userName;
    cell.customDetailTextLabel.text = [NSString stringWithFormat:@"账号:%@", memberInfo.empAccount];
    cell.customDetailTextLabel2.text = [NSString stringWithFormat:@"编号:%@", @(memberInfo.uid)];
    
    //设置头像图片圆角边框
    EBCHAT_UI_SET_CORNER_VIEW_CLEAR(cell.customImageView);
    
    //设置头像图片
    static UIImage* defaultOnlineHeadPhoto; //默认在线头像图标
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        defaultOnlineHeadPhoto = [UIImage imageNamed:[ResourceKit defaultImageNameOfUser]];
    });
    
    //显示默认头像的代码模块
    void(^showDefaultHeadPhoto)(void) = ^ {
        [BlockUtility performBlockInMainQueue:^{
            cell.customImageView.image = defaultOnlineHeadPhoto;
        }];
    };
    
//    //清除旧的手势事件
//    if (cell.customTapRecognizer) {
//        [cell.customImageView removeGestureRecognizer:cell.customTapRecognizer];
//    }
    
    __weak typeof(self) safeSelf = self;
    
    //定义图片文件加载失败后的处理模块
    void(^loadedFailureBlock)(uint64_t uid) = ^(uint64_t uid) {
        [BlockUtility performBlockInMainQueue:^{
            safeSelf.headPhotoLoadedCache[@(uid)] = @NO;
            showDefaultHeadPhoto();
        }];
    };
    
    //定义图片文件加载完毕后的处理模块
    void(^loadedSuccessBlock)(uint64_t uid, NSString* filePath, BOOL isOffline) = ^(uint64_t uid, NSString* filePath, BOOL isOffline) {
        if (filePath) {
            [BlockUtility performBlockInMainQueue:^{
                UIImage* image = [[UIImage alloc] initWithContentsOfFile:filePath];
                safeSelf.headPhotoLoadedCache[@(uid)] = image;
                cell.customImageView.image = image;
            }];
        } else {
            loadedFailureBlock(uid);
        }
    };
    
    //智能显示头像的处理模块
    void(^showPhotoBlock)(id headPhoto) = ^(id headPhoto) {
        if ([headPhoto isMemberOfClass:[UIImage class]])
            cell.customImageView.image = headPhoto;
        else
            showDefaultHeadPhoto();
    };

//    //添加点击头像的手势事件
//    cell.customTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headPhotoTap:)];
//    [cell.customImageView addGestureRecognizer:cell.customTapRecognizer];
//    objc_setAssociatedObject(cell.customTapRecognizer , @"uid", @(memberInfo.uid), OBJC_ASSOCIATION_RETAIN); //关联数据
    
    __block id headPhoto = self.headPhotoLoadedCache[@(memberInfo.uid)];
    if (headPhoto!=nil) {
        showPhotoBlock(headPhoto);
    } else {
        [[ENTBoostKit sharedToolKit] loadHeadPhotoWithMemberInfo:memberInfo onCompletion:^(NSString *filePath) {
            loadedSuccessBlock(memberInfo.uid, filePath, YES);
        } onFailure:^(NSError *error) {
            loadedFailureBlock(memberInfo.uid);
        }];
    }
    
    return cell;
}

#define HEIGHT_FOR_HEADER_FOOTER 20.0f

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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EBMemberInfo* memberInfo = self.memberInfos[indexPath.row];
    [self showUserInformationWithMemberInfo:memberInfo];
}

//显示成员资料界面
- (void)showUserInformationWithMemberInfo:(EBMemberInfo*)memberInfo
{
    uint64_t myUid = [ENTBoostKit sharedToolKit].accountInfo.uid;
    
    EBMemberInfo* myMemberInfo;
    for (EBMemberInfo* tmpMemberInfo in self.memberInfos) {
        if (myUid==tmpMemberInfo.uid)
            myMemberInfo = tmpMemberInfo;
    }
    
    __weak typeof(self) safeSelf = self;
    [[ControllerManagement sharedInstance] fetchUserControllerWithUid:memberInfo.uid orAccount:memberInfo.empAccount checkVCard:NO onCompletion:^(UserInformationViewController *uvc) {
        uvc.targetMemberInfo = memberInfo;
        uvc.targetGroupInfo = safeSelf.groupInfo;
        uvc.delegate = safeSelf;
        uvc.dataObject = nil;
        uvc.myMemberInfo = myMemberInfo;
        
        [safeSelf.navigationController pushViewController:uvc animated:YES];
    } onFailure:nil];
}

////处理点击头像图标事件
//- (void)headPhotoTap:(UITapGestureRecognizer*)recognizer
//{
//    uint64_t uid = [objc_getAssociatedObject(recognizer, @"uid") unsignedLongLongValue]; //取出关联数据
//    
//    EBMemberInfo* memberInfo;
//    for (EBMemberInfo* tmpMemberInfo in self.memberInfos) {
//        if (uid==tmpMemberInfo.uid)
//            memberInfo = tmpMemberInfo;
//    }
//    
//    if (memberInfo)
//        [self showUserInformationWithMemberInfo:memberInfo];
//}

@end
