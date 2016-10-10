//
//  CTFrameParser.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-11-15.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "CTFrameParser.h"
#import "CTFrameParserConfig.h"
#import "CoreTextImageData.h"
#import "CoreTextLinkData.h"
#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "ENTBoost+Utility.h"

@implementation CTFrameParser

//销毁引用对象
static void deallocCallback(void* ref){
    CFRelease(ref);
}

//获取基线上段
static CGFloat ascentCallback(void *ref)
{
//    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
    CoreTextImageData* imageData = (__bridge CoreTextImageData*)ref;
    return imageData.scaleSize.height;
}

//获取基线下段
static CGFloat descentCallback(void *ref)
{
    CoreTextImageData* imageData = (__bridge CoreTextImageData*)ref;
    return fabs(imageData.descender);
}

//获取宽度
static CGFloat widthCallback(void* ref)
{
//    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
    CoreTextImageData* imageData = (__bridge CoreTextImageData*)ref;
    return imageData.scaleSize.width;
}
#pragma mark -

+ (NSMutableDictionary *)attributesWithConfig:(CTFrameParserConfig *)config
{
    CGFloat fontSize = config.fontSize;
//    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    CGFontRef fontRef = (__bridge_retained CGFontRef)([UIFont systemFontOfSize:fontSize]);
    CGFloat lineSpacing = config.lineSpace;
    const CFIndex kNumberOfSettings = 3;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing }
    };
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    UIColor * textColor = config.textColor;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    
    CFRelease(theParagraphRef);
    CFRelease(fontRef);
    return dict;
}

//+ (CoreTextData *)parseMessage:(EBMessage *)message config:(CTFrameParserConfig*)config chatAudio:(EBChatAudio**)chatAudio
//{
//    NSMutableArray *imageArray = [NSMutableArray array];
//    NSMutableArray *linkArray = [NSMutableArray array];
//    NSAttributedString *content = [self loadMessage:message config:config chatAudio:chatAudio imageArray:imageArray linkArray:linkArray];
//    CoreTextData *data = [self parseAttributedContent:content config:config imageArray:imageArray linkArray:linkArray];
////    data.imageArray = imageArray;
////    data.linkArray = linkArray;
//    return data;
//}

+ (NSAttributedString *)attributedStringWithMessage:(EBMessage *)message config:(CTFrameParserConfig*)config chatAudio:(EBChatAudio**)chatAudio imageArray:(NSMutableArray *)imageArray linkArray:(NSMutableArray *)linkArray
{
    //获取富文本信息内容
    NSArray* chats = message.chats;
    
    NSMutableArray* array = [NSMutableArray array];
    for (int idx = 0; idx<chats.count; idx++) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        
        EBChat* chatDot = chats[idx];
        switch (chatDot.type) {
            case EB_CHAT_ENTITY_TEXT:
            {
                NSString* text = ((EBChatText*)chatDot).text;
                //检测URL链接，并加入结果
                NSArray* txts = [self matchedUrlsInString:text];
                if (txts) {
                    [array addObjectsFromArray:txts];
                } else {
                    dict[@"type"] = @"txt";
                    dict[@"content"] = text;
                    
                    [array addObject:dict];
                }
            }
                break;
            case EB_CHAT_ENTITY_RESOURCE:
            {
                EBChatResource* resDot = (EBChatResource*)chatDot;
                EBEmotion* expression = resDot.expression;
                
                NSString* tag = [NSString stringWithFormat:@"expression_%llu", expression.resId];
                UIImage* image;
                if (expression.dynamicFilepath)
                    image = [UIImage imageWithContentsOfFile:expression.dynamicFilepath];
                else
                    image = [UIImage imageNamed:@"loading_emotion"];
                
                CoreTextImageData* obj = [[CoreTextImageData alloc] initWithImage:image UsingScaleSize:CGSizeMake(24, 24) forTag:tag];
                obj.imageType = CHAT_IMAGE_TYPE_RESOURCE;
                obj.descender = [[UIFont systemFontOfSize:config.fontSize] descender];
                
                dict[@"type"] = @"img";
                dict[@"name"] = tag;
                dict[@"imageType"] = @(obj.imageType);
//                dict[@"width"] = @(obj.scaleSize.width);
//                dict[@"height"] = @(obj.scaleSize.height);
                dict[@"object"] = obj;
                
                [array addObject:dict];
            }
                break;
            case EB_CHAT_ENTITY_IMAGE:
            {
                EBChatImage* imageDot = (EBChatImage*)chatDot;
                UIImage* image = imageDot.image;
                
                NSString* tag = [NSString stringWithFormat:@"image_%@", image];
                
                CoreTextImageData* obj = [[CoreTextImageData alloc] initWithImage:image forTag:tag];
                obj.imageType = CHAT_IMAGE_TYPE_COMMON;
                obj.descender = [[UIFont systemFontOfSize:config.fontSize] descender];
                
                dict[@"type"] = @"img";
                dict[@"name"] = tag;
                dict[@"imageType"] = @(obj.imageType);
//                dict[@"width"] = @(obj.scaleSize.width);
//                dict[@"height"] = @(obj.scaleSize.height);
                dict[@"object"] = obj;
                
                [array addObject:dict];
            }
                break;
            case EB_CHAT_ENTITY_AUDIO:
            {
                *chatAudio = (EBChatAudio*)chatDot;
                
                dict[@"type"] = @"txt";
                dict[@"content"] = @"[语音]";
            }
                break;
        }
    }
    
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    
    for (NSDictionary *dict in array) {
        NSString *type = dict[@"type"];
        if ([type isEqualToString:@"txt"]) {
            NSAttributedString *as = [self parseAttributedContentFromNSDictionary:dict config:config];
            [result appendAttributedString:as];
        } else if ([type isEqualToString:@"img"]) {
            // 创建 CoreTextImageData
            CoreTextImageData *imageData = dict[@"object"];
            imageData.name = dict[@"name"];
            imageData.position = [result length];
            [imageArray addObject:imageData];
            // 创建空白占位符，并且设置它的CTRunDelegate信息
            NSAttributedString *as = [self parseImageData:imageData config:config];
            [result appendAttributedString:as];
        } else if ([type isEqualToString:@"link"]) {
            NSUInteger startPos = result.length;
            NSMutableAttributedString *as = [self parseAttributedContentFromNSDictionary:dict config:config];
            
            [result appendAttributedString:as];
            
            // 创建 CoreTextLinkData
            NSUInteger length = result.length - startPos;
            NSRange linkRange = NSMakeRange(startPos, length);
            CoreTextLinkData *linkData = [[CoreTextLinkData alloc] init];
            linkData.title = dict[@"content"];
            linkData.url = dict[@"url"];
            linkData.range = linkRange;
            [linkArray addObject:linkData];
        }
    }
    return result;
}

+ (NSAttributedString *)parseImageData:(CoreTextImageData*)imageData config:(CTFrameParserConfig*)config
{
    //为图片设置CTRunDelegate,delegate决定留给图片的空间大小
    CTRunDelegateCallbacks imageCallbacks;
    imageCallbacks.version      = kCTRunDelegateVersion1;
    imageCallbacks.dealloc      = deallocCallback;
    imageCallbacks.getAscent    = ascentCallback;
    imageCallbacks.getDescent   = descentCallback;
    imageCallbacks.getWidth     = widthCallback;
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, (__bridge_retained void *)(imageData));
    
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:@" "];//空格用于给图片留位置
    [space addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:NSMakeRange(0, 1)];
    CFRelease(runDelegate);
    
    //设置图片唯一标识属性
//    [imageAttributedString addAttribute:CHAT_IMAGE_TAG_NAME value:tag range:NSMakeRange(0, 1)];
    
    //追加属性字符串
//    [attributedString appendAttributedString:imageAttributedString];
    
//    CTRunDelegateCallbacks callbacks;
//    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
//    callbacks.version = kCTRunDelegateVersion1;
//    callbacks.getAscent = ascentCallback;
//    callbacks.getDescent = descentCallback;
//    callbacks.getWidth = widthCallback;
////    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(dict));
//    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(imageData));
//
//    // 使用0xFFFC作为空白的占位符
//    unichar objectReplacementChar = 0xFFFC;
//    NSString * content = [NSString stringWithCharacters:&objectReplacementChar length:1];
//    NSDictionary * attributes = [self attributesWithConfig:config];
//    NSMutableAttributedString * space = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
//    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
//    CFRelease(delegate);
    
    return space;
}

+ (NSMutableAttributedString *)parseAttributedContentFromNSDictionary:(NSDictionary *)dict config:(CTFrameParserConfig*)config
{
    NSString *content = dict[@"content"];
    NSMutableDictionary *attributes = [self attributesWithConfig:config];
    
    // 设置颜色
    UIColor *color = [self colorFromTemplate:dict[@"color"]];
    if (color) {
        attributes[(id)kCTForegroundColorAttributeName] = color; //NSForegroundColorAttributeName不生效，BUG?
    }
    
    // 设置字体
    CGFloat fontSize = [dict[@"size"] floatValue];
    if (fontSize > 0) {
//        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attributes[NSFontAttributeName] = [UIFont systemFontOfSize:fontSize];
//        CFRelease(fontRef);
    }
    
    // 设置下划线
    BOOL underline = [dict[@"underline"] boolValue];
    if (underline) {
        attributes[NSUnderlineStyleAttributeName]= @1;
    }
    
    //设置换行模式和行间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.lineSpacing = config.lineSpace;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    // 关联点击链接
//    NSString* url = dict[@"url"];
//    if (url) {
//        attributes[NSLinkAttributeName] = [[NSURL alloc] initWithString:url];
//    }
    
    return [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
}

+ (UIColor *)colorFromTemplate:(NSString *)name
{
    if (!name)
        return nil;
    
    if ([name isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    } else if ([name isEqualToString:@"red"]) {
        return [UIColor redColor];
    } else if ([name isEqualToString:@"black"]) {
        return [UIColor blackColor];
    } else {
        return [UIColor colorWithHexString:name];
    }
}

+ (CoreTextData *)parseContent:(NSString *)content config:(CTFrameParserConfig*)config
{
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSAttributedString *contentString = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    return [self parseAttributedContent:contentString config:config imageArray:nil linkArray:nil];
}

+ (CoreTextData *)parseAttributedContent:(NSAttributedString *)content config:(CTFrameParserConfig*)config imageArray:(NSMutableArray *)imageArray linkArray:(NSMutableArray *)linkArray
{
    // 创建CTFramesetterRef实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    // 获得要缓制的区域的高度
    CGSize restrictSize = CGSizeMake(config.width, CHAT_CONTENT_MAX_HEIGHT);
//    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), nil, restrictSize, nil); //这个方法有BUG，不要用
    CGSize coreTextSize = [self suggestSizeFrameSizeWithFramesetter:framesetter maxSize:restrictSize];
//    CGFloat textHeight = coreTextSize.height;
    
    // 生成CTFrameRef实例
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter width:ceil(coreTextSize.width)+0 height:ceil(coreTextSize.height)+0];
    
    // 将生成好的CTFrameRef实例和计算好的缓制高度保存到CoreTextData实例中，最后返回CoreTextData实例
    CoreTextData *data = [[CoreTextData alloc] init];
    data.ctFramesetter  = framesetter;
    data.ctFrame        = frame;
//    data.height         = textHeight;
    data.size           = coreTextSize;
    data.content        = content;
    data.imageArray     = imageArray;
    data.linkArray      = linkArray;
    
    // 释放内存
//    CFRelease(frame);
//    CFRelease(framesetter);
    return data;
}

+ (CGSize)suggestSizeFrameSizeWithFramesetter:(CTFramesetterRef)ctFramesetter maxSize:(CGSize)maxSize
{
    //CGSize suggestSize =CTFramesetterSuggestFrameSizeWithConstraints(ctFramesetter,CFRangeMake(0, 0), NULL, maxSize, NULL); //该方法有BUG，别用
    
    //创建绘图路径并把设置矩形参数
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0.0, 0.0, maxSize.width, maxSize.height));
    
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, 0), path, NULL); //创建一个帧并在上下文执行绘制文本
    
    NSArray *lines = (__bridge NSArray *) CTFrameGetLines(ctFrame); //获取帧中所有行
    //    NSLog(@"line count = %i", lines.count);
    
    //获取各行的起始坐标
    CGPoint lineOrigins[lines.count];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    CGFloat maxWidth = 0.0;
    CGFloat totalHeight = 0.0;
    int i =0;
    //循环每一行找出最大宽度及总高度
    for(i=0; i<lines.count; i++) {
        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
        double width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        if(maxWidth < width)
            maxWidth = width;
        
        if(i == lines.count-1) { //最后一行
            totalHeight = maxSize.height - lineOrigins[i].y + descent;
        }
    }
    
    CFRelease(ctFrame);
    CFRelease(path);
    
    return CGSizeMake(maxWidth, totalHeight);
}

+ (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter width:(CGFloat)width height:(CGFloat)height
{
    
    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    CGPathAddRect(path, NULL, CGRectMake(0, 0, width, height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}

+ (NSString*)keyForMessage:(EBMessage*)message
{
    if (message.msgId)
        return [@(message.msgId) stringValue];
    if (message.tagId)
        return [@(message.tagId) stringValue];
    if (message.customField)
        return message.customField;
    return nil;
}

//检测URL链接并拆分模块
+ (NSArray*)matchedUrlsInString:(NSString*)string
{
    NSUInteger length = [string length];
    if (length==0)
        return nil;
    
    //匹配正则表达式
    NSError *error;
    //@"((http|ftp|https|file):\/\/([\w\-]+\.)+[\w\-]+(\/[\w\u4e00-\u9fa5\-\.\/?\@\%\!\&=\+\~\:\#\;\,]*)?)"
//    NSString* pattern = @"((http|ftp|https|file):\\/\\/([\\w\\-]+\\.)+[\\w\\-]+(\\/[\\w\\u4e00-\\u9fa5\\-\\.\\/?\\@\\%\\!\\&=\\+\\~\\:\\#\\;\\,]*)?)";
    NSString* pattern = @"((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray* checkingResults = [regex matchesInString:string options:0 range:NSMakeRange(0, length)];
    
    NSMutableArray* returnStrings = [[NSMutableArray alloc] init];
    
    if (checkingResults.count>0) {
        NSUInteger index = 0;
        NSUInteger i     = 0;
        NSRange range    = [checkingResults[i] range];
        
        do {
            if (range.location > index) { //普通字符串
                NSString* subStr = [string substringWithRange:NSMakeRange(index, range.location-index)];
                [returnStrings addObject:@{@"type":@"txt", @"content":subStr}];
                index = range.location;
            } else { //超链接
                NSString* subStr = [string substringWithRange:range];
                [returnStrings addObject:@{@"type":@"link", @"content":subStr, @"url":subStr, @"underline":@YES, @"color":@"#4670eb"}];
                
                i++;
                index = range.location+range.length;
                if (length-1 <= index) { //结束
                    break;
                }
                if (checkingResults.count>i)
                    range = [checkingResults[i] range];
                else {
                    subStr = [string substringWithRange:NSMakeRange(index, string.length-index)];
                    [returnStrings addObject:@{@"type":@"txt", @"content":subStr}];
                    break;
                }
            }
        } while (true);
        
    } else { //没有任何匹配结果，直接返回原字符串
        return @[@{@"type":@"txt", @"content":string}];
    }

    return returnStrings;
}

@end
