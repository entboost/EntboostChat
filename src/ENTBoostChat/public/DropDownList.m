//
//  DropDownList.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/9/21.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "DropDownList.h"
#import "ENTBoostChat.h"
#import "ENTBoost+Utility.h"

@interface DropDownList () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong)    UITableView* tableView;
@property(nonatomic, weak)      UIView* inputView;
@property(nonatomic, weak)      UIView* rootView;

@property(nonatomic, weak)      id delegate;

@end

@implementation DropDownList

- (id)initWithInputView:(UIView*)inputView rootView:(UIView*)rootView delegate:(id)delegate
{
    if (self = [super init]) {
        self.inputView = inputView;
        self.rootView = rootView;
        
//        self.tableView = [[UITableView alloc] initWithFrame:targetFrame];
        self.tableView = [[UITableView alloc] init];
        if (IOS7)
            self.tableView.separatorInset = UIEdgeInsetsZero;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.separatorColor = [UIColor lightGrayColor];
        self.tableView.hidden = YES;
        
        EBCHAT_UI_SET_CORNER_BUTTON_4(self.tableView);
        
        self.delegate = delegate;
    }
    return self;
}

- (BOOL)isHidden
{
    return self.tableView.hidden;
}

//在指定视图内找寻当前tableView
- (UITableView*)findInView:(UIView*)view
{
    __block UITableView* resultView;
    [[view subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj == self.tableView) {
            resultView = obj;
            *stop = YES;
        }
    }];
    return resultView;
}

- (void)show:(BOOL)hidden toTargetFrame:(CGRect)targetFrame
{
    UITableView* tableView = [self findInView:self.rootView];
    if (!tableView) {
        [self.rootView addSubview:self.tableView];
    }
    self.tableView.frame = targetFrame;
    self.tableView.hidden = hidden;
}

- (void)show:(BOOL)hidden
{
    CGRect inputViewFrame   = self.inputView.frame;
    inputViewFrame.origin.x = 0;
    inputViewFrame.origin.y = 0;
    UIView* view            = self.inputView;
    
    do {
        inputViewFrame = [view convertRect:inputViewFrame toView:[view superview]];
        view = [view superview];
    } while (view != self.rootView);
    
    CGRect targetFrame = inputViewFrame;
    targetFrame.origin.y = inputViewFrame.origin.y + inputViewFrame.size.height;
    targetFrame.size.height = 30.0 * self.data.count;//(self.data.count>0?self.data.count:(self.data.count+1));
    
    [self show:hidden toTargetFrame:targetFrame];
}

- (void)refresh
{
    [self show:self.tableView.hidden];
    [self.tableView reloadData];
}


#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self.delegate respondsToSelector:@selector(dropDownList:atRow:supplyCell:data:)]) {
        [self.delegate dropDownList:self atRow:indexPath.row supplyCell:cell data:self.data[indexPath.row]];
//        UserNamePassword* unp = self.data[indexPath.row];
//        cell.textLabel.text = unp.userName;
    } else {
        cell.textLabel.text = @"未知";
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0;
}

////行缩进
//-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 0;
//}

//- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
//        [cell setPreservesSuperviewLayoutMargins:NO];
//    }
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 30.0;
//}
//
//- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30.0)];
//    [view setBackgroundColor:[UIColor clearColor]];
//
//    return view;
//}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(dropDownList:atRow:didSelectedWithData:)])
        [self.delegate dropDownList:self atRow:indexPath.row didSelectedWithData:self.data[indexPath.row]];
//    [self.accountTextField resignFirstResponder];
//    [self.accountListTableView setHidden:YES];
//    
//    UserNamePassword* unp = _accountList[indexPath.row];
//    self.accountTextField.text = unp.userName;
//    NSString* password;
//    if ([unp.password isMemberOfClass:[NSString class]])
//        password = unp.password;
//    self.passwordTextField.text = password;
//    
//    [self.accountTextField resignFirstResponder];
//    [self.passwordTextField becomeFirstResponder];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id data = self.data[indexPath.row];
        [self.data removeObjectAtIndex:indexPath.row]; //从缓存里删除
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft]; //删除视图对应行
        [self show:self.tableView.hidden]; //刷新窗口
        
        //通知上层
        if ([self.delegate respondsToSelector:@selector(dropDownList:atRow:deleteWithData:)])
            [self.delegate dropDownList:self atRow:indexPath.row deleteWithData:data];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

@end
