//
//  ControllerManagement.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/15.
//  Copyright (c) 2015年 EB. All rights reserved.
//
//  管理显示群组和用户属性的界面


#import <Foundation/Foundation.h>

@class UserInformationViewController;
@class GroupInformationViewController;
@class ContactInformationViewController;
@class CommonTextInputViewController;
@class EBContactInfo;

@interface ControllerManagement : NSObject

//获取全局单例
+ (id)sharedInstance;

/**获取查看联系人属性的Controller
 * @param contactInfo 联系人信息
 * @param completionBlock 正常获取结果的回调
 * @param failureBlock 错误后的回调
 */
- (void)fetchContactControllerWithContactInfo:(EBContactInfo*)contactInfo onCompletion:(void(^)(ContactInformationViewController* cvc))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**获取查看用户属性的controller
 * 用户编号和用户账号至少一个不等于0或nil
 * @param uid 用户编号
 * @param account 用户账号
 * @param checkVCard 获取电子名片
 * @param completionBlock 正常获取结果的回调
 * @param failureBlock 错误后的回调
 */
- (void)fetchUserControllerWithUid:(uint64_t)uid orAccount:(NSString*)account checkVCard:(BOOL)checkVCard onCompletion:(void(^)(UserInformationViewController* uvc))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**获取查看群组(部门)属性的controller
 * @param depCode 群组(部门)编号
 * @param completionBlock 正常获取结果的回调
 * @param failureBlock 错误后的回调
 */
- (void)fetchGroupControllerWithDepCode:(uint64_t)depCode onCompletion:(void(^)(GroupInformationViewController* gvc))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/*!获取输入文本的controller
 @param navigationTitle 导航栏标题
 @param defaultText 初始化文本
 @param textInputViewHeight 输入框高度，填0表示使用默认值
 @param delegete 代理对象
 @return 文本输入的controller
 */
- (CommonTextInputViewController*)fetchCommonTextInputControllerWithNavigationTitle:(NSString*)navigationTitle defaultText:(NSString*)defaultText textInputViewHeight:(CGFloat)textInputViewHeight delegate:(id)delegete;

@end
