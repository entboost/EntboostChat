//
//  ChatImage.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-15.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

//图片默认最大尺寸
#define CHAT_IMAGE_MAX_WIDTH 96
#define CHAT_IMAGE_MAX_HEIGHT 96

//图片默认最小尺寸
#define CHAT_IMAGE_MIN_WIDTH 16
#define CHAT_IMAGE_MIN_HEIGHT 16

///聊天图片类型
typedef enum {
    CHAT_IMAGE_TYPE_COMMON, //普通图片
    CHAT_IMAGE_TYPE_RESOURCE //系统资源(表情或头像等)
} CHAT_IMAGE_TYPE;

///聊天记录内图片信息
@interface CoreTextImageData : NSObject

@property(nonatomic, strong) NSString* tag; //唯一标识
@property(nonatomic, readonly) CGSize size; //图片大小
@property(nonatomic, readonly) CGSize scaleSize; //图片适配大小(非图片真实大小)
@property(nonatomic) CGFloat descender; //基线下段高度，通常与字体基线下端高度一致，用于计算图片显示高度(累加)；否则图片不能正常显示
@property(nonatomic) CHAT_IMAGE_TYPE imageType; //聊天图片类型


@property (strong, nonatomic) NSString * name;
//同一聊天记录内的索引，从0开始
@property (nonatomic) NSUInteger position;
//此坐标是 CoreText 的坐标系，而不是UIKit的坐标系
@property (nonatomic) CGRect imagePosition;


/**初始化
 * 默认使用最大尺寸，如图片小于最小尺寸则使用最小尺寸
 * @param imageName 图片文件名
 * @param tag 唯一标识
 */
- (id)initWithImageName:(NSString*)imageName forTag:(NSString*)tag;

/**初始化
 * 默认使用最大尺寸，如图片小于最小尺寸则使用最小尺寸
 * @param filePath 图片文件绝对路径
 * @param tag 唯一标识
 */
- (id)initWithFilePath:(NSString*)filePath forTag:(NSString*)tag;

/**初始化
 * 默认使用最大尺寸，如图片小于最小尺寸则使用最小尺寸
 * @param image 图片对象
 * @param tag 唯一标识
 */
- (id)initWithImage:(UIImage*)image forTag:(NSString*)tag;

/**初始化
 * @param image 图片对象
 * @param scaleSize 等比例缩放的尺寸
 * @param tag 唯一标识
 */
- (id)initWithImage:(UIImage*)image UsingScaleSize:(CGSize)scaleSize forTag:(NSString*)tag;

///获取原始图片
- (UIImage*)image;

///获取等比例缩放后的图片
- (UIImage*)scaleImage;

///获取文件名
- (NSString*)imageName;

///获取文件绝对路径
- (NSString*)filePath;

@end
