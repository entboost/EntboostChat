//
//  ChatView.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-15.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "CoreTextData.h"

#define CHAT_IMAGE_TAG_NAME @"chatImageTag"

@class CoreTextImageData;
@class CoreTextLinkData;

@interface ChatView : UIView

@property(nonatomic, weak) id delegate; //事件代理
//@property(nonatomic) CTFramesetterRef ctFramesetter; //帧管理器
@property (strong, nonatomic) CoreTextData * data;

///**初始化
// * @param ctFramesetter 帧管理器
// * @param frame 本view窗口矩形
// */
//- (id)initWithCTFramesetterRef:(CTFramesetterRef)ctFramesetter andFrame:(CGRect)frame;

/**初始化
 * @param data 渲染参数
 * @param frame 本view窗口位置尺寸
 */
- (id)initWithCoreTextData:(CoreTextData*)data frame:(CGRect)frame;

@end

@protocol ChatViewDelegate

@optional
//图片点击事件
- (void)chatView:(ChatView*)chatView imageTaped:(CoreTextImageData *)imageData;

//链接点击事件
- (void)chatView:(ChatView*)chatView linkTaped:(CoreTextLinkData *)linkData;

//双击事件
- (void)chatView:(ChatView*)chatView doubleTaped:(UITapGestureRecognizer *)recognizer data:(id)data;

//长按事件
- (void)chatView:(ChatView*)chatView longPressed:(UILongPressGestureRecognizer *)recognizer data:(id)data;


@end