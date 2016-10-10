//
//  HeadPhotoSettingViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/12/23.
//  Copyright © 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EBMemberInfo;

@interface HeadPhotoSettingViewController : UIViewController

@property(nonatomic, weak) id delegate; //回调代理
@property(nonatomic, strong) EBMemberInfo* memberInfo; //成员资料对象

@end

@protocol HeadPhotoSettingViewControllerDelegate <NSObject>

@optional

///当前用户头像变更事件
- (void)headPhotoSettingViewController:(HeadPhotoSettingViewController*)viewController updateHeadPhoto:(uint64_t)resId dataObject:(id)dataObject;

@end