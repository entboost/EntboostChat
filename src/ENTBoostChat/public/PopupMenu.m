//
//  PopupMenu.m
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "PopupMenu.h"
#import "ENTBoostChat.h"
#import <QuartzCore/QuartzCore.h>

@interface PopupMenuView : UIView

@property(nonatomic) CGFloat arrowSize; //小三角尺寸
@property(nonatomic) CGFloat cornerRadius; //圆角弧长
@property(nonatomic, strong) UIFont *titleFont; //标题字体
@property(nonatomic, strong) UIColor *topBackgroundColor; //上层背景颜色
@property(nonatomic) BOOL hiddenSeparator; //隐藏分隔线
@property(nonatomic) BOOL horizontalRank; //子菜单项是否水平排列

- (void)dismissMenu:(BOOL) animated;

@end

#pragma mark - PopupMenuOverlay

@interface PopupMenuOverlay : UIView
@end

@implementation PopupMenuOverlay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *touched = [[touches anyObject] view];
    if (touched == self) {
        for (UIView *v in self.subviews) {
            if ([v isKindOfClass:[PopupMenuView class]]) {
                PopupMenuView* pView = (PopupMenuView*)v;
                if ([pView respondsToSelector:@selector(dismissMenu:)]) {
                    [pView performSelector:@selector(dismissMenu:) withObject:@(YES)];
                }
            }
        }
    }
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pragma mark - PopupMenuItem

@implementation PopupMenuItem

+ (instancetype) menuItem:(NSString *) title image:(UIImage *) image target:(id)target action:(SEL) action tag:(uint64_t)tag
{
    return [[PopupMenuItem alloc] initWithTitle:title image:image target:target action:action tag:tag];
}

- (id)initWithTitle:(NSString *) title image:(UIImage *) image target:(id)target action:(SEL) action tag:(uint64_t)tag
{
    NSParameterAssert(title.length || image);
    
    self = [super init];
    if (self) {
        _title = title;
        _image = image;
        _target = target;
        _action = action;
        _tag = tag;
    }
    return self;
}

- (BOOL) enabled
{
    return _target != nil && _action != NULL;
}

- (void)performAction
{
    __strong id target = self.target;
    if (target && [target respondsToSelector:_action]) {
        [target performSelectorOnMainThread:_action withObject:self waitUntilDone:YES];
    }
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@ #%p %@>", [self class], self, _title];
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pragma mark - PopupMenuView

typedef enum {
    PopupMenuViewArrowDirectionNone,
    PopupMenuViewArrowDirectionUp,
    PopupMenuViewArrowDirectionDown,
    PopupMenuViewArrowDirectionLeft,
    PopupMenuViewArrowDirectionRight
} PopupMenuViewArrowDirection;

@implementation PopupMenuView {

    PopupMenuViewArrowDirection _arrowDirection;
    CGFloat                     _arrowPosition;
    UIView                      *_contentView;
    NSArray                     *_menuItems;
    SEL                         _cancelAction;  //菜单关闭时调用的方法
    id                          _target;        //回调目标对象
}

- (id)initWithArrowSize:(CGFloat)arrowSize cornerRadius:(CGFloat)cornerRadius titleFont:(UIFont*)titleFont topBackgroundColor:(UIColor*)topBackgroundColor hiddenSeparator:(BOOL)hiddenSeparator horizontalRank:(BOOL)horizontalRank
{
    self = [super initWithFrame:CGRectZero];    
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        self.topBackgroundColor = topBackgroundColor;
        self.opaque = YES;
        self.alpha = 0;
        self.clipsToBounds = NO;
        
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(2, 2);
        self.layer.shadowRadius = 2;
        
        self.arrowSize = arrowSize;
        self.cornerRadius = cornerRadius;
        self.titleFont = titleFont;
        self.hiddenSeparator = hiddenSeparator;
        self.horizontalRank = horizontalRank;
    }
    
    return self;
}

- (void) setupFrameInView:(UIView *)view fromRect:(CGRect)fromRect
{
    const CGSize contentSize = _contentView.frame.size;
    
    const CGFloat outerWidth = view.bounds.size.width;
    const CGFloat outerHeight = view.bounds.size.height;
    
    const CGFloat rectX0 = fromRect.origin.x;
    const CGFloat rectX1 = fromRect.origin.x + fromRect.size.width;
    const CGFloat rectXM = fromRect.origin.x + fromRect.size.width * 0.5f;
    const CGFloat rectY0 = fromRect.origin.y;
    const CGFloat rectY1 = fromRect.origin.y + fromRect.size.height;
    const CGFloat rectYM = fromRect.origin.y + fromRect.size.height * 0.5f;;
    
    const CGFloat widthPlusArrow = contentSize.width + _arrowSize;
    const CGFloat heightPlusArrow = contentSize.height + _arrowSize;
    const CGFloat widthHalf = contentSize.width * 0.5f;
    const CGFloat heightHalf = contentSize.height * 0.5f;
    
    const CGFloat kMargin = 5.f;
    
    if (heightPlusArrow < rectY0) {
        
        _arrowDirection = PopupMenuViewArrowDirectionDown;
        CGPoint point = (CGPoint){
            rectXM - widthHalf,
            rectY0 - heightPlusArrow
        };
        
        if (point.x < kMargin)
            point.x = kMargin;
        
        if ((point.x + contentSize.width + kMargin) > outerWidth)
            point.x = outerWidth - contentSize.width - kMargin;
        
        _arrowPosition = rectXM - point.x;
        _contentView.frame = (CGRect){CGPointZero, contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width,
            contentSize.height + _arrowSize
        };
        
    } else if (heightPlusArrow < (outerHeight - rectY1)) {
    
        _arrowDirection = PopupMenuViewArrowDirectionUp;
        CGPoint point = (CGPoint){
            rectXM - widthHalf,
            rectY1
        };
        
        if (point.x < kMargin)
            point.x = kMargin;
        
        if ((point.x + contentSize.width + kMargin) > outerWidth)
            point.x = outerWidth - contentSize.width - kMargin;
        
        _arrowPosition = rectXM - point.x;
        //_arrowPosition = MAX(16, MIN(_arrowPosition, contentSize.width - 16));        
        _contentView.frame = (CGRect){0, _arrowSize, contentSize};
                
        self.frame = (CGRect) {
            
            point,
            contentSize.width,
            contentSize.height + _arrowSize
        };
        
    } else if (widthPlusArrow < (outerWidth - rectX1)) {
        
        _arrowDirection = PopupMenuViewArrowDirectionLeft;
        CGPoint point = (CGPoint){
            rectX1,
            rectYM - heightHalf
        };
        
        if (point.y < kMargin)
            point.y = kMargin;
        
        if ((point.y + contentSize.height + kMargin) > outerHeight)
            point.y = outerHeight - contentSize.height - kMargin;
        
        _arrowPosition = rectYM - point.y;
        _contentView.frame = (CGRect){_arrowSize, 0, contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width + _arrowSize,
            contentSize.height
        };
        
    } else if (widthPlusArrow < rectX0) {
        
        _arrowDirection = PopupMenuViewArrowDirectionRight;
        CGPoint point = (CGPoint){
            rectX0 - widthPlusArrow,
            rectYM - heightHalf
        };
        
        if (point.y < kMargin)
            point.y = kMargin;
        
        if ((point.y + contentSize.height + 5) > outerHeight)
            point.y = outerHeight - contentSize.height - kMargin;
        
        _arrowPosition = rectYM - point.y;
        _contentView.frame = (CGRect){CGPointZero, contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width  + _arrowSize,
            contentSize.height
        };
        
    } else {
        _arrowDirection = PopupMenuViewArrowDirectionNone;
        self.frame = (CGRect) {
            
            (outerWidth - contentSize.width)   * 0.5f,
            (outerHeight - contentSize.height) * 0.5f,
            contentSize,
        };
    }    
}

- (void)showMenuInView:(UIView *)view fromRect:(CGRect)rect menuItems:(NSArray *)menuItems target:(id)target cancelAction:(SEL)cancelAction
{
    _menuItems = menuItems;
    _cancelAction = cancelAction;
    _target = target;
    
    if (self.horizontalRank)
        _contentView = [self makeHorizontalContentView];
    else
        _contentView = [self makeVerticalContentView];
    
    _contentView.clipsToBounds = NO;
    [self addSubview:_contentView];
    
    [self setupFrameInView:view fromRect:rect];
        
    PopupMenuOverlay *overlay = [[PopupMenuOverlay alloc] initWithFrame:(CGRect){0, 0,view.bounds.size.width, view.bounds.size.height+10000}];//view.bounds];
//    NSLog(@"overlay.frame:%@", NSStringFromCGRect(overlay.frame));
    overlay.clipsToBounds = NO;
    [overlay addSubview:self];
    [view addSubview:overlay];
    
    _contentView.hidden = YES;
    const CGRect toFrame = self.frame;
    self.frame = (CGRect){self.arrowPoint, 1, 1};
    
    //动画效果
    [UIView animateWithDuration:0.2
                     animations:^(void) {
                         
                         self.alpha = 1.0f;
                         self.frame = toFrame;
                         
                     } completion:^(BOOL completed) {
                         _contentView.hidden = NO;
                     }];
}

- (void)dismissMenu:(BOOL) animated
{
    if (self.superview) {
        if (animated) {
            _contentView.hidden = YES;            
            const CGRect toFrame = (CGRect){self.arrowPoint, 1, 1};
            
            [UIView animateWithDuration:0.2 animations:^(void) {
                                 self.alpha = 0;
                                 self.frame = toFrame;
                             } completion:^(BOOL finished) {
                                 if ([self.superview isKindOfClass:[PopupMenuOverlay class]])
                                     [self.superview removeFromSuperview];
                                 [self removeFromSuperview];
                             }];
        } else {
            if ([self.superview isKindOfClass:[PopupMenuOverlay class]])
                [self.superview removeFromSuperview];
            [self removeFromSuperview];
        }
        
        __strong id target = _target;
        if (target && _cancelAction && [target respondsToSelector:_cancelAction]) {
            [target performSelectorOnMainThread:_cancelAction withObject:self waitUntilDone:YES];
        }
    }
}

- (void)performAction:(id)sender
{
    [self dismissMenu:YES];
    
    UIButton *button = (UIButton *)sender;
    PopupMenuItem *menuItem = _menuItems[button.tag];
    [menuItem performAction];
}

//创建水平排列模式下的视图
- (UIView*)makeHorizontalContentView
{
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    
    if (!_menuItems.count)
        return nil;
    
    const CGFloat kMinMenuItemHeight = 30.f;
    const CGFloat kMinMenuItemWidth = 30.f;
    const CGFloat kMarginX = 4.f;
    const CGFloat kMarginY = 0.f;
    
    CGFloat maxImageWidth = 0;
    CGFloat maxItemHeight = 0;
    CGFloat maxItemWidth = 0;
    
    UIFont *titleFont = self.titleFont;
    if (!titleFont)
        titleFont = [UIFont boldSystemFontOfSize:14];
    
    for (PopupMenuItem *menuItem in _menuItems) {
        const CGSize imageSize = menuItem.image.size;
        if (imageSize.width > maxImageWidth)
            maxImageWidth = imageSize.width;
    }
    
    for (PopupMenuItem *menuItem in _menuItems) {
        const CGSize titleSize = [menuItem.title sizeWithFont:titleFont];
        const CGSize imageSize = menuItem.image.size;
        
        const CGFloat itemHeight = MAX(titleSize.height, imageSize.height) + kMarginY * 2;
        const CGFloat itemWidth = (menuItem.image ? maxImageWidth + kMarginX : 0) + titleSize.width + kMarginX * 4;
        
        if (itemHeight > maxItemHeight)
            maxItemHeight = itemHeight;
        
        if (itemWidth > maxItemWidth)
            maxItemWidth = itemWidth;
    }
    
    maxItemWidth  = MAX(maxItemWidth, kMinMenuItemWidth);
    maxItemHeight = MAX(maxItemHeight, kMinMenuItemHeight);
    
    const CGFloat titleX = kMarginX * 2 + (maxImageWidth > 0 ? maxImageWidth + kMarginX : 0);
    const CGFloat titleWidth = maxItemWidth - titleX - kMarginX;
    
    UIImage *selectedImage = [PopupMenuView selectedImage:(CGSize){maxItemWidth, maxItemHeight + 2}];
    UIImage *gradientLine = [PopupMenuView gradientLine: (CGSize){1, maxItemHeight - kMarginY * 4}];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.autoresizingMask = UIViewAutoresizingNone;
    contentView.backgroundColor = [UIColor clearColor];
    contentView.opaque = NO;
    
//    CGFloat itemY = kMarginY * 2;
    CGFloat itemX = kMarginX * 2;
    NSUInteger itemNum = 0;

    for (PopupMenuItem *menuItem in _menuItems) {
//        const CGRect itemFrame = (CGRect){0, itemY, maxItemWidth, maxItemHeight};
        const CGRect itemFrame = (CGRect){itemX, 0, maxItemWidth, maxItemHeight};
        
        UIView *itemView = [[UIView alloc] initWithFrame:itemFrame];
        itemView.autoresizingMask = UIViewAutoresizingNone;
        itemView.backgroundColor = [UIColor clearColor];
        itemView.opaque = NO;
        
        [contentView addSubview:itemView];
        
        //按钮事件
        if (menuItem.enabled) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = itemNum;
            button.frame = itemView.bounds;
            button.enabled = menuItem.enabled;
            button.backgroundColor = [UIColor clearColor];
            button.opaque = NO;
            button.autoresizingMask = UIViewAutoresizingNone;
            
            [button addTarget:self action:@selector(performAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
            [itemView addSubview:button];
        }
        
        //标题处理
        if (menuItem.title.length) {
            CGRect titleFrame;
            
            if (!menuItem.enabled && !menuItem.image) {
                titleFrame = (CGRect){
                    kMarginX * 2,
                    kMarginY,
                    maxItemWidth - kMarginX * 4,
                    maxItemHeight - kMarginY * 2
                };
            } else {
                titleFrame = (CGRect){
                    titleX,
                    kMarginY,
                    titleWidth,
                    maxItemHeight - kMarginY * 2
                };
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
            titleLabel.text = menuItem.title;
            titleLabel.font = titleFont;
            titleLabel.textAlignment = menuItem.alignment;
            titleLabel.textColor = menuItem.foreColor ? menuItem.foreColor : [UIColor blackColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.autoresizingMask = UIViewAutoresizingNone;
            //titleLabel.backgroundColor = [UIColor greenColor];
            [itemView addSubview:titleLabel];
        }
        
        //图标处理
        if (menuItem.image) {
            const CGRect imageFrame = {kMarginX * 2, kMarginY, maxImageWidth, maxItemHeight - kMarginY * 2};
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            imageView.image = menuItem.image;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeCenter;
            imageView.autoresizingMask = UIViewAutoresizingNone;
            [itemView addSubview:imageView];
        }
        
        //分隔线处理
        if (!self.hiddenSeparator) {
            if (itemNum < _menuItems.count - 1) {
                UIImageView *gradientView = [[UIImageView alloc] initWithImage:gradientLine];
//                gradientView.frame = (CGRect){kMarginX * 2, maxItemHeight + 1, gradientLine.size};
                gradientView.frame = (CGRect){maxItemWidth + 1, kMarginY * 2 , gradientLine.size};
//                NSLog(@"gradientView.frame:%@", NSStringFromCGRect(gradientView.frame));
                gradientView.contentMode = UIViewContentModeTop;
                [itemView addSubview:gradientView];
                
//                itemY += 2;
                itemX += 2;
            }
        }
        
//        itemY += maxItemHeight;
        itemX += maxItemWidth;
        ++itemNum;
    }
    
//    contentView.frame = (CGRect){0, 0, maxItemWidth, itemY + kMarginY * 2};
    contentView.frame = (CGRect){0, 0, itemX + kMarginX * 2, maxItemHeight};
    
    return contentView;
}

//创建垂直排列模式下的视图
- (UIView*)makeVerticalContentView
{
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    
    if (!_menuItems.count)
        return nil;

    const CGFloat kMinMenuItemHeight = 30.f;
    const CGFloat kMinMenuItemWidth = 30.f;
//    const CGFloat kMinMenuItemHeight = 40.f;
//    const CGFloat kMinMenuItemWidth = 32.f;
    const CGFloat kMarginX = 6.f;
    const CGFloat kMarginY = 0.f;
    
    CGFloat maxImageWidth = 0;    
    CGFloat maxItemHeight = 0;
    CGFloat maxItemWidth = 0;
    
    UIFont *titleFont = self.titleFont;
    if (!titleFont)
        titleFont = [UIFont boldSystemFontOfSize:14];
    
    for (PopupMenuItem *menuItem in _menuItems) {
        const CGSize imageSize = menuItem.image.size;        
        if (imageSize.width > maxImageWidth)
            maxImageWidth = imageSize.width;        
    }
    
    for (PopupMenuItem *menuItem in _menuItems) {
        const CGSize titleSize = [menuItem.title sizeWithFont:titleFont];
        const CGSize imageSize = menuItem.image.size;

        const CGFloat itemHeight = MAX(titleSize.height, imageSize.height) + kMarginY * 2;
        const CGFloat itemWidth = (menuItem.image ? maxImageWidth + kMarginX : 0) + titleSize.width + kMarginX * 4;
        
        if (itemHeight > maxItemHeight)
            maxItemHeight = itemHeight;
        
        if (itemWidth > maxItemWidth)
            maxItemWidth = itemWidth;
    }
       
    maxItemWidth  = MAX(maxItemWidth, kMinMenuItemWidth);
    maxItemHeight = MAX(maxItemHeight, kMinMenuItemHeight);

    const CGFloat titleX = kMarginX * 2 + (maxImageWidth > 0 ? maxImageWidth + kMarginX : 0);
    const CGFloat titleWidth = maxItemWidth - titleX - kMarginX;
    
    UIImage *selectedImage = [PopupMenuView selectedImage:(CGSize){maxItemWidth, maxItemHeight + 2}];
    UIImage *gradientLine = [PopupMenuView gradientLine: (CGSize){maxItemWidth - kMarginX * 4, 1}];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.autoresizingMask = UIViewAutoresizingNone;
    contentView.backgroundColor = [UIColor clearColor];
    contentView.opaque = NO;
    
    CGFloat itemY = kMarginY * 2;
    NSUInteger itemNum = 0;
        
    for (PopupMenuItem *menuItem in _menuItems) {
                
        const CGRect itemFrame = (CGRect){0, itemY, maxItemWidth, maxItemHeight};
        
        UIView *itemView = [[UIView alloc] initWithFrame:itemFrame];
        itemView.autoresizingMask = UIViewAutoresizingNone;
        itemView.backgroundColor = [UIColor clearColor];        
        itemView.opaque = NO;
                
        [contentView addSubview:itemView];
        
        //按钮事件
        if (menuItem.enabled) {
        
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = itemNum;
            button.frame = itemView.bounds;
            button.enabled = menuItem.enabled;
            button.backgroundColor = [UIColor clearColor];
            button.opaque = NO;
            button.autoresizingMask = UIViewAutoresizingNone;
            
            [button addTarget:self
                       action:@selector(performAction:)
             forControlEvents:UIControlEventTouchUpInside];
            
            [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
            
            [itemView addSubview:button];
        }
        
        //标题处理
        if (menuItem.title.length) {
            
            CGRect titleFrame;
            
            if (!menuItem.enabled && !menuItem.image) {
                
                titleFrame = (CGRect){
                    kMarginX * 2,
                    kMarginY,
                    maxItemWidth - kMarginX * 4,
                    maxItemHeight - kMarginY * 2
                };
                
            } else {
                titleFrame = (CGRect){
                    titleX,
                    kMarginY,
                    titleWidth,
                    maxItemHeight - kMarginY * 2
                };
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
            titleLabel.text = menuItem.title;
            titleLabel.font = titleFont;
            titleLabel.textAlignment = menuItem.alignment;
            titleLabel.textColor = menuItem.foreColor ? menuItem.foreColor : [UIColor blackColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.autoresizingMask = UIViewAutoresizingNone;
            //titleLabel.backgroundColor = [UIColor greenColor];
            [itemView addSubview:titleLabel];            
        }
        
        //图标处理
        if (menuItem.image) {
            const CGRect imageFrame = {kMarginX * 2, kMarginY, maxImageWidth, maxItemHeight - kMarginY * 2};
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            imageView.image = menuItem.image;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeCenter;
            imageView.autoresizingMask = UIViewAutoresizingNone;
            [itemView addSubview:imageView];
        }
        
        //分隔线处理
        if (!self.hiddenSeparator) {
            if (itemNum < _menuItems.count - 1) {
                
                UIImageView *gradientView = [[UIImageView alloc] initWithImage:gradientLine];
                gradientView.frame = (CGRect){kMarginX * 2, maxItemHeight + 1, gradientLine.size};
                gradientView.contentMode = UIViewContentModeLeft;
                [itemView addSubview:gradientView];
                
                itemY += 2;
            }
        }
        
        itemY += maxItemHeight;
        ++itemNum;
    }    
    
    contentView.frame = (CGRect){0, 0, maxItemWidth, itemY + kMarginY * 2};
    
    return contentView;
}

- (CGPoint)arrowPoint
{
    CGPoint point;
    
    if (_arrowDirection == PopupMenuViewArrowDirectionUp) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame) + _arrowPosition, CGRectGetMinY(self.frame) };
        
    } else if (_arrowDirection == PopupMenuViewArrowDirectionDown) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame) + _arrowPosition, CGRectGetMaxY(self.frame) };
        
    } else if (_arrowDirection == PopupMenuViewArrowDirectionLeft) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame), CGRectGetMinY(self.frame) + _arrowPosition  };
        
    } else if (_arrowDirection == PopupMenuViewArrowDirectionRight) {
        
        point = (CGPoint){ CGRectGetMaxX(self.frame), CGRectGetMinY(self.frame) + _arrowPosition  };
        
    } else {
        
        point = self.center;
    }
    
    return point;
}

+ (UIImage *) selectedImage: (CGSize) size
{
    const CGFloat locations[] = {0,1};
    const CGFloat components[] = {
//        0.216, 0.471, 0.871, 1,
//        0.059, 0.353, 0.839, 1,
        0.662, 0.662, 0.662, 1,
        0.662, 0.662, 0.662, 1
    };
    
    return [self gradientImageWithSize:size locations:locations components:components count:2];
}

+ (UIImage *) gradientLine: (CGSize) size
{
    const CGFloat locations[5] = {0,0.2,0.5,0.8,1};
    
    const CGFloat R = 0.44f, G = 0.44f, B = 0.44f;
        
    const CGFloat components[20] = {
        R,G,B,0.1,
        R,G,B,0.4,
        R,G,B,0.7,
        R,G,B,0.4,
        R,G,B,0.1
    };
    
    return [self gradientImageWithSize:size locations:locations components:components count:5];
}

+ (UIImage *) gradientImageWithSize:(CGSize) size
                          locations:(const CGFloat []) locations
                         components:(const CGFloat []) components
                              count:(NSUInteger)count
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef colorGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawLinearGradient(context, colorGradient, (CGPoint){0, 0}, (CGPoint){size.width, 0}, 0);
    CGGradientRelease(colorGradient);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void) drawRect:(CGRect)rect
{
    [self drawBackground:self.bounds inContext:UIGraphicsGetCurrentContext()];
}

- (void)drawBackground:(CGRect)frame inContext:(CGContextRef) context
{
//    CGFloat R0 = 0.267, G0 = 0.303, B0 = 0.335;
//    CGFloat R1 = 0.040, G1 = 0.040, B1 = 0.040;
    CGFloat R0 = 1, G0 = 1, B0 = 1;
    CGFloat R1 = 1, G1 = 1, B1 = 1;
    
    UIColor *backgroundColor = self.topBackgroundColor;
    if (backgroundColor) {
        CGFloat a;
        [backgroundColor getRed:&R0 green:&G0 blue:&B0 alpha:&a];
        [backgroundColor getRed:&R1 green:&G1 blue:&B1 alpha:&a];
    }
    
    CGFloat X0 = frame.origin.x;
    CGFloat X1 = frame.origin.x + frame.size.width;
    CGFloat Y0 = frame.origin.y;
    CGFloat Y1 = frame.origin.y + frame.size.height;
    
    // render arrow
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    // fix the issue with gap of arrow's base if on the edge
    const CGFloat kEmbedFix = 3.f;
    
    if (_arrowDirection == PopupMenuViewArrowDirectionUp) {
        
        const CGFloat arrowXM = _arrowPosition;
        const CGFloat arrowX0 = arrowXM - _arrowSize;
        const CGFloat arrowX1 = arrowXM + _arrowSize;
        const CGFloat arrowY0 = Y0;
        const CGFloat arrowY1 = Y0 + _arrowSize + kEmbedFix;
        
        [arrowPath moveToPoint:    (CGPoint){arrowXM, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowXM, arrowY0}];
        
        [[UIColor colorWithRed:R0 green:G0 blue:B0 alpha:1] set];
        
        Y0 += _arrowSize;
        
    } else if (_arrowDirection == PopupMenuViewArrowDirectionDown) {
        
        const CGFloat arrowXM = _arrowPosition;
        const CGFloat arrowX0 = arrowXM - _arrowSize;
        const CGFloat arrowX1 = arrowXM + _arrowSize;
        const CGFloat arrowY0 = Y1 - _arrowSize - kEmbedFix;
        const CGFloat arrowY1 = Y1;
        
        [arrowPath moveToPoint:    (CGPoint){arrowXM, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowXM, arrowY1}];
        
        [[UIColor colorWithRed:R1 green:G1 blue:B1 alpha:1] set];
        
        Y1 -= _arrowSize;
        
    } else if (_arrowDirection == PopupMenuViewArrowDirectionLeft) {
        
        const CGFloat arrowYM = _arrowPosition;        
        const CGFloat arrowX0 = X0;
        const CGFloat arrowX1 = X0 + _arrowSize + kEmbedFix;
        const CGFloat arrowY0 = arrowYM - _arrowSize;;
        const CGFloat arrowY1 = arrowYM + _arrowSize;
        
        [arrowPath moveToPoint:    (CGPoint){arrowX0, arrowYM}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowYM}];
        
        [[UIColor colorWithRed:R0 green:G0 blue:B0 alpha:1] set];
        
        X0 += _arrowSize;
        
    } else if (_arrowDirection == PopupMenuViewArrowDirectionRight) {
        
        const CGFloat arrowYM = _arrowPosition;        
        const CGFloat arrowX0 = X1;
        const CGFloat arrowX1 = X1 - _arrowSize - kEmbedFix;
        const CGFloat arrowY0 = arrowYM - _arrowSize;;
        const CGFloat arrowY1 = arrowYM + _arrowSize;
        
        [arrowPath moveToPoint:    (CGPoint){arrowX0, arrowYM}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowYM}];
        
        [[UIColor colorWithRed:R1 green:G1 blue:B1 alpha:1] set];
        
        X1 -= _arrowSize;
    }
    
    [arrowPath fill];

    // render body
    
    const CGRect bodyFrame = {X0, Y0, X1 - X0, Y1 - Y0};
    
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:bodyFrame cornerRadius:_cornerRadius];
        
    const CGFloat locations[] = {0, 1};
    const CGFloat components[] = {
        R0, G0, B0, 1,
        R1, G1, B1, 1,
    };
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                 components,
                                                                 locations,
                                                                 sizeof(locations)/sizeof(locations[0]));
    CGColorSpaceRelease(colorSpace);
    
    
    [borderPath addClip];
    
    CGPoint start, end;
    
    if (_arrowDirection == PopupMenuViewArrowDirectionLeft ||
        _arrowDirection == PopupMenuViewArrowDirectionRight) {
                
        start = (CGPoint){X0, Y0};
        end = (CGPoint){X1, Y0};
        
    } else {
        
        start = (CGPoint){X0, Y0};
        end = (CGPoint){X0, Y1};
    }
    
    CGContextDrawLinearGradient(context, gradient, start, end, 0);
    
    CGGradientRelease(gradient);    
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pragma mark - PopupMenu

//static PopupMenu *gMenu;
//static UIColor *gBackgroundColor;
//static UIFont *gTitleFont;
//static CGFloat gCornerRadius = 8.f;

@implementation PopupMenu {
    PopupMenuView *_menuView;
    BOOL _observing;
}

//+ (instancetype) sharedMenu
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        
//        gMenu = [[PopupMenu alloc] init];
//    });
//    return gMenu;
//}

- (id) init
{
//    NSAssert(!gMenu, @"singleton object");
    
    self = [super init];
    if (self) {
        self.cornerRadius = 8.0f;
    }
    return self;
}

- (void)dealloc
{
    if (_observing) {        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)showMenuInView:(UIView *)view fromRect:(CGRect)rect menuItems:(NSArray *)menuItems arrowSize:(CGFloat)arrowSize target:(id)target cancelAction:(SEL)cancelAction
{
//    NSParameterAssert(view);
//    NSParameterAssert(menuItems.count);
    
    if (_menuView) {
        [_menuView dismissMenu:NO];
        _menuView = nil;
    }

    if (!_observing) {
        _observing = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationWillChange:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
    }

    _menuView = [[PopupMenuView alloc] initWithArrowSize:arrowSize cornerRadius:self.cornerRadius titleFont:self.titleFont topBackgroundColor:self.backgroundColor hiddenSeparator:self.hiddenSeparator horizontalRank:self.horizontalRank];
    //显示菜单
    [_menuView showMenuInView:view fromRect:rect menuItems:menuItems target:target cancelAction:cancelAction];
}

- (void)dismissMenu
{
    if (_menuView) {
        [_menuView dismissMenu:NO];
        _menuView = nil;
    }
    
    if (_observing) {
        _observing = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void) orientationWillChange: (NSNotification *) n
{
    [self dismissMenu];
}

@end
