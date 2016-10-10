//
//  MyInformationViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/6.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyInformationViewController : UITableViewController

@property(nonatomic, weak) id delegate; //回调代理
@property(weak, nonatomic) id dataObject; //自定义数据对象

@end


@class EBAccountInfo;

@protocol MyInformationViewControllerDelegate <NSObject>

@optional

///当前用户资料变更事件
- (void)myInformationViewController:(MyInformationViewController*)viewController updateAccountInfo:(EBAccountInfo*)accountInfo dataObject:(id)dataObject;

@end