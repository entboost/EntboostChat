//
//  CaptionEditViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/10/23.
//  Copyright © 2015年 EB. All rights reserved.
//

//  编辑名称、备注资料

#import <UIKit/UIKit.h>

@interface CaptionEditViewController : UIViewController

@property(nonatomic, weak) id delegate; //代理
@property(nonatomic, strong) NSString*  customName;         //名称
@property(nonatomic, strong) NSString*  customDescription;  //备注

@end



@protocol CaptionEditViewControllerDelgate <NSObject>

@optional
/*!内容输入完毕后点击保存事件
 @param captionEditViewController
 @param text 输入的名称内容
 @param description 输入的备注内容
 */
- (void)captionEditViewController:(CaptionEditViewController*)captionEditViewController wantToSaveInputName:(NSString*)name inputDescription:(NSString*)description;

@end