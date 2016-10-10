//
//  ChatImage.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-15.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "CoreTextImageData.h"
#import "ENTBoost+Utility.h"

#pragma mark - ChatImage
@implementation CoreTextImageData
{
    NSString* _imageName; //图片文件名称
    NSString* _filePath; //图片文件绝对路径
    
    UIImage* _image; //原始大小图片
    UIImage* _scaleImage; //等比例缩放后图片
    
    CGSize _size; //图片原始大小
    CGSize _scaleSize; //图片等比例缩放后大小
}

/**获取图片对象
 * 参数二选一填写
 * @param imageName 图片文件名
 * @param filePath 图片文件绝对路径
 */
+ (UIImage*)imageWithImageName:(NSString*)imageName filePath:(NSString*)filePath
{
    UIImage* image;
    if(imageName)
        image = [UIImage imageNamed:imageName];
    else
        image = [UIImage imageWithContentsOfFile:filePath];
    
    return image;
}

//计算默认缩放大小
+ (CGSize)defaultScaleSizeWithImage:(UIImage*)image
{
    CGSize scaleSize = CGSizeMake(CHAT_IMAGE_MAX_WIDTH, CHAT_IMAGE_MAX_HEIGHT);
    if(image) {
        CGSize size = image.size;
        //如果图片原始尺寸小于默认最小尺寸，则使用默认最小尺寸进行缩放
        if(size.width <= CHAT_IMAGE_MIN_WIDTH && size.height <= CHAT_IMAGE_MIN_HEIGHT) {
            scaleSize = CGSizeMake(CHAT_IMAGE_MIN_WIDTH, CHAT_IMAGE_MIN_HEIGHT);
        } else if(size.width <= CHAT_IMAGE_MAX_WIDTH && size.height <= CHAT_IMAGE_MAX_HEIGHT) {
            scaleSize = size;
        }
    }
    return scaleSize;
}

- (id)initWithImage:(UIImage*)image UsingScaleSize:(CGSize)scaleSize forTag:(NSString*)tag
{
    if(self = [super init]) {
        self.descender = 0.0;
        self.tag = tag;
        _size = _scaleSize = CGSizeZero;
        if(image) {
            _image = image;
            _size = _image.size;
            _scaleSize = scaleSize;
            _scaleImage = [_image scaleTosuggestedSize:scaleSize realSize:&_scaleSize];
        }
    }
    return self;
}

- (id)initWithImage:(UIImage*)image forTag:(NSString*)tag
{
    CGSize scaleSize = [CoreTextImageData defaultScaleSizeWithImage:image];
    
    if(self = [self initWithImage:image UsingScaleSize:scaleSize forTag:tag]) {
       
    }
    
    return self;
}

- (id)initWithImageName:(NSString*)imageName forTag:(NSString*)tag
{
    UIImage* image = [CoreTextImageData imageWithImageName:imageName filePath:nil];
    CGSize scaleSize = [CoreTextImageData defaultScaleSizeWithImage:image];
    
    if(self = [self initWithImage:image UsingScaleSize:scaleSize forTag:tag]) {
        _imageName = imageName;
    }
    
    return self;
}

- (id)initWithFilePath:(NSString*)filePath forTag:(NSString*)tag
{
    UIImage* image = [CoreTextImageData imageWithImageName:nil filePath:filePath];
    CGSize scaleSize = [CoreTextImageData defaultScaleSizeWithImage:image];
    
    if(self = [self initWithImage:image UsingScaleSize:scaleSize forTag:tag]) {
        _filePath = filePath;
    }
    
    return self;
}

- (UIImage*)image
{
    return _image;
}

- (UIImage*)scaleImage
{
    return _scaleImage;
}

- (NSString*)imageName
{
    return _imageName;
}

- (NSString*)filePath
{
    return _filePath;
}

@end

