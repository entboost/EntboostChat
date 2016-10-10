//
//  SearchPersonController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/8/18.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "SearchPersonController.h"
#import "ButtonKit.h"
#import "ENTBoost+Utility.h"
#import "BlockUtility.h"
#import "ResourceKit.h"
#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "RelationshipHelper.h"
#import "UserInformationViewController.h"
#import "ContactInformationViewController.h"
#import "SearchPersonCell.h"

@interface SearchPersonController () <UISearchBarDelegate, UserInformationViewControllerDelegate, ContactInformationViewControllerDelegate>
{
    NSArray     *_data;
//    NSArray   *_filterData;
//    UISearchDisplayController *searchDisplayController;
    UISearchBar *_searchBar;        //搜索框
    UIButton    *_btnAccessoryView; //遮盖层
    NSDate      *_lastTextDidChangeTime;    //上一次输入内容变更的时间
    NSTimer     *_checkTextChangeTimers;    //检查输入内容变更的定时器
    NSString    *_currText;         //当前搜索条件
    
    NSMutableDictionary *_contactGroups;    //全部联系人分组资料
    NSMutableDictionary *_groups;           //裙摆部门和群组资料
    NSDate      *_lastSearchTime;           //上一次执行查询时间点
    
}

@end

@implementation SearchPersonController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"#EFFAFE"]];
    
    self.title = @"搜索";
    
    //导航栏左边按钮1
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    
//    UISearchBar *_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , 44)];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [_searchBar sizeToFit];
    _searchBar.delegate = self;
//    searchBar.backgroundColor=[UIColor clearColor];
    _searchBar.placeholder = @"搜索：联系人、群组(部门)成员";
//    [_searchBar setTintColor:EBCHAT_DEFAULT_BACKGROUND_COLOR];//[UIColor colorWithHexString:@"#194E62"]]; //搜索框颜色
//    [_searchBar setShowsCancelButton:YES animated:YES]; //显示取消按钮
//    [_searchBar setShowsSearchResultsButton:YES];
    [_searchBar setTranslucent:YES]; //设置透明
    [_searchBar setBackgroundImage:[UIImage imageFromColor:EBCHAT_DEFAULT_BLANK_DEEP_COLOR/*[UIColor colorWithHexString:@"#CBF1FE"]*/ size:CGSizeMake(_searchBar.frame.size.width, _searchBar.frame.size.height)]];
//    [_searchBar setSearchResultsButtonSelected:YES]; //显示搜索结果按钮
    
    // 遮盖层
//    [_searchBar setInputAccessoryView:myView]; //遮盖视图 //ios6以上版本支持
    _btnAccessoryView =[[UIButton alloc] initWithFrame:CGRectMake(0, _searchBar.frame.size.height, _searchBar.frame.size.width, 5000)];
    [_btnAccessoryView setBackgroundColor:[UIColor blackColor]];
    [_btnAccessoryView setAlpha:0];
    [_btnAccessoryView addTarget:self action:@selector(clickControlAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnAccessoryView];
    
//    //设置分栏条
//    [searchBar setShowsScopeBar:YES];
//    [searchBar setScopeButtonTitles:@[@"1", @"2"]];
//    [searchBar setSelectedScopeButtonIndex:1];
    
//    [searchBar setPrompt:@"搜索:联系人、群组/部门成员"];
    // 添加 searchbar 到 headerview
    self.tableView.tableHeaderView = _searchBar;
    
//    //自定义searchbar背景
//    for (UIView *view in searchBar.subviews) {
//        // for before iOS7.0
//        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
//            [view removeFromSuperview];
//            break;
//        }
//        // for later iOS7.0(include)
//        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
//            [[view.subviews objectAtIndex:0] removeFromSuperview];
//            break;
//        }
//    }
//    
//    UIImage *image = [UIImage imageFromColor:[UIColor colorWithHexString:@"#CBF1FE"] size:CGSizeMake(1500, 60)];
//    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
//    [searchBar insertSubview:imageView atIndex:1];
//    [searchBar sendSubviewToBack:imageView];
    
    //用 searchbar 初始化 SearchDisplayController
    //并把 searchDisplayController 和当前 controller 关联起来
//    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    //searchResultsDataSource 就是 UITableViewDataSource
//    searchDisplayController.searchResultsDataSource = self;
    //searchResultsDelegate 就是 UITableViewDelegate
//    searchDisplayController.searchResultsDelegate = self;
    
    ENTBoostKit *ebKit = [ENTBoostKit sharedToolKit];
    //加载联系人分组资料
    [ebKit loadContactGroupsOnCompletion:^(NSDictionary *contactGroups) {
        [BlockUtility performBlockInMainQueue:^{
            _contactGroups = [contactGroups mutableCopy];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"加载联系人分组资料失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
    }];
    //加载企业部门资料
    [ebKit loadEntGroupInfosOnCompletion:^(NSDictionary *groupInfos) {
        [BlockUtility performBlockInMainQueue:^{
           if (!_groups)
               _groups = [NSMutableDictionary dictionaryWithDictionary:groupInfos];
            else
                [_groups setValuesForKeysWithDictionary:groupInfos];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"加载企业部门资料失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
    }];
    //加载群组资料
    [ebKit loadPersonalGroupInfosOnCompletion:^(NSDictionary *groupInfos) {
        [BlockUtility performBlockInMainQueue:^{
            if (!_groups)
                _groups = [NSMutableDictionary dictionaryWithDictionary:groupInfos];
            else
                [_groups setValuesForKeysWithDictionary:groupInfos];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"加载个人群组资料失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
//    [_searchBar becomeFirstResponder]; //获取输入焦点
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回上一级
- (void)goBack
{
    [self clearSearch];
    [self.navigationController  popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

// 遮罩层（按钮）-点击处理事件
- (void)clickControlAction:(id)sender
{
    [self controlAccessoryView:0];
}

// 控制遮罩层的透明度
- (void)controlAccessoryView:(float)alphaValue
{
    [UIView animateWithDuration:0.2 animations:^{
        [_btnAccessoryView setAlpha:alphaValue]; //动画代码
    }completion:^(BOOL finished){
        if (alphaValue<=0) {
            [_searchBar resignFirstResponder];
//            [_searchBar setShowsCancelButton:NO animated:YES];
//            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    }];
}

//执行搜索
- (void)executeSearchForPersons
{
    NSLog(@"executeSearchForPersons:%@", _currText);
    [_checkTextChangeTimers setFireDate:[NSDate distantFuture]]; //相当于暂停
    if (_currText.length==0) {
        NSLog(@"搜索条件空白，忽略处理");
        return;
    }
    
    UITableView *tableView = self.tableView;
    ENTBoostKit *ebKit = [ENTBoostKit sharedToolKit];
    NSMutableArray *sortedData = [[NSMutableArray alloc] init];
    __block long result = 0;
    _lastSearchTime = [NSDate date];
    
    [BlockUtility performBlockInGlobalQueue:^{
        NSDate* localDate = _lastSearchTime;
        
        //搜索联系人(好友)
        __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [ebKit loadContactInfosOnCompletion:^(NSDictionary *contactInfos) {
            NSArray* cisArray = [contactInfos allValues];
            
            //设置过滤条件
    //        NSMutableString* filterStr = [NSMutableString stringWithFormat:@"name LIKE[cd] $V1 or account LIKE[cd] $V2"];
    //        NSMutableDictionary* filterDict = [@{@"V1":_currText, @"V2":_currText} mutableCopy];
            NSMutableString* filterStr = [NSMutableString stringWithFormat:@"name LIKE[cd] '*%@*' or account LIKE[cd] '*%@*'", _currText, _currText];
            
            //当条件是纯数字，才判断使用uid条件
            NSScanner* scan = [NSScanner scannerWithString:_currText];
            uint64_t val;
            if ([scan scanUnsignedLongLong:&val] && [scan isAtEnd]) {
                [filterStr appendFormat:@" or uid = %@", _currText];
    //            [filterStr appendFormat:@" or uid = $V3"];
    //            filterDict[@"V3"] = _currText;
            }
                
            //执行过滤
            NSPredicate *predicate = [NSPredicate predicateWithFormat: filterStr];
    //        NSPredicate *predicate = [predicateTemplate predicateWithSubstitutionVariables:filterDict];
            NSArray *results = [cisArray filteredArrayUsingPredicate:predicate];
            
            //按名称排序
            NSSortDescriptor* sortDescriptorByName = [NSArray gbkSortDescriptionWithFieldName:@"_name" ascending:YES];
            NSArray* sortedContactInfos = [results sortedArrayUsingDescriptors:@[sortDescriptorByName]];
            
            //暂存结果
            [BlockUtility performBlockInMainQueue:^{
                //依然是同一次查询才更新结果
                if (localDate==_lastSearchTime)
                    [sortedData addObjectsFromArray:sortedContactInfos];
                else
                    NSLog(@"搜索联系人执行过期:%@", localDate);
            }];
            
            dispatch_semaphore_signal(sem);
        } onFailure:^(NSError *error) {
            NSLog(@"executeSearchForPersons->loadContactInfos error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            dispatch_semaphore_signal(sem);
        }];
        result = dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 2.0f * NSEC_PER_SEC)); //最长等待2秒
        
        //搜索群组(或讨论组)成员
        if (result==0) {
            __block dispatch_semaphore_t sem1 = dispatch_semaphore_create(0);
            [ebKit loadMemberInfosOfPersonalGroupOnCompletionBlock:^(NSDictionary *memberInfos) {
                NSMutableArray *sortedMemberInfos = [[NSMutableArray alloc] init];
                
                //提取每个成员资料到一个队列
                [[memberInfos allValues] enumerateObjectsUsingBlock:^(NSDictionary* membersOfOneGroup, NSUInteger idx, BOOL *stop) {
                    [sortedMemberInfos addObjectsFromArray:[membersOfOneGroup allValues]];
                }];
                
                //=====条件过滤=====
                //设置过滤条件
                NSMutableString* filterStr = [NSMutableString stringWithFormat:@"userName LIKE[cd] '*%@*' or empAccount LIKE[cd] '*%@*'", _currText, _currText];
                
                //当条件是纯数字，才判断使用uid条件
                NSScanner* scan = [NSScanner scannerWithString:_currText];
                uint64_t val;
                if ([scan scanUnsignedLongLong:&val] && [scan isAtEnd]) {
                    [filterStr appendFormat:@" or uid = %@", _currText];
                }
                
                //执行过滤
                NSPredicate *predicate = [NSPredicate predicateWithFormat: filterStr];
                [sortedMemberInfos filterUsingPredicate:predicate];

                //按名称排序
                NSSortDescriptor* sortDescriptorByName = [NSArray gbkSortDescriptionWithFieldName:@"_userName" ascending:YES];
                [sortedMemberInfos sortedArrayUsingDescriptors:@[sortDescriptorByName]];
                
                //暂存结果
                [BlockUtility performBlockInMainQueue:^{
                    //依然是同一次查询才更新结果
                    if (localDate==_lastSearchTime)
                        [sortedData addObjectsFromArray:sortedMemberInfos];
                    else
                        NSLog(@"搜索群组成员执行过期:%@", localDate);
                }];
                dispatch_semaphore_signal(sem1);
            } onFailure:^(NSError *error) {
                 NSLog(@"executeSearchForPersons->loadMemberInfosOfPersonalGrouperror, code = %@, msg = %@", @(error.code), error.localizedDescription);
                dispatch_semaphore_signal(sem1);
            }];
            result = dispatch_semaphore_wait(sem1, dispatch_time(DISPATCH_TIME_NOW, 5.0f * NSEC_PER_SEC)); //最长等待5秒
        }
        
        //搜索部门(或项目组)成员
        if (result==0) {
            [ebKit loadMemberInfosOfEntGroupWithSearchKey:_currText onCompletionBlock:^(NSDictionary *memberInfos) {
                NSMutableArray *sortedMemberInfos = [[NSMutableArray alloc] init];
                
                //提取每个成员资料到一个队列
                [[memberInfos allValues] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [sortedMemberInfos addObjectsFromArray:[(NSDictionary*)obj allValues]];
                }];
                
                //按名称排序
                NSSortDescriptor* sortDescriptorByName = [NSArray gbkSortDescriptionWithFieldName:@"_userName" ascending:YES];
                [sortedMemberInfos sortedArrayUsingDescriptors:@[sortDescriptorByName]];
                
                [BlockUtility performBlockInMainQueue:^{
                    //依然是同一次查询才更新结果
                    if (localDate==_lastSearchTime) {
                        [sortedData addObjectsFromArray:sortedMemberInfos];
                        _data = sortedData;
                        [tableView reloadData];
                    } else
                        NSLog(@"搜索部门成员执行过期:%@", localDate);
                }];
            } onFailure:^(NSError *error) {
                NSLog(@"executeSearchForPersons->loadMemberInfosWithSearchKey:%@ error, code = %@, msg = %@", _currText, @(error.code), error.localizedDescription);
            }];
        }
    }];
}

- (void)search:(NSString*)text
{
    _currText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_currText.length>0) {
        if (!_checkTextChangeTimers) {
            _checkTextChangeTimers = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(executeSearchForPersons) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_checkTextChangeTimers forMode:NSDefaultRunLoopMode];
        } else {
            //下一次触发时间距离当前时间大于10秒，视为invalid状态
            if ([[_checkTextChangeTimers fireDate] timeIntervalSinceNow]>10) {
                [_checkTextChangeTimers setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]]; //1秒后触发
            }
        }
    } else {
        [_checkTextChangeTimers setFireDate:[NSDate distantFuture]]; //相当于暂停
        _data = nil;
        [self.tableView reloadData];
    }
}

//清除搜索状态
- (void)clearSearch
{
    if (_checkTextChangeTimers) {
        [_checkTextChangeTimers invalidate];
        _checkTextChangeTimers = nil;
    }
    _currText = nil;
}

#pragma mark -

- (void)contactInformationViewController:(ContactInformationViewController *)contactInformationViewController needExitParentController:(BOOL)needExit
{
    [self goBack];
}

- (void)userInformationViewController:(UserInformationViewController *)userInformationViewController needExitParentController:(BOOL)needExit
{
    [self goBack];
}

#pragma mark - UISearchBarDelegate

// UISearchBar得到焦点并开始编辑时，执行该方法
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
//    [_searchBar setShowsCancelButton:YES animated:YES];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self controlAccessoryView:0.15];// 显示遮盖层
    return YES;
}

// 取消按钮被按下时，执行的方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
    [_searchBar setShowsCancelButton:NO animated:YES];
    [self clearSearch];
//    [liveViewAreaTable searchDataBySearchString:nil];// 搜索tableView数据
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self controlAccessoryView:0];// 隐藏遮盖层
}

// 键盘中，搜索按钮被按下，执行的方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    NSLog(@"---%@", searchBar.text);
    [self search:searchBar.text];
    [_searchBar resignFirstResponder];// 放弃第一响应者
//    [liveViewAreaTable searchDataBySearchString:searchBar.text];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self controlAccessoryView:0];// 隐藏遮盖层
}

// 当搜索内容变化时，执行该方法。很有用，可以实现时实搜索
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    NSLog(@"textDidChange---%@", searchText);
    [self search:searchText];
//    [liveViewAreaTable searchDataBySearchString:searchBar.text];// 搜索tableView数据
//    [self controlAccessoryView:0];// 隐藏遮盖层
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
//        return _data.count;
        return 1;
    }
    return 0;
//    else {
//        //谓词搜索
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains [cd] %@" ,searchDisplayController.searchBar.text];
//        filterData = [[NSArray alloc] initWithArray:[data filteredArrayUsingPredicate:predicate]];
//        return filterData.count;
//    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return _data.count;
    }
    return 0;
}

#define SEARCH_PERSON_CELL_HEIGHT 60.0

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"searchPersonCell";
    SearchPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
//    //生成点击聊天按钮
//    CGFloat iconWidth = 30;
//    CGFloat iconHeight = iconWidth;
//    UIImageView *btnImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat"]];
//    btnImageView.frame = CGRectMake(tableView.bounds.size.width-iconHeight-20, (SEARCH_PERSON_CELL_HEIGHT-iconHeight)/2, iconWidth, iconHeight);
//    btnImageView.contentMode = UIViewContentModeScaleToFill;
//    btnImageView.tag = indexPath.row;
//    [btnImageView setUserInteractionEnabled:YES];
//    
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTalk:)];
//    [btnImageView addGestureRecognizer:singleTap];
//    [cell addSubview:btnImageView];
    
    id obj = _data[indexPath.row];
    
    //联系人(好友)
    if ([obj isMemberOfClass:[EBContactInfo class]]) {
        EBContactInfo* contactInfo = obj;
        EBContactGroup* contactGroup = _contactGroups[@(contactInfo.groupId)];
        
        cell.customImageView.image = [UIImage imageNamed:[ResourceKit defaultImageNameOfUser]];
        cell.customTitleLabel.text  = [NSString stringWithFormat:@"%@", contactInfo.name];
        cell.customDetailLabel.text = [NSString stringWithFormat:@"账号: %@", contactInfo.account];
//        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", contactInfo.name, contactInfo.account];
        
        NSString* contactGroupTypeName = [[ENTBoostKit sharedToolKit] isContactNeedVerification]?@"好友":@"联系人";
        if (contactGroup)
            cell.customDetailLabel2.text = [NSString stringWithFormat:@"来自%@[分组]\"%@\"", contactGroupTypeName, contactGroup.groupName];
        else
            cell.customDetailLabel2.text = [NSString stringWithFormat:@"来自\"未分组%@\"", contactGroupTypeName];
    } else {//部门或群组成员
        EBMemberInfo* memberInfo = obj;
        EBGroupInfo* groupInfo =  _groups[@(memberInfo.depCode)];
        
        cell.customImageView.image = [UIImage imageNamed:[ResourceKit defaultImageNameWithGroupType:groupInfo.type]];
        cell.customTitleLabel.text  = [NSString stringWithFormat:@"%@", memberInfo.userName];
        cell.customDetailLabel.text = [NSString stringWithFormat:@"账号：%@", memberInfo.empAccount];
//        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", memberInfo.userName, memberInfo.empAccount];
        if (groupInfo) {
            NSString* name;
            if (groupInfo.type == EB_GROUP_TYPE_DEPARTMENT)
                name = @"部门";
            else if (groupInfo.type == EB_GROUP_TYPE_PROJECT)
                name = @"项目组";
            else if (groupInfo.type == EB_GROUP_TYPE_GROUP)
                name = @"群组";
            else if (groupInfo.type == EB_GROUP_TYPE_TEMP)
                name = @"讨论组";
            cell.customDetailLabel2.text = [NSString stringWithFormat:@"来自[%@]\"%@\"", name, groupInfo.depName];
        } else
            cell.customDetailLabel2.text = nil;
    }
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.backgroundColor = [UIColor colorWithHexString:@"#EFFAFE"];
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 20.0;
//}
//
//- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20.0)];
//    [view setBackgroundColor:[UIColor clearColor]];
//    
//    return view;
//}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SEARCH_PERSON_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableTreeNode* node = [[TableTreeNode alloc] init];
    
    if ([_data[indexPath.row] isMemberOfClass:[EBContactInfo class]]) {
        EBContactInfo* contactInfo = _data[indexPath.row];
        node.data = [@{@"type":@(RELATIONSHIP_TYPE_CONTACT), @"contactInfo":contactInfo} mutableCopy];
        [RelationshipHelper showPropertiesWithNode:node navigationController:self.navigationController delegate:self]; //显示属性界面
        
//        //发送显示聊天界面通知
//        [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_SHOW_TALK object:self userInfo:@{@"informationType":@"USER" ,@"otherUid":@(contactInfo.uid), @"otherAccount":contactInfo.account, @"otherUserName":contactInfo.name?contactInfo.name:@""}];
    } else {
        EBMemberInfo* memberInfo = _data[indexPath.row];
        node.data = [@{@"type":@(RELATIONSHIP_TYPE_MEMBER), @"memberInfo":memberInfo} mutableCopy];
        [RelationshipHelper showPropertiesWithNode:node navigationController:self.navigationController delegate:self]; //显示属性界面
    }
}

//- (void)showTalk:(id)sender
//{
//    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
//    NSInteger row = tap.view.tag;
//    
//    if ([_data[row] isMemberOfClass:[EBContactInfo class]]) {
//        EBContactInfo* contactInfo = _data[row];
//        //发送显示聊天界面通知
//        [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_SHOW_TALK object:self userInfo:@{@"informationType":@"USER" ,@"otherUid":@(contactInfo.uid), @"otherAccount":contactInfo.account, @"otherUserName":contactInfo.name?contactInfo.name:@""}];
//    } else {
//        EBMemberInfo* memberInfo = _data[row];
//        //发送显示聊天界面通知
//        [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_SHOW_TALK object:self userInfo:@{@"informationType":@"USER" ,@"otherUid":@(memberInfo.uid), @"otherAccount":memberInfo.empAccount, @"otherUserName":memberInfo.userName?memberInfo.userName:@""}];
//    }
////    [self goBack];
//}

@end
