//
//  ImageViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 13-1-24.
//  Copyright (c) 2013年 zhong zf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage* image;

@end
