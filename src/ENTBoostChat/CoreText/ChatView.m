//
//  ChatView.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-15.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "ChatView.h"
#import "CoreTextImageData.h"
#import "ImageViewController.h"
#import "CTFrameParserConfig.h"
#import "CoreTextData.h"
#import "CoreTextUtils.h"
#import "ENTBoost+Utility.h"

typedef enum ChatViewState : NSInteger {
    ChatViewStateNormal,       // 普通状态
//    ChatViewStateTouching,     // 正在按下，需要弹出放大镜
//    ChatViewStateSelecting     // 选中了一些文本，需要弹出复制菜单
} ChatViewState;

@interface ChatView ()
{

}

@property (nonatomic) ChatViewState state;

@end

@implementation ChatView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupEvents];
    }
    return self;
}

//- (id)initWithCTFramesetterRef:(CTFramesetterRef)ctFramesetter andFrame:(CGRect)frame
- (id)initWithCoreTextData:(CoreTextData*)data frame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.data = data;
        [self setupEvents];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (!self.data)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context); //保存上下文

//    //转换被反转的坐标系
//    CGContextSetTextMatrix(context, CGAffineTransformIdentity);//设置字形变换矩阵为CGAffineTransformIdentity，也就是说每一个字形都不做图形变换
//    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, rect.size.height);
//    CGContextConcatCTM(context, flipVertical);//将当前context的坐标系进行flip
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
//    if (self.state == CTDisplayViewStateTouching || self.state == CTDisplayViewStateSelecting) {
//        [self drawSelectionArea];
//        [self drawAnchors];
//    }
    
    CTFrameDraw(self.data.ctFrame, context);
    
    for (CoreTextImageData * imageData in self.data.imageArray) {
//        UIImage *image = [UIImage imageNamed:imageData.name];
        if (imageData.scaleImage) {
            CGContextDrawImage(context, imageData.imagePosition, imageData.image.CGImage);//imageData.scaleImage.CGImage);
        }
    }
    
    CGContextRestoreGState(context);
}

//- (void)drawRect:(CGRect)rect
//{
////    NSLog(@"drawRect %@", NSStringFromCGRect(rect));
////    if(!self.attributedString) {
////        NSLog(@"no attributedString");
////        return;
////    }
//
////    if(!self.ctFramesetter) {
////        NSLog(@"no ctFramesetter");
////        return;
////    }
//    
//    //保存上下文
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//    
//    //转换被反转的坐标系
//    CGContextSetTextMatrix(context, CGAffineTransformIdentity);//设置字形变换矩阵为CGAffineTransformIdentity，也就是说每一个字形都不做图形变换
//    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, rect.size.height);
//    CGContextConcatCTM(context, flipVertical);//将当前context的坐标系进行flip
//
//    //创建帧管理器
////    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFMutableAttributedStringRef)self.data.content);
//    CTFramesetterRef ctFramesetter = self.data.ctFramesetter;
////    NSAttributedString* testStr = [[NSAttributedString alloc] initWithString:@"1" attributes:nil];
////    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFMutableAttributedStringRef)self.data.content);
//    
//    //CGSize suggestedSize =CTFramesetterSuggestFrameSizeWithConstraints(ctFramesetter,CFRangeMake(0, 0), NULL,CGSizeMake(CONTENT_MAX_HEIGHT, 100), NULL);
//    
//    //创建绘图路径并把设置矩形参数
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGRect bounds = CGRectMake(0.0, 0.0, rect.size.width, rect.size.height);
//    CGPathAddRect(path, NULL, bounds);
//    
//    //创建一个帧并在上下文执行绘制文本
//    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, 0), path, NULL);
////    self.ctFrame = ctFrame;
////    CFRelease(ctFrame);
////    CFRange frameRange = CTFrameGetVisibleStringRange(self.ctFrame);
////    NSLog(@"frame location:%li, length:%li", frameRange.location, frameRange.length);
////    CTFrameRef ctFrame = self.data.ctFrame;
//    
//    CTFrameDraw(ctFrame, context);
//    
////    //获取帧中所有行
////    CFArrayRef lines = CTFrameGetLines(ctFrame);
////    
////    //获取行数
////    CFIndex lineCount = CFArrayGetCount(lines);
////    
////    //获取各行的起始坐标
////    CGPoint lineOrigins[lineCount];
////    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
//////    NSLog(@"line count = %ld", lineCount);
////    
////    //循环处理每行数据，检查是否需要绘制图片
////    for (int i = 0; i < lineCount; i++) {
////        //获取单行
////        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
////        
////        //当前行起点坐标
////        CGPoint lineOrigin = lineOrigins[i];
////        
////        //获取单行的印刷(真实绘制)大小信息(宽度、高度、左间距等)
//////        CGFloat lineAscent;
//////        CGFloat lineDescent;
//////        CGFloat lineLeading;
//////        double lineWidth = CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
//////        NSLog(@"line width = %f, ascent = %f, descent = %f, leading = %f", lineWidth, lineAscent, lineDescent, lineLeading);
////        
////        //获取单行中的CTRun实例列表
////        CFArrayRef runs = CTLineGetGlyphRuns(line);
////        CFIndex runCount = CFArrayGetCount(runs);
////        //NSLog(@"ctRun count = %ld", runCount);
////        
////        //循环检查每一个CTRun实例
////        for (int j = 0; j < runCount; j++) {
////            //获取一个CTRun实例
////            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
////            
////            //获取一个CTRun的印刷(真实绘制)大小信息(宽度、高度、左间距等)
////            CGFloat runAscent;
////            CGFloat runDescent;
////            CGFloat runLeading;
////            double runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, &runLeading);
////            
////            //获取属性字典
////            NSDictionary* attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
////            NSString *imageTag = [attributes objectForKey:CHAT_IMAGE_TAG_NAME];
////            
////            //判断是否图片并执行渲染
////            if (imageTag) {
////                CoreTextImageData* chatImage = [[ChatRenderingCache sharedCache] chatImageForTag:imageTag];
////                if (chatImage) {
////                    //计算当前CTRun的维度信息(起点、宽度、高度等)
////                    CGRect runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runWidth, runAscent + runDescent);
////                    
////                    CGRect imageDrawRect = CGRectMake(runRect.origin.x, runRect.origin.y, runRect.size.width, runRect.size.height);
////                    CGContextDrawImage(context, imageDrawRect, chatImage.scaleImage.CGImage);
////                }
////            }
////        }
////    }
//    
//    for (CoreTextImageData * imageData in self.data.imageArray) {
//        if (imageData.scaleImage) {
//            CGContextDrawImage(context, imageData.imagePosition, imageData.scaleImage.CGImage);
//        }
//    }
//    
//    CFRelease(ctFrame);
//    CFRelease(path);
////    CFRelease(ctFramesetter);
//    
//    CGContextRestoreGState(context);
//}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if(!self.ctFrame)
//        return;
//    
//    //获取UITouch对象
//    UITouch *touch = [touches anyObject];
//    //获取触摸点击当前view的坐标位置
//    CGPoint location = [touch locationInView:self];
//    //获取每一行
//    CFArrayRef lines = CTFrameGetLines(self.ctFrame);
//    CGPoint origins[CFArrayGetCount(lines)];
//    //获取每行的原点坐标
//    CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), origins);
//    CTLineRef line = NULL;
//    CGPoint lineOrigin = CGPointZero;
//    for (int i= 0; i < CFArrayGetCount(lines); i++)
//    {
//        CGPoint origin = origins[i];
//        CGPathRef path = CTFrameGetPath(self.ctFrame);
//        //获取整个CTFrame的大小
//        CGRect rect = CGPathGetBoundingBox(path);
//        //坐标转换，把每行的原点坐标转换为uiview的坐标体系
//        CGFloat y = rect.origin.y + rect.size.height - origin.y;
//        //判断点击的位置处于那一行范围内
//        if ((location.y <= y) && (location.x >= origin.x))
//        {
//            line = CFArrayGetValueAtIndex(lines, i);
//            lineOrigin = origin;
//            break;
//        }
//    }
//    
//    if(!line)
//        return;
//    
//    location.x -= lineOrigin.x;
//    //获取点击位置所处的字符位置，就是相当于点击了第几个字符
//    CFIndex index = CTLineGetStringIndexForPosition(line, location);
//    
//    //遍历所点击行中的所有CTRun，匹配被点击的图片
//    CFArrayRef runs = CTLineGetGlyphRuns(line);
//    CFIndex runCount = CFArrayGetCount(runs);
//    for (int j = 0; j < runCount; j++) {
//        CTRunRef run = CFArrayGetValueAtIndex(runs, j);
//        NSDictionary* attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
//        NSString *imageTag = [attributes objectForKey:CHAT_IMAGE_TAG_NAME];
//        if (imageTag) {
//            CFRange range = CTRunGetStringRange(run);
////            NSLog(@"range: location = %li, length = %li", range.location, range.length);
////            NSLog(@"index:%ld",index);
//            
//            //判断点击的字符是否在需要处理点击事件的字符串范围内
//            if (index >= range.location && index <= range.location + range.length) {
//                CoreTextImageData* chatImage = [[ChatRenderingCache sharedCache] chatImageForTag:imageTag];
//                if (chatImage) {
//                    if (chatImage.imageType == CHAT_IMAGE_TYPE_COMMON) { //普通图片
////                        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"click event" message:@"1111" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
////                        [alert show];
//                        if ([self.delegate respondsToSelector:@selector(chatImageClick:)]) {
//                            [self.delegate chatImageClick:chatImage];
//                        }
//                    }
//                }
//                break;
//            }
//        }
//    }
//}

#pragma mark - Events
//设置手势事件
- (void)setupEvents
{
    //单击检测
    UITapGestureRecognizer * singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userSingleTapGestureDetected:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [self addGestureRecognizer:singleTapGestureRecognizer];
    
    //双击检测
    UITapGestureRecognizer * doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDoubleTapGestureDetected:)];
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTapGestureRecognizer];
    
    //这行很关键，只有当没有检测到doubleTapGestureRecognizer 或者 检测doubleTapGestureRecognizer失败，singleTapGestureRecognizer才有效
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    
    //长按检测
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(userLongPressedGuestureDetected:)];
    [self addGestureRecognizer:longPressRecognizer];
    
    //滑动检测
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userPanGuestureDetected:)];
    [self addGestureRecognizer:panRecognizer];
    
    self.userInteractionEnabled = YES;
}

//处理点击事件
- (void)userSingleTapGestureDetected:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    if (self.state == ChatViewStateNormal) {
        //判断点击图片
        for (CoreTextImageData * imageData in self.data.imageArray) {
            // 翻转坐标系，因为imageData中的坐标是CoreText的坐标系
            CGRect imageRect = imageData.imagePosition;
            CGPoint imagePosition = imageRect.origin;
            imagePosition.y = self.bounds.size.height - imageRect.origin.y - imageRect.size.height;
            CGRect rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
            // 检测点击位置 Point 是否在rect之内
            if (CGRectContainsPoint(rect, point)) {
                //回调事件
                if ([self.delegate respondsToSelector:@selector(chatView:imageTaped:)]) {
                    [self.delegate chatView:self imageTaped:imageData];
                };
                return;
            }
        }
        
        //判断点击链接
        CoreTextLinkData *linkData = [CoreTextUtils touchLinkInView:self atPoint:point data:self.data];
        if (linkData) {
            //回调事件
            if ([self.delegate respondsToSelector:@selector(chatView:linkTaped:)]) {
                [self.delegate chatView:self linkTaped:linkData];
            };
            return;
        }
    } else {
        self.state = ChatViewStateNormal;
    }
}

//处理双击事件
- (void)userDoubleTapGestureDetected:(UITapGestureRecognizer *)recognizer
{
    //回调事件
    if ([self.delegate respondsToSelector:@selector(chatView:doubleTaped:data:)]) {
        [self.delegate chatView:self doubleTaped:recognizer data:nil];
    };
}

//处理长按事件
- (void)userLongPressedGuestureDetected:(UILongPressGestureRecognizer *)recognizer
{
//    CGPoint point = [recognizer locationInView:self];
//    debugMethod();
//    debugLog(@"state = %@", @(recognizer.state));
//    debugLog(@"point = %@", NSStringFromCGPoint(point));
//    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
//        CFIndex index = [CoreTextUtils touchContentOffsetInView:self atPoint:point data:self.data];
//        if (index != -1 && index < self.data.content.length) {
//            _selectionStartPosition = index;
//            _selectionEndPosition = index + 2;
//        }
//        self.magnifierView.touchPoint = point;
//        self.state = ChatViewStateTouching;
//    } else {
//        if (_selectionStartPosition >= 0 && _selectionEndPosition <= self.data.content.length) {
//            self.state = ChatViewStateSelecting;
//            [self showMenuController];
//        } else {
//            self.state = ChatStateNormal;
//        }
//    }
//    if (recognizer.state == UIGestureRecognizerStateEnded) {
    if ([self.delegate respondsToSelector:@selector(chatView:longPressed:data:)]) {
        [self.delegate chatView:self longPressed:recognizer data:nil];
    }
//    }
}

//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
//    debugMethod();
//    if (action == @selector(cut:) || action == @selector(copy:) || action == @selector(paste:) || action == @selector(selectAll:)) {
//        return YES;
//    }
//    return NO;
//}

//处理滑动事件
- (void)userPanGuestureDetected:(UIPanGestureRecognizer *)recognizer
{
//    if (self.state == ChatViewStateNormal) {
//        return;
//    }
//    CGPoint point = [recognizer locationInView:self];
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        if (_leftSelectionAnchor && CGRectContainsPoint(CGRectInset(_leftSelectionAnchor.frame, -25, -6), point)) {
//            debugLog(@"try to move left anchor");
//            _leftSelectionAnchor.tag = ANCHOR_TARGET_TAG;
//            [self hideMenuController];
//        } else if (_rightSelectionAnchor && CGRectContainsPoint(CGRectInset(_rightSelectionAnchor.frame, -25, -6), point)) {
//            debugLog(@"try to move right anchor");
//            _rightSelectionAnchor.tag = ANCHOR_TARGET_TAG;
//            [self hideMenuController];
//        }
//    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
//        CFIndex index = [CoreTextUtils touchContentOffsetInView:self atPoint:point data:self.data];
//        if (index == -1) {
//            return;
//        }
//        if (_leftSelectionAnchor.tag == ANCHOR_TARGET_TAG && index < _selectionEndPosition) {
//            debugLog(@"change start position to %ld", index);
//            _selectionStartPosition = index;
//            self.magnifierView.touchPoint = point;
//            [self hideMenuController];
//        } else if (_rightSelectionAnchor.tag == ANCHOR_TARGET_TAG && index > _selectionStartPosition) {
//            debugLog(@"change end position to %ld", index);
//            _selectionEndPosition = index;
//            self.magnifierView.touchPoint = point;
//            [self hideMenuController];
//        }
//        
//    } else if (recognizer.state == UIGestureRecognizerStateEnded ||
//               recognizer.state == UIGestureRecognizerStateCancelled) {
//        debugLog(@"end move");
//        _leftSelectionAnchor.tag = 0;
//        _rightSelectionAnchor.tag = 0;
//        [self removeMaginfierView];
//        [self showMenuController];
//    }
//    [self setNeedsDisplay];
}

@end

