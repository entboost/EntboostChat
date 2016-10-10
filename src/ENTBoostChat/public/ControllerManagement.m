//
//  ControllerManagement.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/15.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "ControllerManagement.h"
#import "ENTBoostChat.h"
#import "BlockUtility.h"
#import "UserInformationViewController.h"
#import "GroupInformationViewController.h"
#import "ContactInformationViewController.h"
#import "CommonTextInputViewController.h"

@interface ControllerManagement ()
{
    UIStoryboard* _settingStoryboard;
    UIStoryboard* _otherStoryboard;
}
@end

@implementation ControllerManagement

- (id)init
{
    if (self = [super init]) {
        _settingStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_SETTING bundle:nil];
        _otherStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_OTHER bundle:nil];
    }
    return self;
}

+ (id)sharedInstance
{
    static ControllerManagement *instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[ControllerManagement alloc] init];
    });
    return instance;
}

- (void)fetchContactControllerWithContactInfo:(EBContactInfo*)contactInfo onCompletion:(void(^)(ContactInformationViewController* cvc))completionBlock onFailure:(void(^)(NSError* error))failureBlock
{
    ContactInformationViewController* cvc = [_settingStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_CONTACT_INFORMATION_CONTROLLER];
    cvc.contactInfo = contactInfo;
    
    if (contactInfo.groupId) {
        [[ENTBoostKit sharedToolKit] loadContactGroupsOnCompletion:^(NSDictionary *contactGroups) {
            [BlockUtility performBlockInMainQueue:^{
                cvc.contactGroup = contactGroups[@(contactInfo.groupId)];
                
                if (completionBlock)
                    completionBlock(cvc);
            }];
        } onFailure:^(NSError *error) {
            NSLog(@"loadContactGroups error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            if (failureBlock) {
                [BlockUtility performBlockInMainQueue:^{
                    failureBlock(error);
                }];
            }
        }];
    } else {
        if (completionBlock)
            completionBlock(cvc);
    }
}

- (void)fetchUserControllerWithUid:(uint64_t)uid orAccount:(NSString*)account checkVCard:(BOOL)checkVCard onCompletion:(void(^)(UserInformationViewController* uvc))completionBlock onFailure:(void(^)(NSError* error))failureBlock
{
    UserInformationViewController* uvc = [_settingStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_USER_INFORMATION_CONTROLLER];

    if (checkVCard) {
        //获取用户默认电子名片
        NSString* virtualAccount = uid>0?[NSString stringWithFormat:@"%llu", uid]:account;
        [[ENTBoostKit sharedToolKit] queryUserInfoWithVirtualAccount:virtualAccount onCompletion:^(uint64_t newUid, NSString *newAccount, EBVCard *vCard) {
            [BlockUtility performBlockInMainQueue:^{
                uvc.uid = newUid;
                uvc.account = newAccount;
                uvc.vCard = vCard;
                
                if (completionBlock)
                    completionBlock(uvc);
            }];
        } onFailure:^(NSError *error) {
            NSLog(@"queryUserInfoWithVirtualAccount error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            if (failureBlock) {
                [BlockUtility performBlockInMainQueue:^{
                    failureBlock(error);
                }];
            }
        }];
    } else {
        uvc.uid = uid;
        uvc.account = account;
        
        if (completionBlock)
            completionBlock(uvc);
    }
}

- (void)fetchGroupControllerWithDepCode:(uint64_t)depCode onCompletion:(void(^)(GroupInformationViewController* gvc))completionBlock onFailure:(void(^)(NSError* error))failureBlock
{
    GroupInformationViewController* gvc = [_settingStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_GROUP_INFORMATION_CONTROLLER];
    
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    gvc.groupInfo = [ebKit groupInfoWithDepCode:depCode];
    
    if (gvc.groupInfo) {
        if (gvc.groupInfo.entCode) {
            //读取企业信息
            __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            [ebKit loadEnterpriseInfoOnCompletion:^(EBEnterpriseInfo *enterpriseInfo) {
                [BlockUtility syncPerformBlockInMainQueue:^{
                    gvc.enterpriseInfo = enterpriseInfo;
                }];
                dispatch_semaphore_signal(sem);
            } onFailure:^(NSError *error) {
                NSLog(@"loadEnterpriseInfo error, code = %@, msg = %@", @(error.code), error.localizedDescription);
                dispatch_semaphore_signal(sem);
            }];
            dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 2.0f * NSEC_PER_SEC)); //最长等待2秒
        }
        
        if (completionBlock)
            completionBlock(gvc);
    } else {
        NSLog(@"没有找到群组(部门)%llu", depCode);
        if (failureBlock)
            failureBlock(EBERR(EB_STATE_ERROR, @"没有找到群组(部门)"));
    }
}

- (CommonTextInputViewController*)fetchCommonTextInputControllerWithNavigationTitle:(NSString*)navigationTitle defaultText:(NSString*)defaultText textInputViewHeight:(CGFloat)textInputViewHeight delegate:(id)delegete
{
    CommonTextInputViewController* vc = [_otherStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_COMMON_TEXT_INPUT_CONTROLLER];
    vc.delegate = delegete;
    vc.navigationTitle = navigationTitle;
    vc.defaultText = defaultText;
    vc.textInputViewHeight = textInputViewHeight;
    
    return vc;
}

@end
