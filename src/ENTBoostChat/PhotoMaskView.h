//
//  TTPhotoMaskView.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/12/25.
//  Copyright © 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PhotoMaskViewMaskTypeCircle,
    PhotoMaskViewMaskTypeRectangle,
} PhotoMaskViewMaskType;

@protocol PhotoMaskViewDelegate <NSObject>

@optional
- (void)pickingFieldRectChangedTo:(CGRect) rect;

@end


@interface PhotoMaskView : UIView

@property (nonatomic) CGFloat widthGap;
@property (nonatomic) CGFloat heightGap;

@property (nonatomic) CGRect pickingFieldRect;
@property (nonatomic) PhotoMaskViewMaskType maskType;
@property (nonatomic, weak) id<PhotoMaskViewDelegate> delegate;

@end
