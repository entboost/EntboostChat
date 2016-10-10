//
//  UIImage+UIImageScale.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-15.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Uitlity)

/**计算压缩后的分辨率
 * @param maxSize 压缩后的最大分辨率
 * @param originSize 压缩前分辨率
 * @param realSize 压缩后的实际分辨率
 * @return 是否需要调整分辨率(如果本来的分辨率小于最大分辨率，则不需要调整)
 */
+ (BOOL)decreaseUnderSize:(CGSize)maxSize originSize:(CGSize)originSize realSize:(CGSize*)realSize;

///截取部分图片
- (UIImage*)getSubImage:(CGRect)rect;

/**等比例缩放图片
 * 图片最终分辨率与期望分辨率一致, 空白处将透明填充
 * @param size 图片分辨率
 * @return 图片对象
 */
- (UIImage*)scaleToSize:(CGSize)size;

/**等比例缩放图片
 * 图片最终分辨率将被调整到实际分辨率
 * @param suggestedSize 图片期望分辨率
 * @param realSize 缩放后最终分辨率
 * @return 图片对象
 */
- (UIImage*)scaleTosuggestedSize:(CGSize)suggestedSize realSize:(CGSize*)realSize;

///灰度图片
- (UIImage*)convertToGrayscale;

/**使用纯色生成一个图片
 * @param color 颜色对象
 * @param size 图片大小
 * @return 图片对象
 */
+ (UIImage*)imageFromColor:(UIColor*)color size:(CGSize)size;

///以弧度旋转图片
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;

///以角度数旋转图片
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end
