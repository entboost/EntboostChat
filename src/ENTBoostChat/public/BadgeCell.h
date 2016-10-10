//
//  BadgedCell.h
//	BageView
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface BadgeView : UIView
{
}

@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, strong)   NSString *badgeString;
@property (nonatomic, weak)     UITableViewCell *parent;
@property (nonatomic, strong)   UIColor *badgeColor;
@property (nonatomic, strong)   UIColor *badgeColorHighlighted;
@property (nonatomic) BOOL showShadow;
@property (nonatomic) CGFloat radius;

@end

@interface BadgeCell : UITableViewCell {

}

@property (nonatomic, strong)   NSString *badgeString;
@property (nonatomic, strong, readonly) BadgeView *badge;
@property (nonatomic, strong)   UIColor *badgeColor;
@property (nonatomic, strong)   UIColor *badgeColorHighlighted;
@property (nonatomic)           BOOL showShadow;

@end
