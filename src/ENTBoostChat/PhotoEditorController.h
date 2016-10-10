//
//  PhotoEditorController.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/12/25.
//  Copyright © 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoEditorControllerDelegate;


@interface PhotoEditorController : UIViewController

@property(nonatomic, strong) id<PhotoEditorControllerDelegate> delegate; //回调代理
@property(nonatomic, strong) UIImage* originImage; //原始图片

@end

@protocol PhotoEditorControllerDelegate <NSObject>

@optional
///保存裁剪图片事件
- (void)photoEditorController:(PhotoEditorController*)viewController croppedImage:(UIImage*)croppedImage;

@end