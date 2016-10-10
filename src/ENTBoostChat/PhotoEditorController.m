//
//  PhotoEditorController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/12/25.
//  Copyright © 2015年 EB. All rights reserved.
//

#import "PhotoEditorController.h"
#import "PhotoMaskView.h"
#import "ButtonKit.h"

@interface PhotoEditorController () <PhotoMaskViewDelegate, UIScrollViewDelegate>
{
    CGFloat _photoWidth;
    CGFloat _photoHeight;
}
@property(nonatomic) CGRect pickingFieldRect;
@property(nonatomic) BOOL needAdjustScrollViewZoomScale;

@property(nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property(nonatomic, strong) IBOutlet UIImageView* imageView;
@property(nonatomic, strong) IBOutlet PhotoMaskView* maskView;

@end

@implementation PhotoEditorController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //导航栏左边按钮1
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    //右边按钮1
    self.navigationItem.rightBarButtonItem = [ButtonKit saveBarButtonItemWithTarget:self action:@selector(saveImage:)];
    
    //设置待编辑原图片
    self.imageView.image = self.originImage;
    //设置目标框大小
    _photoWidth = 200;
    _photoHeight = 200;
    CGSize size = self.view.bounds.size;
    self.maskView.widthGap  = size.width - _photoWidth;
    self.maskView.heightGap = size.height - _photoHeight;
    //其它设置
    self.maskView.delegate = self;
    self.maskView.maskType = PhotoMaskViewMaskTypeRectangle;
    self.pickingFieldRect = CGRectZero;
    self.needAdjustScrollViewZoomScale = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回上一级
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//获取图片实际剪裁区域
- (CGRect)convertClipRectToImage
{
    CGRect clipedRect = self.pickingFieldRect;
    CGFloat zoomScale = self.scrollView.zoomScale;
    clipedRect.size.width = clipedRect.size.width / zoomScale;
    clipedRect.size.height = clipedRect.size.height / zoomScale;
    clipedRect.origin.x = (self.scrollView.contentOffset.x + clipedRect.origin.x) / zoomScale;
    clipedRect.origin.y = (self.scrollView.contentOffset.y + clipedRect.origin.y) / zoomScale;
    return clipedRect;
}

// See here for detail:
// http://stackoverflow.com/questions/8915630/ios-uiimageview-how-to-handle-uiimage-image-orientation/15039609#15039609
- (UIImage *)fixrotation:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

//执行剪裁并保存图片
- (IBAction)saveImage:(id)sender
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self fixrotation:self.originImage].CGImage, [self convertClipRectToImage]);
    UIImage *clipedImage = [UIImage imageWithCGImage:imageRef];
    
    if ([self.delegate respondsToSelector:@selector(photoEditorController:croppedImage:)])
        [self.delegate photoEditorController:self croppedImage:clipedImage];
    
    [self goBack];
//    NSArray *iInfos = [[TTDataSourceManager sharedInstance] searchManagedObjectWithEntityName:NSStringFromClass([TTI class])];
//    if (iInfos.count > 0) {
//        TTI *i = iInfos[0];
//        i.headImage = clipedImage;
//        [[TTDataSourceManager sharedInstance] saveManagedObjectContext];
//    }
//    
//    NSInteger currentIndex = [self.navigationController.viewControllers indexOfObject:self];
//    [self.navigationController popToViewController:self.navigationController.viewControllers[currentIndex - 2] animated:YES];
}

#pragma mark - TTPhotoMaskViewDelegate

- (void)pickingFieldRectChangedTo:(CGRect)rect
{
    self.pickingFieldRect = rect;
    CGFloat topGap = rect.origin.y;
    CGFloat leftGap = rect.origin.x;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(topGap, leftGap, topGap, leftGap);
    //step 1: setup contentInset
    self.scrollView.contentInset = UIEdgeInsetsMake(topGap, leftGap, topGap, leftGap);
    
    CGFloat maskCircleWidth = rect.size.width;
    CGSize imageSize = self.originImage.size;
    //setp 2: setup contentSize:
    self.scrollView.contentSize = imageSize;
    CGFloat minimunZoomScale = imageSize.width < imageSize.height ? maskCircleWidth / imageSize.width : maskCircleWidth / imageSize.height;
    CGFloat maximumZoomScale = 5;
    //step 3: setup minimum and maximum zoomScale
    self.scrollView.minimumZoomScale = minimunZoomScale;
    self.scrollView.maximumZoomScale = maximumZoomScale;
    self.scrollView.zoomScale = self.scrollView.zoomScale < minimunZoomScale ? minimunZoomScale : self.scrollView.zoomScale;
    
    //step 4: setup current zoom scale if needed:
    if (self.needAdjustScrollViewZoomScale) {
        CGFloat temp = self.view.bounds.size.width < self.view.bounds.size.height ? self.view.bounds.size.width : self.view.bounds.size.height;
        minimunZoomScale = imageSize.width < imageSize.height ? temp / imageSize.width : temp / imageSize.height;
        self.scrollView.zoomScale = minimunZoomScale;
        self.needAdjustScrollViewZoomScale = NO;
        
        //滚动到中间
        CGSize size = self.imageView.frame.size;
        CGPoint point = [self.scrollView contentOffset];
        [self.scrollView setContentOffset:CGPointMake((point.x + (size.width-_photoWidth)/2), (point.y + (size.height-_photoHeight)/2)) animated:YES];
    }
}

#pragma mark - UIContentContainer protocol

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self.maskView setNeedsDisplay];
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
