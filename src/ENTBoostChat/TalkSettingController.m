//
//  TalkSettingController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/12/18.
//  Copyright © 2015年 EB. All rights reserved.
//

#import "TalkSettingController.h"
#import "InformationCell1.h"
#import "ENTBoost.h"
#import "ENTBoost+Utility.h"
#import "BlockUtility.h"
#import "ButtonKit.h"
#import <objc/runtime.h>

@interface TalkSettingController ()

@property (nonatomic, strong) NSMutableArray* settings;

@end

@implementation TalkSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)]; //导航栏左边按钮1
    
    self.settings = [[NSMutableArray alloc] initWithCapacity:4];
    [self.settings addObject:@{@"外部企业用户":@[@{@(EB_SETTING_ENABLE_OUTENT_CALL):@"允许外部企业用户呼叫我"}, @{@(EB_SETTING_AUTO_OUTENT_ACCEPT):@"当我在线时，自动接通聊天会话"}]}];
    [self.settings addObject:@{@"普通注册用户":@[@{@(EB_SETTING_ENABLE_USER_CALL):@"允许普通注册用户呼叫我"}, @{@(EB_SETTING_AUTO_USER_ACCEPT):@"当我在线时，自动接通聊天会话"}]}];
    [self.settings addObject:@{@"游客匿名用户":@[@{@(EB_SETTING_ENABLE_VISITOR_CALL):@"允许游客匿名用户呼叫我"}, @{@(EB_SETTING_AUTO_VISITOR_ACCEPT):@"当我在线时，自动接通聊天会话"}]}];
    [self.settings addObject:@{@"离线状态":@[@{@(EB_SETTING_ENABLE_OFF_FILE):@"允许接收离线文件"}, @{@(EB_SETTING_ENABLE_OFF_CALL):@"当我离线时，自动接收离线信息"}]}];
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
    return self.settings.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.settings[section] allValues][0] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InformationCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"InformationCell_1" forIndexPath:indexPath];
    
    NSArray* subSettings = [self.settings[indexPath.section] allValues][0];
    NSDictionary* dict = subSettings[indexPath.row];
    //设置属性标题
    cell.customTextLabel.text = [dict allValues][0];
    
    //获取属性值
    EBAccountInfo* accountInfo = [[ENTBoostKit sharedToolKit] accountInfo];
    int value = [[dict allKeys][0] intValue];
    
    //分段宽度
    [cell.customSegmentedCtrl setWidth:30.0 forSegmentAtIndex:0];
    [cell.customSegmentedCtrl setWidth:30.0 forSegmentAtIndex:1];
    //分段颜色
    [cell.customSegmentedCtrl setTintColor:[UIColor colorWithHexString:@"#60B1CE"]];
    
    //点选改变事件
    [cell.customSegmentedCtrl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    //关联数据
    objc_setAssociatedObject(cell.customSegmentedCtrl , @"indexPath", indexPath, OBJC_ASSOCIATION_RETAIN);
    
    //设置选中
    if ((accountInfo.setting&value)==value) {
        cell.customSegmentedCtrl.selectedSegmentIndex = 0;
    } else
        cell.customSegmentedCtrl.selectedSegmentIndex = 1;
    
    return cell;
}

//性别选择事件处理
-(void)segmentAction:(UISegmentedControl*)segCtrl
{
    //取出关联数据
    NSIndexPath* indexPath = objc_getAssociatedObject(segCtrl, @"indexPath");
    NSArray* subSettings = [self.settings[indexPath.section] allValues][0];
    NSDictionary* dict = subSettings[indexPath.row];
    EB_SETTING_VALUE value = [[dict allKeys][0] intValue];
    
    //获取原有配置
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    int newSetting = ebKit.accountInfo.setting;
    
    //设置新值
    if (segCtrl.selectedSegmentIndex==0) //是
        newSetting |= value;
    else //否
        newSetting &= (~value);
    
    //执行保存，成功后刷新视图
    __weak typeof(self) safeSelf = self;
    [ebKit editUserSetting:newSetting onCompletion:^{
        [BlockUtility performBlockInMainQueue:^{
            [safeSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"edit userSetting error, code = %@, msg = %@", @(error.code), error.localizedDescription);
    }];
}


#define HEIGHT_FOR_HEADER 36.0f
#define HEIGHT_FOR_FOOTER 20.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEIGHT_FOR_HEADER;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, HEIGHT_FOR_HEADER)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:(CGRect){5, HEIGHT_FOR_HEADER-25, 200, 24}];
    headerLabel.text = [self.settings[section] allKeys][0];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor grayColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont systemFontOfSize:14];
    
    [view addSubview:headerLabel];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==self.settings.count-1)
        return HEIGHT_FOR_FOOTER;
    else
        return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, HEIGHT_FOR_FOOTER)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    return view;
}

@end
