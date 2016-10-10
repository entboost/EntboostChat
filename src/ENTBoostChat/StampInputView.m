//
//  StampInputView.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-9-17.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "StampInputView.h"
#import "ENTBoostChat.h"
#import "ENTBoost.h"
#import "SETextView.h"
#import "CustomSeparator.h"
#import "ENTBoost+Utility.h"

@implementation StampButton

@end

@interface StampInputView () <UIScrollViewDelegate>

@property(nonatomic, strong) NSArray* expressions;       //表情队列

@property(nonatomic, strong) UIScrollView*  scrollView;         //滚动视图
@property(nonatomic, strong) UIView*        contentView;        //内容视图
@property(nonatomic, strong) NSMutableArray* pointImageViews;   //分页小圆点视图队列

@property(nonatomic) NSUInteger currentPage;    //当前页数
@property(nonatomic) NSUInteger lastPage;       //上次保存页数

@end

@implementation StampInputView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.currentPage    = 1;
        self.lastPage       = 1;
        self.isRealShow     = NO;
        self.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithHexString:@"#ACE9FF"];
        self.pointImageViews = [[NSMutableArray alloc] init];
    }
    return self;
}

const CGFloat emoInterval = 8.0; //表情图标间隔
const CGFloat emoWidth = 32.0, emoHeight = 32.0; //表情图标宽和高

//获取最大列数
- (int)maxColumn:(CGSize)size
{
    return (int)((size.width - emoInterval)/(emoWidth+emoInterval)); //每行最大可放置最大个数
}

//获取最大行数
- (int)maxRow:(CGSize)size
{
    return (int)((size.height - emoInterval)/(emoHeight+emoInterval)); //可放置最大行数
}

//获取单页最大数量
- (NSUInteger)maxCountOfPage
{
    const int maxColumn = [self maxColumn:self.bounds.size]; //每行最大可放置最大个数
    const int maxRow = [self maxRow:self.bounds.size]; //可放置最大行数
    return maxRow>2?((maxRow-2)*maxColumn-1):0;
}

//获取总页数
- (NSUInteger)totalPages
{
    NSUInteger maxCountOfPage = [self maxCountOfPage];
    if (maxCountOfPage==0)
        return 0;
    
    NSUInteger total = self.expressions.count;
    return (total+maxCountOfPage-1)/maxCountOfPage;
}

//填充指定分页表情视图
- (void)fillPage:(NSUInteger)page expressions:(NSArray*)expressions screenSize:(CGSize)screenSize
{
    const int maxColumn = [self maxColumn:screenSize]; //(int)((screenSize.width - emoInterval)/(emoWidth+emoInterval)); //每行最大可放置最大个数
    const int maxRow = [self maxRow:screenSize]; //(int)((screenSize.height - emoInterval)/(emoHeight+emoInterval)); //可放置最大行数
    const CGFloat remainWidth = screenSize.width - (maxColumn*(emoWidth+emoInterval)+emoInterval); //横向填充以后剩余的空白宽度
    const CGFloat remainHeight = screenSize.height - (maxRow*(emoHeight+emoInterval)+emoInterval); //纵向填充以后剩余的空白高度
    
//    NSArray* expressions = [self stampsAtPage:&page];
    NSMutableArray* stamps = [NSMutableArray array];
    for (int i=0;i<expressions.count; i++) {
        //                if (((i+1)/maxColumn) >= maxRow-2) //最多只显示maxRow-2行，并且最后一个图标位置留空给工具栏
        //                    break;
        EBEmotion* emotion = [expressions objectAtIndex:i];
        
        StampButton* button = [StampButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(remainWidth/2 + emoInterval +(emoInterval + emoWidth)*(i%maxColumn) + ((page-1)*screenSize.width), remainHeight/2 + emoInterval + ((i/maxColumn)*(emoHeight + emoInterval)), emoWidth, emoHeight);
        button.backgroundColor = [UIColor clearColor];
        
        //设置背景图
        UIImage* image;
        if (emotion.dynamicFilepath)
            image = [UIImage imageWithContentsOfFile:emotion.dynamicFilepath];
        else
            image = [UIImage imageNamed:@"loading_emotion"];
        [button setImage:image forState:UIControlStateNormal];
        //                UIWebView* view = [[UIWebView alloc] initWithFrame:button.bounds];
        //                [view loadData:[NSData dataWithContentsOfFile:emotion.dynamicFilepath] MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
        //                [button addSubview:view];
        
        //绑定自定义数据
        button.data = @{STAMP_CUSTOM_DATA_EMOTION_NAME: emotion};
        //绑定点击事件
        [button addTarget:self action:@selector(stampTap:) forControlEvents:UIControlEventTouchUpInside];
        
        [stamps addObject:button];
        //设置圆角边框
        EBCHAT_UI_SET_CORNER_VIEW_RADIUS(button, 1.0f, [UIColor clearColor]/*[UIColor colorWithHexString:@"#ACE9FF"]*/, 16.0f);
    }
    
    //最后一个位置放置删除按钮
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    const CGFloat delButtonWidth = emoWidth + 6.0f;
    const CGFloat delButtonHeight = emoHeight + 8.0f;
    const NSUInteger lastIndex = expressions.count;
    button.frame = CGRectMake((remainWidth/2 + emoInterval +(emoInterval + emoWidth)*(lastIndex%maxColumn))-3.0 + ((page-1)*screenSize.width), (remainHeight/2 + emoInterval + ((lastIndex/maxColumn)*(emoHeight + emoInterval)))-4.0, delButtonWidth, delButtonHeight);
    //            [button setBackgroundImage:[UIImage imageFromColor:[UIColor lightGrayColor] size:CGSizeMake(delButtonWidth, delButtonHeight)] forState:UIControlStateNormal];
    //            [button setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor] size:CGSizeMake(delButtonWidth, delButtonHeight)] forState:UIControlStateHighlighted];
    [button setImage:[[UIImage imageNamed:@"emotion_del"] scaleToSize:CGSizeMake(24.0f, 24.0f)] forState:UIControlStateNormal];
    
    //绑定点击事件
    [button addTarget:self action:@selector(deleteStampTap:) forControlEvents:UIControlEventTouchUpInside];
    [stamps addObject:button];
//    //设置圆角边框
//    EBCHAT_UI_SET_CORNER_VIEW_RADIUS(button, 0.5f, [UIColor grayColor], 5.0f);
    
    for (StampButton* btn in stamps)
        [self.contentView addSubview:btn];
}

const CGFloat pointWidth = 8;
const CGFloat pointHeight = 8;
const CGFloat pointPlaceHolderWidth = 16;

- (void)fillStamps
{
    if (self.isRealShow)
        return;
        
    //清理旧的图标视图
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
    
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    if (ebKit.isEmotionLoaded)
        self.isRealShow = YES;
    
    self.expressions = [[ENTBoostKit sharedToolKit] expressions];
    
    //计算尺寸
    CGSize screenSize = self.bounds.size;
    NSUInteger totalPages = [self totalPages];
    NSUInteger maxCountOfPage = [self maxCountOfPage];
    const int maxRow = [self maxRow:screenSize]; //(int)((screenSize.height - emoInterval)/(emoHeight+emoInterval)); //可放置最大行数
    
    //生成滚动视图
    CGFloat contentViewWidth    = (maxRow-1)*emoWidth+(emoWidth*0.7);
    CGFloat contentViewHeight   = (maxRow-1)*emoHeight+10;
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width*totalPages, contentViewWidth)];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, contentViewWidth)];
    self.scrollView.delegate = self;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(totalPages*screenSize.width, 0);
    [self.scrollView addSubview:self.contentView];
    [self addSubview:self.scrollView];
    
    for (NSUInteger page=1; page<=totalPages; page++) {
        //获取指定分页的表情队列
        NSArray* subExpressions;
        if (page < totalPages)
            subExpressions = [self.expressions subarrayWithRange:NSMakeRange((page-1)*maxCountOfPage, maxCountOfPage)];
        else
            subExpressions = [self.expressions subarrayWithRange:NSMakeRange((page-1)*maxCountOfPage, self.expressions.count-((page-1)*maxCountOfPage))];

        //填充指定分页表情视图
        [self fillPage:page expressions:subExpressions screenSize:CGSizeMake(screenSize.width, contentViewHeight)];
    }
    
    //---设置工具栏
    const CGFloat toolbarHeight = 44.0f;
    const CGFloat toolbarWidth = self.bounds.size.width;
    UIView* toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, screenSize.height - toolbarHeight, toolbarWidth, toolbarHeight)];
    toolbar.backgroundColor = EBCHAT_DEFAULT_BLANK_COLOR;//[UIColor colorWithHexString:@"#ACE9FF"];//[UIColor colorWithHexString:@"#C0C5CD"];
    [self addSubview:toolbar];
    
    //设置分页图标
    NSUInteger pageCount = [self totalPages];
    for (int j=0; j<pageCount; j++) {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenSize.width-pageCount*pointPlaceHolderWidth)/2 + j*pointPlaceHolderWidth, screenSize.height-toolbarHeight-pointPlaceHolderWidth, pointWidth, pointHeight)];
        [imageView setImage:[UIImage imageFromColor:self.currentPage==(j+1)?[UIColor grayColor]:[UIColor lightGrayColor] size:CGSizeMake(pointWidth, pointHeight)]];
        EBCHAT_UI_SET_CORNER_VIEW_RADIUS(imageView, 0.1, self.currentPage==(j+1)?[UIColor grayColor]:[UIColor lightGrayColor], pointWidth/2);
        [self addSubview:imageView];
        
        [self.pointImageViews addObject:imageView];
    }
    
    //分隔线
    const CGFloat lineHeight = 0.5f;
    CustomSeparator* separator = [[CustomSeparator alloc] initWithFrame:CGRectMake(0, 0, toolbarWidth, lineHeight)];
    separator.color1 = EBCHAT_DEFAULT_BORDER_CORLOR;//[UIColor lightGrayColor];
    separator.lineHeight1 = lineHeight;
    [toolbar addSubview:separator];
    
    //发送按钮
    CGSize btnSize = CGSizeMake(100.0f, 36.0f);
    UIButton* sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(toolbarWidth-btnSize.width-5.0f, 4.0f, btnSize.width, btnSize.height);
    [sendBtn setBackgroundImage:[UIImage imageFromColor:EBCHAT_DEFAULT_COLOR/*[UIColor colorWithHexString:@"#0067FF"]*/ size:btnSize] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor] size:btnSize] forState:UIControlStateHighlighted];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [sendBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    [sendBtn setTitle:@"发  送" forState:UIControlStateNormal];
    EBCHAT_UI_SET_CORNER_VIEW_RADIUS(sendBtn, 0.5f, [UIColor clearColor]/*[UIColor colorWithHexString:@"#C0C5CD"]*/, 2.0f); //设置圆角边框
    
    [sendBtn addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [toolbar addSubview:sendBtn];
}

//发送按钮点击事件
- (IBAction)sendAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(stampInputView:customButton1Taped:)]) {
        [self.delegate stampInputView:self customButton1Taped:sender];
    }
}

//选中一个表情图标
- (IBAction)stampTap:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(stampInputView:stampTaped:)]) {
        [self.delegate stampInputView:self stampTaped:sender];
    }
}

//删除输入框里的表情图标
- (IBAction)deleteStampTap:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(stampInputView:deleteBackwordTaped:)]) {
        [self.delegate stampInputView:self deleteBackwordTaped:sender];
    }
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)sender
{
    UIScrollView* scrollView = self.scrollView;
    //设置当前页数
    self.currentPage = ceil((scrollView.contentOffset.x+0.1) / scrollView.bounds.size.width);
//    NSLog(@"self.currentPage = %@, scrollView.contentOffset.x=%@, scrollView.bounds.size.width=%@", @(self.currentPage), @(scrollView.contentOffset.x), @(scrollView.bounds.size.width));
    
    if (self.currentPage==0)
        self.currentPage = 1;
    
    NSUInteger totalPages = [self totalPages];
    if (self.currentPage>totalPages)
        self.currentPage = totalPages;
    
    if (self.lastPage==self.currentPage)
        return;
    
    //把上一次保存的分页对应圆点标记复位
    UIImageView* imageView = [self.pointImageViews objectAtIndex:self.lastPage-1];
    [imageView setImage:[UIImage imageFromColor:[UIColor lightGrayColor] size:CGSizeMake(pointWidth, pointHeight)]];
    self.lastPage = self.currentPage;
    
    //把当前分页对应圆点标记显亮
    imageView = [self.pointImageViews objectAtIndex:self.currentPage-1];
    [imageView setImage:[UIImage imageFromColor:[UIColor grayColor] size:CGSizeMake(pointWidth, pointHeight)]];
}

@end
