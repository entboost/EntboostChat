//
//  ResourceKit.m
//  ENTBoostChat
//
//  Created by zhong zf on 16/1/7.
//  Copyright © 2016年 EB. All rights reserved.
//

#import "ResourceKit.h"

@implementation ResourceKit

+ (NSString*)defaultImageNameWithGroupType:(EB_GROUP_TYPE)groupType
{
    NSString* imageName;
    switch (groupType) {
        case EB_GROUP_TYPE_DEPARTMENT:
            imageName = @"default_department_head";
            break;
        case EB_GROUP_TYPE_PROJECT:
            imageName = @"default_project_group_head";
            break;
        case EB_GROUP_TYPE_GROUP:
            imageName = @"default_personal_group_head";
            break;
        case EB_GROUP_TYPE_TEMP:
            imageName = @"default_temp_group_head";
            break;
    }
    
    return imageName;
}

+ (NSString*)minusAccessoryImageNameWithGroupType:(EB_GROUP_TYPE)groupType
{
    NSString* imageName;
    switch (groupType) {
        case EB_GROUP_TYPE_DEPARTMENT:
            imageName = @"tree_type0_opened";
            break;
        case EB_GROUP_TYPE_PROJECT:
            imageName = @"tree_type1_opened";
            break;
        case EB_GROUP_TYPE_GROUP:
            imageName = @"tree_type2_opened";
            break;
        case EB_GROUP_TYPE_TEMP:
            imageName = @"tree_type3_opened";
            break;
    }
    
    return imageName;
}

+ (NSString*)plusAccessoryImageNameWithGroupType:(EB_GROUP_TYPE)groupType
{
    NSString* imageName;
    switch (groupType) {
        case EB_GROUP_TYPE_DEPARTMENT:
            imageName = @"tree_type0_closed";
            break;
        case EB_GROUP_TYPE_PROJECT:
            imageName = @"tree_type1_closed";
            break;
        case EB_GROUP_TYPE_GROUP:
            imageName = @"tree_type2_closed";
            break;
        case EB_GROUP_TYPE_TEMP:
            imageName = @"tree_type3_closed";
            break;
    }
    
    return imageName;
}

+ (NSString*)defaultImageNameOfUser
{
    return @"default_user_head";
}

+ (NSString*)defaultImageNameOf3rdApplication
{
    return @"default_application_head";
}

+ (NSString*)defaultImageNameOfNotification
{
    return @"default_notification_head";
}

+ (UIImage*)imageOf3rdApplicationWithSubId:(uint64_t)subId
{
    NSString* imageName = [NSString stringWithFormat:@"subid_%llu", subId];
    return [UIImage imageNamed:imageName];
}

+ (BOOL)showImageWithFilePath:(NSString*)filepath inImageView:(UIImageView*)imageView
{
    if (filepath.length) {
        imageView.image = [UIImage imageWithContentsOfFile:filepath];
        return YES;
    }
    return NO;
}

+ (void)showGroupHeadPhotoWithFilePath:(NSString*)filepath inImageView:(UIImageView*)imageView forGroupType:(EB_GROUP_TYPE)groupType
{
    if (![self showImageWithFilePath:filepath inImageView:imageView])
        imageView.image = [UIImage imageNamed:[self defaultImageNameWithGroupType:groupType]];
}

+ (void)showUserHeadPhotoWithFilePath:(NSString*)filepath inImageView:(UIImageView*)imageView
{
    if (![self showImageWithFilePath:filepath inImageView:imageView])
        imageView.image = [UIImage imageNamed:[self defaultImageNameOfUser]];
}

+ (void)show3rdApplicationHeadPhotoWithFilePath:(NSString*)filepath inImageView:(UIImageView*)imageView
{
    if (![self showImageWithFilePath:filepath inImageView:imageView])
        imageView.image = [UIImage imageNamed:[self defaultImageNameOf3rdApplication]];
}

+ (void)showNotificationHeadPhotoWithFilePath:(NSString*)filepath inImageView:(UIImageView*)imageView
{
    if (![self showImageWithFilePath:filepath inImageView:imageView]) {
        imageView.image = [UIImage imageNamed:[self defaultImageNameOfNotification]];
    }
}

@end
