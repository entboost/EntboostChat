//
//  TTPhotoMaskView.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/12/25.
//  Copyright © 2015年 EB. All rights reserved.
//

#import "PhotoMaskView.h"

@interface PhotoMaskView ()

@end


@implementation PhotoMaskView

- (void)drawRect:(CGRect)rect
{
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGFloat pickingFieldWidth = width < height ? (width - self.widthGap) : (height - self.heightGap);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(contextRef);
    CGContextSetRGBFillColor(contextRef, 0, 0, 0, 0.35);
    CGContextSetLineWidth(contextRef, 3);
    self.pickingFieldRect = CGRectMake((width - pickingFieldWidth) / 2, (height - pickingFieldWidth) / 2, pickingFieldWidth, pickingFieldWidth);
    UIBezierPath *pickingFieldPath = [self pickingFieldShapePathForType:self.maskType];
    UIBezierPath *bezierPathRect = [UIBezierPath bezierPathWithRect:rect];
    [bezierPathRect appendPath:pickingFieldPath];
    bezierPathRect.usesEvenOddFillRule = YES;
    [bezierPathRect fill];
    CGContextSetLineWidth(contextRef, 2);
    CGContextSetRGBStrokeColor(contextRef, 255, 255, 255, 1);
    CGFloat dash[2] = {4,4};
    [pickingFieldPath setLineDash:dash count:2 phase:0];
    [pickingFieldPath stroke];
    CGContextRestoreGState(contextRef);
    self.layer.contentsGravity = kCAGravityCenter;
    
    if ([self.delegate respondsToSelector:@selector(pickingFieldRectChangedTo:)]) {
        [self.delegate pickingFieldRectChangedTo:self.pickingFieldRect];
    }
}

- (UIBezierPath *)pickingFieldShapePathForType:(PhotoMaskViewMaskType)type
{
    switch (self.maskType) {
        case PhotoMaskViewMaskTypeCircle:
            return [UIBezierPath bezierPathWithOvalInRect:self.pickingFieldRect];
            break;
            
        case PhotoMaskViewMaskTypeRectangle:
            return [UIBezierPath bezierPathWithRect:self.pickingFieldRect];
            break;
            
        default:
            break;
    }
}

@end
