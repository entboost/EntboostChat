//
//  SecritySettingsViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/11/16.
//  Copyright © 2015年 EB. All rights reserved.
//

#import "SecritySettingsViewController.h"
#import "ChangePasswordViewController.h"
#import "InformationCell1.h"
#import "ENTBoostChat.h"
#import "ButtonKit.h"

@interface SecritySettingsViewController ()
{
    UIStoryboard* _settingStoryboard;
}
@end

@implementation SecritySettingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _settingStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_SETTING bundle:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)]; //导航栏左边按钮1
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

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InformationCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"MyInformationCell_1" forIndexPath:indexPath];
    
    cell.customTextLabel.text = @"修改密码";
    
    return cell;
}

#define HEIGHT_FOR_HEADER_FOOTER 20.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

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
    
    ChangePasswordViewController* vc = [_settingStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_CHANGE_PASSWORD_CONTROLLER];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
