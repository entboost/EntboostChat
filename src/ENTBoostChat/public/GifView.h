//
//  GifView.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//
//  播放gif文件


#import <UIKit/UIKit.h>

@interface GifView : UIView


@property(nonatomic) float repeatCount; //重复播放次数

///**初始化
// * @param center 位置中心点
// * @param fileURL gif文件访问路径
// */
//- (id)initWithCenter:(CGPoint)center fileURL:(NSURL*)fileURL;

//设置gif文件访问路径
- (void)setFileURL:(NSURL*)fileURL;

///开始播放动画
- (void)startAnimation;

///停止播放动画
- (void)stopAnimation;

///**获取gif各帧列表
// * @param fileURL gif文件访问路径
// */
//+ (NSArray*)framesInGif:(NSURL*)fileURL;


@end
