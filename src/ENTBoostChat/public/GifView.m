//
//  GifView.m
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "GifView.h"
#import <ImageIO/ImageIO.h>
#import <QuartzCore/CoreAnimation.h>

//获取各帧信息
void getFrameInfo(CFURLRef url, NSMutableArray *frames, NSMutableArray *delayTimes, CGFloat *totalTime,CGFloat *width, CGFloat *height)
{
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL(url, NULL);
    if (imageSource) {
        //获取帧数量
        size_t frameCount = CGImageSourceGetCount(imageSource);
        for (size_t i = 0; i < frameCount; ++i) {
            //获取一个帧实例
            CGImageRef frame = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            [frames addObject:(__bridge id)frame];
            CGImageRelease(frame);
            
            //获取帧信息
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL));
            //NSLog(@"kCGImagePropertyGIFDictionary %@", [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary]);
            
            //帧高度和宽度
            if (width && height) {
                *width = [[dict valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
                *height = [[dict valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
            }
            
            //kCGImagePropertyGIFDictionary中kCGImagePropertyGIFDelayTime，kCGImagePropertyGIFUnclampedDelayTime值是一样的
            NSDictionary *gifDict = [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
            [delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
            
            if (totalTime)
                *totalTime = *totalTime + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
        }
        
        CFRelease(imageSource);
    }
}

@interface GifView()
{
    NSMutableArray *_frames; //各帧对象列表
    NSMutableArray *_frameDelayTimes; //各帧播放时长
    
    CGFloat _totalTime; //秒
    CGFloat _width; //宽度
    CGFloat _height; //高度
}

@end

@implementation GifView

- (id)init
{
    if (self = [super init]) {
        self.repeatCount = FLT_MAX;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.repeatCount = FLT_MAX;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.repeatCount = FLT_MAX;
    }
    return self;
}

- (void)setFileURL:(NSURL*)fileURL
{
    if (!fileURL) {
        NSLog(@"fileURL is empty");
        return;
    }
        
    _frames = [[NSMutableArray alloc] init];
    _frameDelayTimes = [[NSMutableArray alloc] init];
    
    CGPoint center = self.center; //暂存当前视图中心点
    _width = 0;
    _height = 0;
    getFrameInfo((__bridge CFURLRef)fileURL, _frames, _frameDelayTimes, &_totalTime, &_width, &_height);
    self.center = center;
}

//+ (NSArray*)framesInGif:(NSURL *)fileURL
//{
//    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:3];
//    NSMutableArray *delays = [NSMutableArray arrayWithCapacity:3];
//    
//    getFrameInfo((__bridge CFURLRef)fileURL, frames, delays, NULL, NULL, NULL);
//    
//    return frames;
//}

- (void)startAnimation
{
    if (!_frames.count) {
        NSLog(@"frames is empty");
        return;
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    NSUInteger count = _frameDelayTimes.count;
    
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:count];
    CGFloat currentTime = 0;
    
    for (int i = 0; i < count; ++i) {
        [times addObject:[NSNumber numberWithFloat:(currentTime / _totalTime)]];
        currentTime += [[_frameDelayTimes objectAtIndex:i] floatValue];
    }
    [animation setKeyTimes:times];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; ++i) {
        [images addObject:[_frames objectAtIndex:i]];
    }
    
    [animation setValues:images];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    animation.duration = _totalTime;
    animation.delegate = (id <CAAnimationDelegate>)self;
    animation.repeatCount = self.repeatCount;
    
    [self.layer addAnimation:animation forKey:@"gifAnimation"];
}

- (void)stopAnimation
{
    [self.layer removeAllAnimations];
}

// remove contents when animation end
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.layer.contents = nil;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


@end


