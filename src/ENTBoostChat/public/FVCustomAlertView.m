//
//  FVCustomAlertView.m
//  FVCustomAlertView
//
//  Created by Francis Visoiu Mistrih on 13/07/2014.
//  Copyright (c) 2014 Francis Visoiu Mistrih. All rights reserved.
//

#import "FVCustomAlertView.h"
#import "GifView.h"

static const NSInteger kInsetValue = 6;
static const NSUInteger kFinalViewTag = 1337;
static const NSUInteger kAlertViewTag = 1338;
static const NSUInteger kContentViewTag = 1339;
static const CGFloat kFadeOutDuration = 0.5f;
static const CGFloat kActivityIndicatorSize = 50;
static const CGFloat kOtherIconsSize = 30;

@interface FVCustomAlertView ()

+ (NSArray *)setupCustomActivityIndicator;
+ (UIView *)contentViewFromType:(FVAlertType)type;
+ (void)fadeOutView:(UIView *)view completion:(void (^)(BOOL finished))completion;
+ (void)hideAlertByTap:(UITapGestureRecognizer *)sender;

@end

@implementation FVCustomAlertView

+ (void)showAlertOnView:(UIView *)view
              withTitle:(NSString *)title
             titleColor:(UIColor *)titleColor
                  width:(CGFloat)width
                 height:(CGFloat)height
        backgroundImage:(UIImage *)backgroundImage
        backgroundColor:(UIColor *)backgroundColor
           cornerRadius:(CGFloat)cornerRadius
            shadowAlpha:(CGFloat)shadowAlpha
                  alpha:(CGFloat)alpha
            contentView:(UIView *)contentView
                   type:(FVAlertType)type
{
    if ([view viewWithTag:kFinalViewTag]) {
        //don't allow 2 alerts on the same view
        NSLog(@"Can't add two FVCustomAlertViews on the same view. Hide the current view first.");
        return;
    }

    //get window size and position
    CGRect windowRect = [[UIScreen mainScreen] bounds];

    //create the final view with a special tag
    UIView *resultView = [[UIView alloc] initWithFrame:windowRect];
    resultView.tag = kFinalViewTag; //set tag to retrieve later

    //create shadow view by adding a black background with custom opacity
    UIView *shadowView = [[UIView alloc] initWithFrame:windowRect];
    shadowView.backgroundColor = [UIColor blackColor];
    shadowView.alpha = shadowAlpha;
    [resultView addSubview:shadowView];

    //create the main alert view centered
    //with custom width and height
    //and custom background
    //and custom corner radius
    //and custom opacity
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(windowRect.size.width/2 - width/2,
                                                                 windowRect.size.height/2 - height/2,
                                                                 width, height)];
    alertView.tag = kAlertViewTag; //set tag to retrieve later

    //set background color
    //if a background image is used, use the image instead.
    alertView.backgroundColor = backgroundColor;
    if (backgroundImage) {
        alertView.backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundImage];
    }
    alertView.layer.cornerRadius = cornerRadius;
    alertView.alpha = alpha;

    //create the title label centered with multiple lines
    //and custom color
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = titleColor;
    titleLabel.backgroundColor = [UIColor clearColor];

    //set the number of lines to 0 (unlimited)
    //set a maximum size to the label
    //then get the size that fits the maximum size
    titleLabel.numberOfLines = 0;
    CGSize requiredSize = [titleLabel sizeThatFits:CGSizeMake(width - kInsetValue, height - kInsetValue)];
    titleLabel.frame = CGRectMake(width/2 - requiredSize.width / 2, kInsetValue, requiredSize.width, requiredSize.height);
    [alertView addSubview:titleLabel];

    //check wether the alert is of custom type or not
    //if it is, set the custom view
    UIView *content = type == FVAlertTypeCustom ? contentView : [self contentViewFromType:type];

    content.frame = CGRectApplyAffineTransform(content.frame, CGAffineTransformMakeTranslation(width/2 - content.frame.size.width/2, titleLabel.frame.origin.y + titleLabel.frame.size.height + kInsetValue));
    content.tag = kContentViewTag;

    [alertView addSubview:content];

    [resultView addSubview:alertView];

//    //tap the alert view to hide and remove it from the superview
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:[FVCustomAlertView class] action:@selector(hideAlertByTap:)];
//    tapGesture.numberOfTapsRequired = 1;
//    tapGesture.numberOfTouchesRequired = 1;
//    [resultView addGestureRecognizer:tapGesture];

    [view addSubview:resultView];
}

+ (void)showDefaultLoadingAlertOnView:(UIView *)view withTitle:(NSString *)title {
    [self showAlertOnView:view
                withTitle:title
               titleColor:[UIColor whiteColor]
                    width:100.0
                   height:100.0
          backgroundImage:nil
          backgroundColor:[UIColor blackColor]
             cornerRadius:10.0
              shadowAlpha:0.1
                    alpha:0.8
              contentView:nil
                     type:FVAlertTypeLoading];
}

+ (void)showDefaultDoneAlertOnView:(UIView *)view withTitle:(NSString *)title {
    [self showAlertOnView:view
                withTitle:title
               titleColor:[UIColor whiteColor]
                    width:100.0
                   height:100.0
          backgroundImage:nil
          backgroundColor:[UIColor blackColor]
             cornerRadius:10.0
              shadowAlpha:0.1
                    alpha:0.8
              contentView:nil
                     type:FVAlertTypeDone];
}

+ (void)showDefaultErrorAlertOnView:(UIView *)view withTitle:(NSString *)title {
    [self showAlertOnView:view
                withTitle:title
               titleColor:[UIColor whiteColor]
                    width:100.0
                   height:100.0
          backgroundImage:nil
          backgroundColor:[UIColor blackColor]
             cornerRadius:10.0
              shadowAlpha:0.1
                    alpha:0.8
              contentView:nil
                     type:FVAlertTypeError];
}

+ (void)showDefaultWarningAlertOnView:(UIView *)view withTitle:(NSString *)title {
    [self showAlertOnView:view
                withTitle:title
               titleColor:[UIColor whiteColor]
                    width:100.0
                   height:100.0
          backgroundImage:nil
          backgroundColor:[UIColor blackColor]
             cornerRadius:10.0
              shadowAlpha:0.1
                    alpha:0.8
              contentView:nil
                     type:FVAlertTypeWarning];
}

+ (NSArray *)setupCustomActivityIndicator {
    NSMutableArray *array = [NSMutableArray array];
    //iterate through all the images and add it to the array for the animation
    for (int i = 1; i <= 20; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i]];
        [array addObject:image];
    }
    return array;
}

+ (UIView *)contentViewFromType:(FVAlertType)type {
    if (type==FVAlertTypeLoading) {
        GifView* content = [[GifView alloc] init];
        content.frame = CGRectMake(0, 0, kActivityIndicatorSize, kActivityIndicatorSize);
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"loading_alert" withExtension:@"gif"];
        [content setFileURL:fileUrl];
        [content startAnimation];
//        content.animationDuration = 0.7;
//        content.animationImages = [self setupCustomActivityIndicator];
//        [content startAnimating];

        
        return content;
    } else {
        UIImageView *content = [[UIImageView alloc] init];
        
        switch (type) {
            case FVAlertTypeDone:
            {
                content.frame = CGRectMake(0, kInsetValue, kOtherIconsSize, kOtherIconsSize);
                content.image = [UIImage imageNamed:@"checkmark"];
            }
                break;
            case FVAlertTypeError:
            {
                content.frame = CGRectMake(0, kInsetValue, kOtherIconsSize, kOtherIconsSize);
                content.image = [UIImage imageNamed:@"cross"];
            }
                break;
            case FVAlertTypeWarning:
            {
                content.frame = CGRectMake(0, kInsetValue, kOtherIconsSize, kOtherIconsSize);
                content.image = [UIImage imageNamed:@"warning"];
            }
                break;
            default:
                //FVAlertTypeCustom never reached
                break;
        }
        return content;
    }
}

+ (void)fadeOutView:(UIView *)view completion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:kFadeOutDuration
                          delay:0.3
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [view setAlpha:0.0];
                     }
                     completion:completion];
}

+ (void)hideAlertFromView:(UIView *)view fading:(BOOL)fading {
    __weak typeof(self) weakSelf = self;
    UIView* finalView = [view viewWithTag:kFinalViewTag];
    if (fading) {
        [self fadeOutView:finalView completion:^(BOOL finished) {
            id safeSelf = weakSelf;
            [safeSelf hideFinalView:finalView];
        }];
    } else {
        [self hideFinalView:finalView];
    }
}

+ (void)hideAlertByTap:(UITapGestureRecognizer *)sender {
    [self hideAlertFromView:sender.view fading:YES];
}

/**隐藏提示框
 * @param finalView 提示框视图
 */
+ (void)hideFinalView:(UIView*)finalView
{
    [finalView removeFromSuperview];
    UIView* contentView = [finalView viewWithTag:kContentViewTag];
    if ([contentView isMemberOfClass:[UIImageView class]]) {
        [(UIImageView*)contentView stopAnimating];
    } else if ([contentView isMemberOfClass:[GifView class]]) {
        [(GifView*)contentView stopAnimation];
    }
}

@end
