//
//  CoreTextData.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-11-15.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "CoreTextImageData.h"

@interface CoreTextData : NSObject

@property (assign, nonatomic) CTFrameRef ctFrame;
@property (assign, nonatomic) CTFramesetterRef ctFramesetter;
//@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGSize size;
@property (strong, nonatomic) NSArray * imageArray;
@property (strong, nonatomic) NSArray * linkArray;
@property (strong, nonatomic) NSAttributedString *content;

@end
