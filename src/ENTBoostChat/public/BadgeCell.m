//
//  BadgedCell.m
//	BageView
//

#import "BadgeCell.h"
#import "ENTBoostChat.h"

//定义字体大小
const CGFloat badgeFontSize = 12.0;
const CGFloat badgeMinViewWidth  = 19.0; //定义badge视图最小尺寸
const CGFloat badgeViewHeight    = 19.0; //定义badge视图固定高度

@implementation BadgeView

- (id) initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

- (void) drawRect:(CGRect)rect
{
    if (self.badgeString) {
        UIFont* font = [UIFont boldSystemFontOfSize:badgeFontSize];
        NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByClipping;
        NSDictionary* attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
        
        CGSize numberSize = [self.badgeString sizeWithFont:font];
        if (IOS7)
            numberSize = [self.badgeString sizeWithAttributes:attributes];
        
//        CGFloat width = numberSize.width;// + 12;
        CGRect bounds = CGRectMake(0, 0, numberSize.width, numberSize.height); //width<numberSize.height?numberSize.height:width, numberSize.height); //18);
        CGFloat radius = (_radius)?_radius:(badgeViewHeight/2);//(numberSize.height/2); //4.0;
        
        UIColor *color;
        
        if((_parent.selectionStyle != UITableViewCellSelectionStyleNone) && (_parent.highlighted || _parent.selected)) {
            if (_badgeColorHighlighted) {
                color = _badgeColorHighlighted;
            } else {
                color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.000f];
            }
        } else {
            if (_badgeColor) {
                color = _badgeColor;
            } else {
                color = [UIColor colorWithRed:0.530f green:0.600f blue:0.738f alpha:1.000f];
            }
        }
        
        // Bounds for thet text label
        bounds.origin.x = (rect.size.width - numberSize.width)/2;//(bounds.size.width - numberSize.width) / 2.0f;// + 0.5f;
        bounds.origin.y = (badgeViewHeight-numberSize.height)/2;//+= 2;
        
        CALayer *badge = [CALayer layer];
        [badge setFrame:rect];
        
        CGSize imageSize = badge.frame.size;
        
//        // Render the image @x2 for retina people
//        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00)
//        {
//            imageSize = CGSizeMake(badge.frame.size.width * 2, badge.frame.size.height * 2);
//            [badge setFrame:CGRectMake(badge.frame.origin.x,
//                                         badge.frame.origin.y,
//                                         badge.frame.size.width*2,
//                                         badge.frame.size.height*2)];
////            fontsize = (fontsize * 2);
//            bounds.origin.x = ((bounds.size.width * 2) - (numberSize.width * 2)) / 2.0f + 1;
//            bounds.origin.y += 3;
//            bounds.size.width = bounds.size.width * 2;
//            radius = radius * 2;
//        }
        
        [badge setBackgroundColor:[color CGColor]];
        [badge setCornerRadius:radius];
        
        UIGraphicsBeginImageContext(imageSize);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSaveGState(context);
        [badge renderInContext:context];
        CGContextRestoreGState(context);
        
        CGContextSetBlendMode(context, kCGBlendModeClear);
        
//        [_badgeString drawInRect:bounds withFont:[UIFont boldSystemFontOfSize:fontsize] lineBreakMode:NSLineBreakByClipping];
        [self.badgeString drawInRect:bounds withAttributes:attributes];
        
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        [outputImage drawInRect:rect];
        
        if((_parent.selectionStyle != UITableViewCellSelectionStyleNone) && (_parent.highlighted || _parent.selected) && _showShadow) {
            [[self layer] setCornerRadius:radius];
            [[self layer] setShadowOffset:CGSizeMake(0, 1)];
            [[self layer] setShadowRadius:1.0];
            [[self layer] setShadowOpacity:0.8];
        } else {
            [[self layer] setCornerRadius:radius];
            [[self layer] setShadowOffset:CGSizeMake(0, 0)];
            [[self layer] setShadowRadius:0];
            [[self layer] setShadowOpacity:0];
        }
    } else {
        [super drawRect:rect];
    }
}

@end


@implementation BadgeCell

@synthesize badge = __badge;

//- (void)setBadgeString:(NSString *)badgeString
//{
//    _badgeString = badgeString;
//}

- (void)configureSelf 
{
    // Initialization code
    __badge = [[BadgeView alloc] initWithFrame:CGRectZero];
    self.badge.parent = self;
    
    [self.contentView addSubview:self.badge];
    [self.badge setNeedsDisplay];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) 
    {
        [self configureSelf];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) 
    {
        [self configureSelf];
    }
    return self;
}

#pragma mark - Drawing Methods

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	if(self.badgeString) {
		//force badges to hide on edit.
		if(self.editing)
			[self.badge setHidden:YES];
		else
			[self.badge setHidden:NO];
		
        UIFont* font = [UIFont boldSystemFontOfSize:badgeFontSize];
        NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByClipping;
        NSDictionary* attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
        
        CGSize oneCharSize1 = [@"1" sizeWithFont:font]; //计算单个数字占位宽度
        CGSize oneCharSize2 = [@"2" sizeWithFont:font];
        CGSize badgeStringSize = [self.badgeString sizeWithFont:font]; //计算整个内容占位宽度
        //在IOS7及以上版本计算占位宽度
        if (IOS7) {
            oneCharSize1 = [@"1" sizeWithAttributes:attributes];
            oneCharSize2 = [@"2" sizeWithAttributes:attributes];
            badgeStringSize = [self.badgeString sizeWithAttributes:attributes];
        }
        
//		CGSize badgeSize = [self.badgeString sizeWithFont:[UIFont boldSystemFontOfSize: 11]];
        CGFloat badgeViewWidth = badgeStringSize.width>badgeMinViewWidth?badgeStringSize.width:badgeMinViewWidth;
        CGRect badgeframe = CGRectMake(self.contentView.frame.size.width - (badgeViewWidth + 25),
//                                (CGFloat)round((self.contentView.frame.size.height - 18) / 2),
                                (self.contentView.frame.size.height - badgeViewHeight/*18*/) / 2,
                                       badgeViewWidth + ((badgeStringSize.width==oneCharSize1.width)?(badgeStringSize.width-oneCharSize1.width):(badgeStringSize.width-oneCharSize2.width)), //+ 13,
                                badgeViewHeight); //18);
		
        if(self.showShadow)
            [self.badge setShowShadow:YES];
        else
            [self.badge setShowShadow:NO];
            
		[self.badge setFrame:badgeframe];
		[self.badge setBadgeString:self.badgeString];
		
		if ((self.textLabel.frame.origin.x + self.textLabel.frame.size.width) >= badgeframe.origin.x) {
			CGFloat badgeWidth = self.textLabel.frame.size.width - badgeframe.size.width - 10.0f;
			
			self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, badgeWidth, self.textLabel.frame.size.height);
		}
		
		if ((self.detailTextLabel.frame.origin.x + self.detailTextLabel.frame.size.width) >= badgeframe.origin.x) {
			CGFloat badgeWidth = self.detailTextLabel.frame.size.width - badgeframe.size.width - 10.0f;
			
			self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, self.detailTextLabel.frame.origin.y, badgeWidth, self.detailTextLabel.frame.size.height);
		}
        
		//set badge highlighted colours or use defaults
		if(self.badgeColorHighlighted)
			self.badge.badgeColorHighlighted = self.badgeColorHighlighted;
		else 
			self.badge.badgeColorHighlighted = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.000f];
		
		//set badge colours or impose defaults
		if(self.badgeColor)
			self.badge.badgeColor = self.badgeColor;
		else
			self.badge.badgeColor = [UIColor colorWithRed:0.530f green:0.600f blue:0.738f alpha:1.000f];
	} else {
        [self.badge setBadgeString:nil];
		[self.badge setHidden:YES];
	}
	
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:animated];
	[self.badge setNeedsDisplay];
    
    if(self.showShadow)
    {
        [[[self textLabel] layer] setShadowOffset:CGSizeMake(0, 1)];
        [[[self textLabel] layer] setShadowRadius:1];
        [[[self textLabel] layer] setShadowOpacity:0.8];
        
        [[[self detailTextLabel] layer] setShadowOffset:CGSizeMake(0, 1)];
        [[[self detailTextLabel] layer] setShadowRadius:1];
        [[[self detailTextLabel] layer] setShadowOpacity:0.8];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	[self.badge setNeedsDisplay];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	if (editing) 
    {
		self.badge.hidden = YES;
		[self.badge setNeedsDisplay];
		[self setNeedsDisplay];
	}
	else 
	{
		self.badge.hidden = NO;
		[self.badge setNeedsDisplay];
		[self setNeedsDisplay];
	}
}

@end
