//
//  CTFrameParser.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-11-15.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTextData.h"
#import "CTFrameParserConfig.h"

@class EBMessage;
@class EBChatAudio;

@interface CTFrameParser : NSObject

+ (NSMutableDictionary *)attributesWithConfig:(CTFrameParserConfig *)config;

+ (CoreTextData *)parseContent:(NSString *)content config:(CTFrameParserConfig*)config;

+ (CoreTextData *)parseAttributedContent:(NSAttributedString *)content config:(CTFrameParserConfig*)config imageArray:(NSMutableArray *)imageArray linkArray:(NSMutableArray *)linkArray;

//+ (CoreTextData *)parseMessage:(EBMessage *)message config:(CTFrameParserConfig*)config chatAudio:(EBChatAudio**)chatAudio;

+ (NSAttributedString *)attributedStringWithMessage:(EBMessage *)message config:(CTFrameParserConfig*)config chatAudio:(EBChatAudio**)chatAudio imageArray:(NSMutableArray *)imageArray linkArray:(NSMutableArray *)linkArray;

/*计算内容的显示区域大小
 * @param ctFramesetter
 * @param maxSize 最大区域范围
 * @return 显示区域大小
 */
+ (CGSize)suggestSizeFrameSizeWithFramesetter:(CTFramesetterRef)ctFramesetter maxSize:(CGSize)maxSize;

//获取消息对象唯一标记
+ (NSString*)keyForMessage:(EBMessage*)message;

@end
