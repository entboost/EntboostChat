//
//  ResourceKit.h
//  ENTBoostChat
//
//  Created by zhong zf on 16/1/7.
//  Copyright © 2016年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENTBoost.h"

@interface ResourceKit : NSObject

//获取默认部门或群组的默认头像图片文件名
+ (NSString*)defaultImageNameWithGroupType:(EB_GROUP_TYPE)groupType;

/**获取树折叠节点图标
 * @param groupType group类型
 * @return 图片文件名
 */
+ (NSString*)minusAccessoryImageNameWithGroupType:(EB_GROUP_TYPE)groupType;

/**获取树扩展节点图标
 * @param groupType group类型
 * @return 图片文件名
 */
+ (NSString*)plusAccessoryImageNameWithGroupType:(EB_GROUP_TYPE)groupType;

//获取用户的默认头像图片文件名
+ (NSString*)defaultImageNameOfUser;

//获取接入应用的默认头像图片文件名
+ (NSString*)defaultImageNameOf3rdApplication;

//获取提醒事件的默认头像图片文件名
+ (NSString*)defaultImageNameOfNotification;

/**从程序包里获取接入应用头像图像实例
 * @param subId 应用订购编号
 * @return 图像实例，如果对应图片文件不存在，则返回nil
 */
+ (UIImage*)imageOf3rdApplicationWithSubId:(uint64_t)subId;

/**显示图片
 * @param filePath 图片文件绝对路径
 * @param imageView 显示头像的普通视图(容器)
 * @return 如果filePath==nil则返回NO，否则返回YES
 */
+ (BOOL)showImageWithFilePath:(NSString*)filepath inImageView:(UIImageView*)imageView;

/**显示部门或群组头像图片；如果filePath==nil，则显示默认图片
 * @param filePath 图片文件绝对路径
 * @param imageView 显示头像的普通视图(容器)
 */
+ (void)showGroupHeadPhotoWithFilePath:(NSString*)filepath inImageView:(UIImageView*)imageView forGroupType:(EB_GROUP_TYPE)groupType;

/**显示用户头像图片；如果filePath==nil，则显示默认图片
 * @param filePath 图片文件绝对路径
 * @param imageView 显示头像的普通视图(容器)
 */
+ (void)showUserHeadPhotoWithFilePath:(NSString*)filepath inImageView:(UIImageView*)imageView;

/**显示接入应用头像图片；如果filePath==nil，则显示默认图片
 * @param filePath 图片文件绝对路径
 * @param imageView 显示头像的普通视图(容器)
 */
+ (void)show3rdApplicationHeadPhotoWithFilePath:(NSString*)filepath inImageView:(UIImageView*)imageView;

/**显示提醒事件的头像图片；如果filePath==nil，则显示默认图片
 * @param filePath 图片文件绝对路径
 * @param imageView 显示头像的普通视图(容器)
 */
+ (void)showNotificationHeadPhotoWithFilePath:(NSString*)filepath inImageView:(UIImageView*)imageView;

@end
