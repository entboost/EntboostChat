//
//  WeiXinCell.m
//  WeixinDeom
//
//  Created by iHope on 13-12-31.
//  Copyright (c) 2013年 任海丽. All rights reserved.
//

#import "ChatCell.h"
#import "ENTBoostChat.h"
#import "ENTBoost.h"
#import "ENTBoost+Utility.h"
#import "BlockUtility.h"
#import "GifView.h"
#import "ASProgressPopUpView.h"
#import "Reachability.h"
#import "PublicUI.h"
#import "PopupMenu.h"
#import "MultimediaUtility.h"
#import "CTFrameParserConfig.h"
#import "CTFrameParser.h"
#import "CoreTextImageData.h"
#import "CoreTextLinkData.h"
#import <CoreText/CoreText.h>

////使用完后销毁对象
//static void RunDelegateDeallocCallback( void* refCon ){
//    CFRelease(refCon);
//}
//
////获取图片显示高度
//static CGFloat RunDelegateGetAscentCallback( void *refCon ){
//    NSString *tag = (__bridge NSString *)refCon;
//    CoreTextImageData* chatImage = [[ChatRenderingCache sharedCache] chatImageForTag:tag];
//    
//    if(chatImage)
//        return chatImage.scaleSize.height;
//    else
//        return 0.0;
//    //return [UIImage imageNamed:imageName].size.height;
//    //return 50;
//}
//
////获取图片显示下降高度
//static CGFloat RunDelegateGetDescentCallback(void *refCon){
//    NSString *tag = (__bridge NSString *)refCon;
//    CoreTextImageData* chatImage = [[ChatRenderingCache sharedCache] chatImageForTag:tag];
//    
//    if(chatImage) {
//        //NSLog(@"descender = %f", fabsf(chatImage.descender));
//        return fabs(chatImage.descender);
//    }
//    else
//        return 0.0;
//
//    //return -[UIFont boldSystemFontOfSize:20].descender;
//}
//
////获取图片显示宽度
//static CGFloat RunDelegateGetWidthCallback(void *refCon){
//    NSString *tag = (__bridge NSString *)refCon;
//    CoreTextImageData* chatImage = [[ChatRenderingCache sharedCache] chatImageForTag:tag];
//    
//    if(chatImage)
//        return chatImage.scaleSize.width;
//    else
//        return 0.0;
//    //return [UIImage imageNamed:imageName].size.width;
//    //return 50;
//}

@interface ChatCell () <ChatViewDelegate>
{
    //消息对象
    EBMessage* _message;
    
    //语音消息对象
    EBChatAudio* _chatAudio;
    //播放语音的按钮
    UIButton* _playVoiceBtn;
    //语音播放图标按钮尺寸
    CGSize _audioButtonSize;
    //播放语音按钮图片
    UIImage* _playVoiceImage;
    //正在播放语音按钮尺寸
    CGSize _playingAudioButtonSize;
    //正在播放语音视图
    GifView* _playVoiceAnimatedView;
    
    //显示内容的视图
    UIView* _contentView;
    //气泡视图
    UIView* _bubbleView;
    //气泡视图遮掩层
    UIView* _bubbleViewMask;
    
    //消息是否我方发起
    BOOL _fromSelf;
    //会话编号
    uint64_t _callId;
    
    //长按气泡视图手势
    UILongPressGestureRecognizer* _bubbleViewLongPressRecognizer;
}
@end

@implementation ChatCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _audioButtonSize = CGSizeMake(30, 30);
        _playingAudioButtonSize = CGSizeMake(30, 30);
    }
    return self;
}

//- (void)insertImage:(UIImage*)image imageType:(CHAT_IMAGE_TYPE)imageType attributedString:(NSMutableAttributedString*)attributedString font:(UIFont*)uiFont usingScaleSize:(CGSize)scaleSize forTag:(NSString*)tag
//{
//    ChatRenderingCache* cache = [ChatRenderingCache sharedCache];
//    
//    //获取全局单实例锁对象
//    static dispatch_once_t pred = 0;
//    __strong static NSString* lock = nil;
//    dispatch_once(&pred, ^{
//        lock = @"LOCK";
//    });
//
//    //在缓存中查找图片资源，如果不存在则进行加载
//    @synchronized(lock) {
//        CoreTextImageData* chatImage = [cache chatImageForTag:tag];
//        if(!chatImage) {
//            if(scaleSize.width == CGSizeZero.width && scaleSize.height == CGSizeZero.height) {
//                chatImage = [[CoreTextImageData alloc] initWithImage:image forTag:tag];
//            } else {
//                chatImage = [[CoreTextImageData alloc] initWithImage:image UsingScaleSize:scaleSize forTag:tag];
//            }
//            [cache addChatImage:chatImage];
//        }
//        chatImage.descender = uiFont.descender;
//        chatImage.imageType = imageType;
//    }
//    
//    //为图片设置CTRunDelegate,delegate决定留给图片的空间大小
//    CTRunDelegateCallbacks imageCallbacks;
//    imageCallbacks.version      = kCTRunDelegateVersion1;
//    imageCallbacks.dealloc      = RunDelegateDeallocCallback;
//    imageCallbacks.getAscent    = RunDelegateGetAscentCallback;
//    imageCallbacks.getDescent   = RunDelegateGetDescentCallback;
//    imageCallbacks.getWidth     = RunDelegateGetWidthCallback;
//    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, (__bridge_retained void *)(tag));
//    
//    NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:@" "];//空格用于给图片留位置
//    [imageAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:NSMakeRange(0, 1)];
//    CFRelease(runDelegate);
//    
//    //设置图片唯一标识属性
//    [imageAttributedString addAttribute:CHAT_IMAGE_TAG_NAME value:tag range:NSMakeRange(0, 1)];
//    
//    //追加属性字符串
//    [attributedString appendAttributedString:imageAttributedString];
//}

///*计算内容的显示区域大小
// * @param ctFramesetter
// * @param size 最大区域范围
// * @return 显示区域大小
// */
//- (CGSize)suggestSizeFrameSizeWithFramesetter:(CTFramesetterRef)ctFramesetter size:(CGSize)size
//{
//    //CGSize suggestSize =CTFramesetterSuggestFrameSizeWithConstraints(ctFramesetter,CFRangeMake(0, 0), NULL, maxSize, NULL); //该方法有BUG，别用
//    
//    //创建绘图路径并把设置矩形参数
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRect(path, NULL, CGRectMake(0.0, 0.0, size.width, size.height));
//    
//    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, 0), path, NULL); //创建一个帧并在上下文执行绘制文本
//    
//    NSArray *lines = (__bridge NSArray *) CTFrameGetLines(ctFrame); //获取帧中所有行
////    NSLog(@"line count = %i", lines.count);
//    
//    //获取各行的起始坐标
//    CGPoint lineOrigins[lines.count];
//    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
//    
//    CGFloat ascent;
//    CGFloat descent;
//    CGFloat leading;
//    CGFloat maxWidth = 0.0;
//    CGFloat totalHeight = 0.0;
//    int i =0;
//    //循环每一行找出最大宽度及总高度
//    for(i=0; i<lines.count; i++) {
//        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
//        double width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
//        if(maxWidth < width)
//            maxWidth = width;
//        
//        if(i == lines.count-1) { //最后一行
//            totalHeight = size.height - lineOrigins[i].y + descent;
//        }
//    }
//    
//    CFRelease(ctFrame);
//    CFRelease(path);
//    
//    return CGSizeMake(maxWidth, totalHeight);
//}

//进度视图标识
#define PROGRESS_VIEW_TAG 130

//显示富文本信息内容
- (BOOL)showRichInfoMessage:(EBMessage*)message bubbleView:(UIView*)bubbleView foregroundColor:(UIColor*)foregroundColor
{
//    //格式化显示时间
//    NSString* dateString = [message.msgTime stringByFlexibleFormat];
//    NSMutableAttributedString* timeAttrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", dateString]];
//    [timeAttrStr addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor colorWithHexString:@"#9eccdd"].CGColor range:NSMakeRange(0, dateString.length+1)];
//    [attributedString appendAttributedString:timeAttrStr];

    //创建消息内容视图
    BOOL hasGesture = [self prepareView:bubbleView message:message fromSelf:_fromSelf foregroundColor:foregroundColor];
    
    if (message.isSentFailure) { //发送失败状态
        [self setMessageState:CHAT_CELL_MESSAGE_STATE_FAILURE];
    } else if (message.isSent) { //发送成功状态
        [self setMessageState:CHAT_CELL_MESSAGE_STATE_COMPLETE];
    } else { //正在发送
        if ([self.delegate chatCell:self isSendingMessage:message]) {
            [self setMessageState:CHAT_CELL_MESSAGE_STATE_LOADING];
        }
    }
    
    return hasGesture;
}

//显示文件消息内容
- (void)showFileMessage:(EBMessage*)message bubbleView:(UIView*)bubbleView foregroundColor:(UIColor*)foregroundColor
{
    BOOL isShowProgress = !message.isSent && !message.isSentFailure && !message.cancelled && !message.rejected && message.isWorking; //判断是否显示进度条
    BOOL canCancel = (_fromSelf && !message.acked && !message.cancelled && message.waittingAck) || message.isWorking; //判断是否显示"取消"按钮
    BOOL offChat = canCancel && _fromSelf && !message.offChat; //判断是否显示“离线发送”按钮
    BOOL needReceiveAck = !_fromSelf && !message.acked && message.waittingAck && !message.cancelled; //判断是否显示“接收”和“拒绝”文件的按钮
    
    CGFloat progressHeight = isShowProgress?30.0:0.0; //进度条占位高度
    CGFloat otherWidth = 75.0; //其它内容占位宽度
    CGFloat screenSpaceWidth = 110.0; //屏幕横向间隙
//    CGFloat minContentViewWidth = 320.f - screenSpaceWidth; //内容最小宽度
    CGFloat contentViewWidth = [UIScreen mainScreen].bounds.size.width - screenSpaceWidth; //消息内容宽度
    UIFont* fileNameFont = [UIFont systemFontOfSize:13.0]; //文件名控件字体
    UIFont* buttonFont = [UIFont systemFontOfSize:13.0]; //按钮标题字体
    NSLineBreakMode lineBreakMode = NSLineBreakByCharWrapping; //断行模式
    NSString * fileName = [NSString stringWithFormat:@"%@", message.fileName]; //文件名
    
    //定义计算文本显示长度
    CGSize(^calculBLock)(UIFont* font, CGSize maxSize, NSLineBreakMode lineBreakMode, NSString* content) = ^(UIFont* font, CGSize maxSize, NSLineBreakMode lbMode, NSString* content) {
        CGSize size;
        if (IOS7) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = lbMode;
            NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:[paragraphStyle copy]};
            size = [content boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil].size; //文件名控件尺寸
            
            size.height = ceil(size.height);
            size.width = ceil(size.width);
        } else {
            size = [content sizeWithFont:font constrainedToSize:maxSize lineBreakMode:lbMode];
        }
        
        return size;
    };
    
    //计算文件名显示尺寸
    const CGSize maxSize = CGSizeMake(contentViewWidth - otherWidth, CHAT_CONTENT_MAX_HEIGHT); //最大尺寸
    CGSize fileNameLabelSize = calculBLock(fileNameFont, maxSize, lineBreakMode, fileName);
    
//    NSLineBreakMode lineBreakMode = NSLineBreakByCharWrapping; //断行模式
//    if (IOS7) {
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//        paragraphStyle.lineBreakMode = lineBreakMode;
//        NSDictionary *attributes = @{NSFontAttributeName:fileNameFont, NSParagraphStyleAttributeName:paragraphStyle.copy};
//        fileNameLabelSize = [fileName boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil].size; //文件名控件尺寸
//        
//        fileNameLabelSize.height = ceil(fileNameLabelSize.height);
//        fileNameLabelSize.width = ceil(fileNameLabelSize.width);
//    } else {
//        fileNameLabelSize = [fileName sizeWithFont:fileNameFont constrainedToSize:maxSize lineBreakMode:lineBreakMode];
//    }
    
    //重新计算内容视图宽度
    CGFloat contentLeftSpace = _fromSelf?CHAT_FILE_CONTENT_HORI_SPACE*0.0:CHAT_FILE_CONTENT_HORI_SPACE; //左边缝隙
    contentViewWidth = (otherWidth + fileNameLabelSize.width + contentLeftSpace);//<minContentViewWidth?minContentViewWidth:(otherWidth + fileNameLabelSize.width);
    
    //内容视图大小
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentViewWidth, fileNameLabelSize.height+progressHeight+40)];
    
    //显示文件头像图标
    UIImage* image = [UIImage imageNamed:@"folder"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO]; //禁止自动产生约束
    [_contentView addSubview:imageView];
    
    //显示文件名
    UILabel* fileNameLabel = [[UILabel alloc] init];
    fileNameLabel.textColor = foregroundColor;
    fileNameLabel.font = fileNameFont;
    fileNameLabel.text = fileName;
    fileNameLabel.lineBreakMode = lineBreakMode;
    fileNameLabel.numberOfLines = 0;
//    fileNameLabel.preferredMaxLayoutWidth = fileNameLabelSize.width;
    [fileNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO]; //禁止自动产生约束
    [_contentView addSubview:fileNameLabel];
    //添加点击事件
    UITapGestureRecognizer *tapGestureOpen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openFile)];
    [fileNameLabel addGestureRecognizer:tapGestureOpen];
    [fileNameLabel setUserInteractionEnabled:YES];

    
    //显示文件容量大小
    UILabel* fileSizeLabel = [[UILabel alloc] init];
    fileSizeLabel.textColor = [UIColor lightGrayColor];
    fileSizeLabel.font = [UIFont systemFontOfSize:12.0];
    
    double size = ((double)message.fileSize)/1024;
    NSString* sizeText;
    if (size>1024) {
        sizeText = [NSString stringWithFormat:@"%.1fMB", size/1024];
    } else {
        sizeText = [NSString stringWithFormat:@"%.1fKB", size];
    }
    fileSizeLabel.text = sizeText;
    [fileSizeLabel setTranslatesAutoresizingMaskIntoConstraints:NO]; //禁止自动产生约束
    [_contentView addSubview:fileSizeLabel];
    CGSize fileSizeLabelSize = calculBLock(fileSizeLabel.font, maxSize, lineBreakMode, sizeText); //计算文件容量控件的尺寸
    
//    if (IOS7) {
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//        paragraphStyle.lineBreakMode = lineBreakMode;
//        NSDictionary *attributes = @{NSFontAttributeName:fileSizeLabel.font, NSParagraphStyleAttributeName:paragraphStyle.copy};
//        fileSizeLabelSize = [sizeText boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil].size; //控件尺寸
//        
//        fileSizeLabelSize.height = ceil(fileSizeLabelSize.height);
//        fileSizeLabelSize.width = ceil(fileSizeLabelSize.width);
//    } else {
//        fileSizeLabelSize = [sizeText sizeWithFont:fileSizeLabel.font constrainedToSize:maxSize lineBreakMode:lineBreakMode];
//    }
    
    //显示"接收"和“拒绝”文件
    UIButton* receiveButton;
    UIButton* rejectButton;
    if(needReceiveAck) {
        //receiveButton
        receiveButton = [UIButton buttonWithType:IOS7?UIButtonTypeSystem:UIButtonTypeRoundedRect];
        [receiveButton setTitle:@"接收" forState:UIControlStateNormal];
        receiveButton.titleLabel.font = buttonFont;
        [receiveButton setTranslatesAutoresizingMaskIntoConstraints:NO]; //禁止自动产生约束
        [_contentView addSubview:receiveButton];
        
        [receiveButton addTarget:self action:@selector(receiveFile) forControlEvents:UIControlEventTouchUpInside];
        
        //rejectButton
        rejectButton = [UIButton buttonWithType:IOS7?UIButtonTypeSystem:UIButtonTypeRoundedRect];
        [rejectButton setTitle:@"拒绝" forState:UIControlStateNormal];
        rejectButton.titleLabel.font = buttonFont;
        [rejectButton setTranslatesAutoresizingMaskIntoConstraints:NO]; //禁止自动产生约束
        [_contentView addSubview:rejectButton];
        
        [rejectButton addTarget:self action:@selector(rejectFile) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //显示"取消"按钮
    UIButton* cancelButton;
    if (canCancel) {
        cancelButton = [UIButton buttonWithType:IOS7?UIButtonTypeSystem:UIButtonTypeRoundedRect];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        cancelButton.titleLabel.font = buttonFont;
        [cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO]; //禁止自动产生约束
        [_contentView addSubview:cancelButton];
        
        [cancelButton addTarget:self action:@selector(cancelFile) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //显示"离线发送"按钮
    UIButton* offChatButton;
    if (offChat) {
        offChatButton = [UIButton buttonWithType:IOS7?UIButtonTypeSystem:UIButtonTypeRoundedRect];
        [offChatButton setTitle:@"离线发送" forState:UIControlStateNormal];
        offChatButton.titleLabel.font = buttonFont;
        [offChatButton setTranslatesAutoresizingMaskIntoConstraints:NO]; //禁止自动产生约束
        [_contentView addSubview:offChatButton];
        
        [offChatButton addTarget:self action:@selector(resendFileOffChat) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //完成状况
    UILabel* completionStateLabel = [[UILabel alloc] init];
    completionStateLabel.text = @"";
    completionStateLabel.textColor = [UIColor lightGrayColor];
    completionStateLabel.font = [UIFont systemFontOfSize:12.0];
    if (message.isSent)
        completionStateLabel.text = @"已完成";
    else if (message.isSentFailure)
        completionStateLabel.text = @"已失败";
    else if (message.rejected)
        completionStateLabel.text = @"已拒绝";
    else if (message.cancelled)
        completionStateLabel.text = @"已取消";
    else if (message.uploaded)
        completionStateLabel.text = @"离线文件成功";
    else if (!_fromSelf && !message.acked && message.waittingAck)
        completionStateLabel.text = @"等待接收";
    else if (!message.isWorking && (message.acked || !message.waittingAck))
        completionStateLabel.text = @"已失败";
    
    [completionStateLabel setTranslatesAutoresizingMaskIntoConstraints:NO]; //禁止自动产生约束
    [_contentView addSubview:completionStateLabel];
    
    //计算显示完成状态控件的尺寸
    CGSize completionStateLabelSize = calculBLock(completionStateLabel.font, maxSize, lineBreakMode, completionStateLabel.text);
    
    //进度条
    ASProgressPopUpView* proView;
    if (isShowProgress) {
        proView = [[ASProgressPopUpView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [proView setTag:PROGRESS_VIEW_TAG];
        
        proView.font = [UIFont systemFontOfSize:10.0];
        proView.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
        proView.popUpViewCornerRadius = 2.0;
        proView.dataSource = self;
        [proView showPopUpViewAnimated:YES];
        [proView setProgress:message.percentCompletion/100 animated:YES];
        
        [proView setTranslatesAutoresizingMaskIntoConstraints:NO]; //禁止自动产生约束
        [_contentView addSubview:proView];
    }
    
//    //显示时间
//    UILabel* timeLabel = [[UILabel alloc] init];
//    timeLabel.textColor = [UIColor colorWithHexString:@"#9eccdd"];
//    timeLabel.font = [UIFont systemFontOfSize:12.0];
//    timeLabel.text = [message.msgTime stringByFlexibleFormat];
//    [timeLabel setTranslatesAutoresizingMaskIntoConstraints:NO]; //禁止自动产生约束
//    [_contentView addSubview:timeLabel];
    
    //按钮尺寸常量
    const CGFloat buttonWidth = 40;
    const CGFloat buttonHeight = 20;
    
    //计算约束的参数
    NSDictionary* metrics = @{@"sizeOfImageView":@40, @"hButton":@(buttonWidth), @"vButton":@(buttonHeight), @"contentLeftSpace":@(contentLeftSpace), @"completionStateRightSpace":@(_fromSelf?CHAT_FILE_CONTENT_HORI_SPACE:0)};
    NSMutableDictionary* views = [@{@"imageView":imageView, @"fileNameLabel":fileNameLabel, @"fileSizeLabel":fileSizeLabel, /*@"timeLabel":timeLabel,*/ @"completionStateLabel":completionStateLabel} mutableCopy];
    
    CGFloat controlWidth = fileSizeLabelSize.width; //按钮控件累加宽度
    if (needReceiveAck) {
        views[@"receiveButton"] = receiveButton;
        views[@"rejectButton"] = rejectButton;
        controlWidth = controlWidth + (buttonWidth*2) + 5;
    }
    if (canCancel) {
        views[@"cancelButton"] = cancelButton;
        controlWidth += buttonWidth;
    }
    if (offChat) {
        views[@"offChatButton"] = offChatButton;
        controlWidth += 80;
    }
    if (isShowProgress) {
        views[@"proView"] = proView;
    }
    
    //计算修正内容视图宽度
    CGFloat finalWidth = fileNameLabelSize.width + 5;
    if (controlWidth > finalWidth)
        finalWidth = controlWidth;
    if (completionStateLabelSize.width > finalWidth)
        finalWidth = completionStateLabelSize.width;
    //执行修正
    if (finalWidth!=fileNameLabelSize.width) {
        contentViewWidth = otherWidth + finalWidth + contentLeftSpace;
        CGRect rect = _contentView.frame;
        _contentView.frame = CGRectMake(rect.origin.x, rect.origin.y, contentViewWidth, rect.size.height);
    }
    
    //=====生成约束=====
    
    //图片视图与文件名视图(横向)
    NSArray* contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"|-contentLeftSpace-[imageView(sizeOfImageView)]-5-[fileNameLabel]-(>=5)-|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views];
    [_contentView addConstraints:contrains];
    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView(sizeOfImageView)]" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views];
    [_contentView addConstraints:contrains];
    
    //图片视图与文件容量大小视图(横向)，文件名与文件容量大小(纵向)
    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"[imageView]-5-[fileSizeLabel]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
    [_contentView addConstraints:contrains];
    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[fileNameLabel]-0-[fileSizeLabel]" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views];
    [_contentView addConstraints:contrains];
    
    //完成状态视图(横向)，文件名视图与完成状态视图(纵向)
    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"[completionStateLabel]-completionStateRightSpace-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
//    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"[completionStateLabel]-(-2)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
    [_contentView addConstraints:contrains];
    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[completionStateLabel]-0-|" options:0 metrics:metrics views:views];
//    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[fileNameLabel]-0-[completionStateLabel]" options:0 metrics:metrics views:views];
    [_contentView addConstraints:contrains];
    
    //"拒绝"按钮与文件大小视图(横向)，文件名视图与"拒绝"按钮(纵向)
    if (receiveButton) {
        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"[fileSizeLabel]-[receiveButton(hButton)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
        [_contentView addConstraints:contrains];
        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[fileNameLabel]-0-[receiveButton(vButton)]" options:0 metrics:metrics views:views];
        [_contentView addConstraints:contrains];
    }
    
    //"接受"按钮与"拒绝"按钮(横向)，文件名视图与"接受"按钮(纵向)
    if (receiveButton && rejectButton) {
        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"[receiveButton]-[rejectButton(hButton)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
        [_contentView addConstraints:contrains];
        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[fileNameLabel]-0-[rejectButton(vButton)]" options:0 metrics:metrics views:views];
        [_contentView addConstraints:contrains];
    }
    
    //取消按钮与完成状态视图(横向)，文件名视图与取消按钮(纵向)
    if (offChatButton) {
        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"[cancelButton]-[offChatButton(65)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
//                contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"[cancelButton(hButton)]-[completionStateLabel]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
        [_contentView addConstraints:contrains];
        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[fileNameLabel]-0-[offChatButton(vButton)]" options:0 metrics:metrics views:views];
        [_contentView addConstraints:contrains];
    }
    
    //"离线发送"按钮与"取消"按钮(横向)，文件名视图与"离线发送"按钮(纵向)
    if (cancelButton) {
        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"[fileSizeLabel]-5-[cancelButton(hButton)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
        [_contentView addConstraints:contrains];
        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[fileNameLabel]-0-[cancelButton(vButton)]" options:0 metrics:metrics views:views];
        [_contentView addConstraints:contrains];
    }
    
    //进度条(横向)、图片视图与进度条(纵向)
    if (isShowProgress) {
        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"[imageView]-10-[proView]-10-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
        [_contentView addConstraints:contrains];
        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[fileSizeLabel]-30-[proView(3)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
        [_contentView addConstraints:contrains];
    }
    
//    //时间视图(横向)、时间视图(纵向)
//    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"[timeLabel]-0-|" options:NSLayoutFormatAlignAllRight metrics:metrics views:views];
//    [_contentView addConstraints:contrains];
//    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[timeLabel]-0-|" options:NSLayoutFormatAlignAllRight metrics:metrics views:views];
//    [_contentView addConstraints:contrains];
    
    //==============
    
    //气泡背景图片
    UIImage *bubbleImage = [UIImage imageNamed:_fromSelf?@"bubble_right":@"bubble_left"];
    //设置图片不拉伸边缘范围
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[bubbleImage stretchableImageWithLeftCapWidth:45 topCapHeight:40]];
    [backgroundImageView setFrame:CGRectMake( 0.0f, 0.0f, _contentView.bounds.size.width + (CHAT_FILE_CONTENT_HORI_SPACE*2), _contentView.bounds.size.height + (CHAT_CONTENT_VERT_SAPCE*2) )];
    
    [bubbleView addSubview:backgroundImageView];
    [bubbleView addSubview:_contentView];
    //设置内容视图中心点与气泡背景重合
    [_contentView setCenter:backgroundImageView.center];
    
    bubbleView.backgroundColor = [UIColor clearColor];
    
    [self autolayout:bubbleView size:backgroundImageView.bounds.size];
}

- (void)setContent:(EBMessage*)message fromSelf:(BOOL)fromSelf
{
    _fromSelf = fromSelf;
    _callId = message.callId;
    
    _message = message;
    if (message.msgId)
        self.msgId = message.msgId;
    
    _bubbleView = [self viewWithTag:102];
    
    //清空旧视图
    for (UIView *subView in _bubbleView.subviews) {
        //停止gif动画
        if ([subView isMemberOfClass:GifView.class])
            [((GifView*)subView) stopAnimation];
        
        [subView removeFromSuperview];
    }
    
    //清空消息发送方名称
    if (!fromSelf && self.isGroup)
        [self updateMemberNameLabel:@" "];
    else
        [self updateMemberNameLabel:nil];
    
    //清空状态
    [self setMessageState:CHAT_CELL_MESSAGE_STATE_CLEAR];
    
    //前台颜色
    UIColor* foregroundColor = EBCHAT_DEFAULT_FONT_COLOR; //[UIColor colorWithHexString:*@"#194e62"];
//    if (fromSelf)
//        foregroundColor = [UIColor colorWithHexString:@"#18611f"];
    
    //是否已设置手势事件
    BOOL hasGesture = NO;
    
    if (message.isFile) { //文件消息
        [self showFileMessage:message bubbleView:_bubbleView foregroundColor:foregroundColor];
    } else { //富文本消息
        hasGesture = [self showRichInfoMessage:message bubbleView:_bubbleView foregroundColor:foregroundColor];
    }
    
    if (!hasGesture) {
        //移除旧的长按手势事件
        if (_bubbleViewLongPressRecognizer) {
            [self removeGestureRecognizer:_bubbleViewLongPressRecognizer];
            _bubbleViewLongPressRecognizer = nil;
        }
        
        //添加长按手势事件
        _bubbleViewLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedAction:)];
        [_bubbleView addGestureRecognizer:_bubbleViewLongPressRecognizer];
    }
    
//    [self setNeedsLayout];
//    [self layoutIfNeeded];
}

//打开文件
- (void)openFile
{
    if (self.msgId && [self.delegate respondsToSelector:@selector(chatCell:fileClick:)]) {
        [self.delegate chatCell:self fileClick:self.msgId];
    }
}

//定义 是否接收文件确认框Tag
const NSInteger tagOfReceiveFileAlertView = 200;

//确认接收文件
- (void)receiveFile
{
    Reachability* rby = [Reachability reachabilityForInternetConnection];
    if ([rby isReachableViaWWAN]) {
        [[PublicUI sharedInstance] showAlertViewWithTag:tagOfReceiveFileAlertView title:@"真的要接收文件吗？" message:@"设备当前使用3G/4G网络，接收文件将会使用比较多的流量，请留意！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认"];
    } else
        [self executeReceiveFile];
}

- (void)executeReceiveFile
{
    if (self.msgId && [self.delegate respondsToSelector:@selector(chatCell:ackReceiveFile:accept:)]) {
        [self.delegate chatCell:self ackReceiveFile:self.msgId accept:YES];
    }
}

//拒绝接收文件
- (void)rejectFile
{
    if (self.msgId && [self.delegate respondsToSelector:@selector(chatCell:ackReceiveFile:accept:)]) {
        [self.delegate chatCell:self ackReceiveFile:self.msgId accept:NO];
    }
}

//取消正在传输文件的动作
- (void)cancelFile
{
    if (self.msgId && _fromSelf && _callId) { //自己发起的正在发送文件的过程
        [[ENTBoostKit sharedToolKit] cancelSendingFileWithMsgId:self.msgId forCallId:_callId onCompletion:^{
            NSLog(@"取消发送文件成功");
        } onFailure:^(NSError *error) {
            NSLog(@"取消发送文件失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
        }];
    } else if (self.msgId && !_fromSelf) { //正在接收文件的过程
        if ([self.delegate respondsToSelector:@selector(chatCell:cancelReceivingFile:)]) {
            [self.delegate chatCell:self cancelReceivingFile:self.msgId];
        }
    }
}

//离线发送文件
- (void)resendFileOffChat
{
    if ([self.delegate respondsToSelector:@selector(chatCell:resendFileOffChat:forCallId:)]) {
        [self.delegate chatCell:self resendFileOffChat:self.msgId forCallId:_callId];
    }
}

- (void)updateProgress:(float)progress animated:(BOOL)animated
{
    ASProgressPopUpView* proView = (ASProgressPopUpView*)[self.contentView viewWithTag:PROGRESS_VIEW_TAG];
    if (proView)
        [proView setProgress:progress/100 animated:YES];
}

- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress
{
//    NSString *s;
//    if (progress < 0.2) {
//        s = @"Just starting";
//    } else if (progress > 0.4 && progress < 0.6) {
//        s = @"About halfway";
//    } else if (progress > 0.75 && progress < 1.0) {
//        s = @"Nearly there";
//    } else if (progress >= 1.0) {
//        s = @"Complete";
//    }
//    return s;
    return nil;
}

- (void)setMessageState:(CHAT_CELL_MESSAGE_STATE)messageState
{
    //清除旧视图
    for (UIView* view in [self.stateImageView subviews]) {
        if ([view isMemberOfClass:GifView.class])
            [((GifView*)view) stopAnimation];
        [view removeFromSuperview];
    }
    //清除旧描述
    self.stateLabel.text = nil;
    
    //设置新状态视图
    if (messageState == CHAT_CELL_MESSAGE_STATE_FAILURE) {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.stateImageView.bounds];
        imageView.image = [UIImage imageNamed:@"message_failure"];
        [self.stateImageView addSubview:imageView];
        
        self.stateLabel.text = @"未成功";
    } else if (messageState == CHAT_CELL_MESSAGE_STATE_LOADING) {
//        NSLog(@"self.stateImageView:%@", NSStringFromCGRect(self.stateImageView.frame));
        GifView* gifView = [[GifView alloc] initWithFrame:self.stateImageView.bounds];
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"loading" withExtension:@"gif"];
        [gifView setFileURL:fileUrl];
        [self.stateImageView addSubview:gifView];
        [gifView startAnimation];
        //待定，什么时候stop？防止内存泄露
    }
}

//视图自动布局(长度和宽度)
- (void)autolayout:(UIView*)bubbleView size:(CGSize)size
{
    NSArray* constraints = [bubbleView constraints];
    [constraints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLayoutConstraint* constraint = obj;
//        NSLog(@"first item = %@(attr:%i),  second item = %@(attr:%i), constant = %f", ((NSObject*)constraint.firstItem).class, constraint.firstAttribute, ((NSObject*)constraint.secondItem).class, constraint.secondAttribute, constraint.constant);
        //宽度约束
        if(constraint.firstItem == bubbleView && constraint.secondItem == nil && constraint.firstAttribute == NSLayoutAttributeWidth) {
//            NSLog(@"found the bubbleView's width constraint, constant = %f", constraint.constant);
            constraint.constant = size.width;
        }
        //高度约束
        if(constraint.firstItem == bubbleView && constraint.secondItem == nil && constraint.firstAttribute == NSLayoutAttributeHeight) {
//            NSLog(@"found the bubbleView's height constraint, constant = %f", constraint.constant);
            constraint.constant = size.height;
        }
    }];

//    NSLog(@"want to set size %@", NSStringFromCGSize(size));
//    bubbleView.bounds = CGRectMake(0, 0, size.width, size.height);
//    [self.contentView setNeedsLayout];
//    [self.contentView layoutIfNeeded];
//    NSLog(@"set size result %@", NSStringFromCGSize(bubbleView.bounds.size));

//    NSLog(@"bubbleView.bounds %@", NSStringFromCGRect(bubbleView.bounds));
}

- (void)playAudio
{
    NSLog(@"go to play audio...");
    AudioToolkit* aToolkit = [AudioToolkit sharedInstance];
    
    if (aToolkit.playing) {
        [aToolkit stopPlaying];
        NSLog(@"stop playing");
        
        if (self.msgId!=aToolkit.tag)
            [self playAudio];
    } else if (_chatAudio.data) {
        NSLog(@"_chatAudio.data.length = %@", @([_chatAudio.data length]));
        if (!_playVoiceAnimatedView) {
            _playVoiceAnimatedView = [[GifView alloc] initWithFrame:CGRectMake(0, 0, _playingAudioButtonSize.width, _playingAudioButtonSize.height)];
            [_playVoiceAnimatedView setFileURL:[[NSBundle mainBundle] URLForResource:_fromSelf?@"playingAudio_right":@"playingAudio_left" withExtension:@"gif"]];
            
            //设置点击事件
            _playVoiceAnimatedView.userInteractionEnabled = YES;
            UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAudio)];
            [_playVoiceAnimatedView addGestureRecognizer:tapRecognizer];
        }
        [_playVoiceBtn addSubview:_playVoiceAnimatedView];
        [_playVoiceBtn setImage:nil forState:UIControlStateNormal];
        [_playVoiceAnimatedView startAnimation];
        
        [aToolkit playData:_chatAudio.data tag:self.msgId delegate:self];
    }
}

/** 创建视图
 * @param bubbleView
 * @param message 消息
 * @param fromSelf 是否本用户发送的消息
 * @param foregroundColor 前台颜色
 * @return 是否已设置手势事件
 */
- (BOOL)prepareView:(UIView*)bubbleView message:(EBMessage*)message fromSelf:(BOOL)fromSelf foregroundColor:(UIColor*)foregroundColor
{
    CTFrameParserConfig* config = [CTFrameParserConfig sharedConfig];
    config.textColor = foregroundColor;
    
    EBChatAudio* audioDot;
    NSMutableArray *imageArray  = [[NSMutableArray alloc] init]; //图片缓存队列
    NSMutableArray *linkArray   = [[NSMutableArray alloc] init]; //链接缓存队列
    
    NSAttributedString *content = [CTFrameParser attributedStringWithMessage:message config:config chatAudio:&audioDot imageArray:imageArray linkArray:linkArray];
    CoreTextData *data = [CTFrameParser parseAttributedContent:content config:config imageArray:imageArray linkArray:linkArray];
    
    _chatAudio = audioDot;
    //语音消息
    if (audioDot) {
        CGFloat timeLengthLabelWidth  = 40.0;
        CGFloat timeLengthLabelHeight = 20.0;
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(CHAT_RICH_CONTENT_HORI_SAPCE, CHAT_CONTENT_VERT_SAPCE, _audioButtonSize.width+timeLengthLabelWidth+CHAT_RICH_CONTENT_HORI_SAPCE*0.0, _audioButtonSize.height)];
        
        //计算语音消息播放时长(WAV格式)
        int timeLength = 0;
        if (audioDot.byteSize>=44)
            timeLength = [MultimediaUtility timeLengthWithWaveData:audioDot.data];
        if (timeLength==0)
            NSLog(@"zero time length of audio message msgId = %llu", message.msgId);
        
        //播发按钮
        _playVoiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playVoiceImage = [UIImage imageNamed:fromSelf?@"audio_play_right":@"audio_play_left"];
        [_playVoiceBtn setImage:_playVoiceImage forState:UIControlStateNormal];
        [_playVoiceBtn addTarget:self action:@selector(playAudio) forControlEvents:UIControlEventTouchUpInside];
        
        //显示时长
        UILabel* timeLengthLabel = [[UILabel alloc] init];
        timeLengthLabel.text = [NSString stringWithFormat:@"%@''", @(timeLength)];
        timeLengthLabel.textColor = [UIColor grayColor];
        timeLengthLabel.textAlignment = NSTextAlignmentCenter;
        
        CGRect rect;
        if (fromSelf) {
            rect = CGRectMake(_contentView.bounds.size.width - _audioButtonSize.width, (_contentView.bounds.size.height-_audioButtonSize.height)/2, _audioButtonSize.width, _audioButtonSize.height);
            timeLengthLabel.frame = (CGRect){rect.origin.x-timeLengthLabelWidth, (_contentView.bounds.size.height-timeLengthLabelHeight)/2, timeLengthLabelWidth, timeLengthLabelHeight};
        } else {
            rect = CGRectMake(0, 0, _audioButtonSize.width, _audioButtonSize.height);
            timeLengthLabel.frame = (CGRect){rect.size.width, (_contentView.bounds.size.height-timeLengthLabelHeight)/2, timeLengthLabelWidth, timeLengthLabelHeight};
        }
        [_playVoiceBtn setFrame:rect];
        
        [_contentView addSubview:timeLengthLabel];
        [_contentView addSubview:_playVoiceBtn];
    } else { //其它消息
        //内容渲染后的尺寸
        CGSize suggestSize = data.size;
        
        //信息内容视图
        ChatView* chatView = [[ChatView alloc] initWithCoreTextData:data frame:CGRectMake(fromSelf?CHAT_RICH_CONTENT_HORI_SAPCE*0.5:CHAT_RICH_CONTENT_HORI_SAPCE, CHAT_CONTENT_VERT_SAPCE, ceilf(suggestSize.width), ceilf(suggestSize.height))];
//        ChatView* chatView = [[ChatView alloc] initWithCTFramesetterRef:data.ctFramesetter andFrame:CGRectMake(fromSelf?CHAT_RICH_CONTENT_HORI_SAPCE*0.5:CHAT_RICH_CONTENT_HORI_SAPCE, CHAT_CONTENT_VERT_SAPCE, ceilf(suggestSize.width), ceilf(suggestSize.height))];
        chatView.delegate = self;
        chatView.data = data;
        
        chatView.backgroundColor = [UIColor clearColor];
        _contentView = chatView;
    }
    
//    [contentView setBackgroundColor:[UIColor lightGrayColor]];
    
    //气泡背景图片
    UIImage *bubbleImage = [UIImage imageNamed:fromSelf?@"bubble_right":@"bubble_left"];
    //设置图片不拉伸边缘范围
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[bubbleImage stretchableImageWithLeftCapWidth:25 topCapHeight:40]];
    [backgroundImageView setFrame:CGRectMake( 0.0f, 0.0f, _contentView.bounds.size.width + (CHAT_RICH_CONTENT_HORI_SAPCE*2), _contentView.bounds.size.height + (CHAT_CONTENT_VERT_SAPCE*2) )];
    
    [bubbleView addSubview:backgroundImageView];
    [bubbleView addSubview:_contentView];
    //设置内容视图中心点与气泡背景重合
//    [_contentView setCenter:backgroundImageView.center];
    
//    _contentView.backgroundColor = [UIColor blueColor];
    bubbleView.backgroundColor = [UIColor clearColor];
    
    [self autolayout:bubbleView size:backgroundImageView.bounds.size];
    
    //如果是语音消息，表示未设置手势事件，返回NO
    return audioDot?NO:YES;
}

//- (CGSize)intrinsicContentSize
//{
//    return CGSizeMake(1, 1);
//}

- (void)updateMemberNameLabel:(NSString*)name
{
    UILabel* label = (UILabel*)[self.contentView viewWithTag:103];
    if (label) {
        self.nameLabel.text = name;
        
        //更新约束
        NSArray* constraints = [label constraints];
        [constraints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLayoutConstraint* constraint = obj;
            //高度约束
            if(constraint.firstItem == label && constraint.secondItem == nil && constraint.firstAttribute == NSLayoutAttributeHeight) {
                if (name && name.length)
                    constraint.constant = 20;
                else
                    constraint.constant = 0;;
            }
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == tagOfReceiveFileAlertView) { //处理 是否接收文件
        if (buttonIndex == 1)
            [self executeReceiveFile];
    }
}

#pragma mark - AudioToolkitDelegate
//播放结束事件
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"结束gif播放动画 DidFinish");
    
    [_playVoiceAnimatedView stopAnimation];
    [_playVoiceAnimatedView removeFromSuperview];
    [_playVoiceBtn setImage:_playVoiceImage forState:UIControlStateNormal];
//    [[AudioToolkit sharedInstance] setPlaying:NO];
//    [[AudioToolkit sharedInstance] setAudioSessionActive:NO];
}
//播放失败事件
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"结束gif播放动画 DecodeError");
    
//    GifView* gifView = (GifView*)[_playVoiceBtn viewWithTag:131];
    [_playVoiceAnimatedView stopAnimation];
    [_playVoiceAnimatedView removeFromSuperview];
    [_playVoiceBtn setImage:_playVoiceImage forState:UIControlStateNormal];
}

#pragma mark - ChatViewDelegate
//单击图片
- (void)chatView:(ChatView *)chatView imageTaped:(CoreTextImageData *)imageData
{
    //头像、表情资源不触发点击事件
    if (imageData.imageType!=CHAT_IMAGE_TYPE_RESOURCE && [self.delegate respondsToSelector:@selector(chatCell:imageClick:)]) {
        [self.delegate chatCell:self imageClick:imageData.image];
    }
}

//点击链接
- (void)chatView:(ChatView *)chatView linkTaped:(CoreTextLinkData *)linkData
{
    if ([self.delegate respondsToSelector:@selector(chatCell:linkClick:)])
        [self.delegate chatCell:self linkClick:linkData.url];
}

//双击视图
- (void)chatView:(ChatView *)chatView doubleTaped:(UITapGestureRecognizer *)recognizer data:(id)data
{
    
}

//长按手势，实现弹出菜单
- (void)chatView:(ChatView *)chatView longPressed:(UILongPressGestureRecognizer *)recognizer data:(id)data
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGRect rect = [self.contentView convertRect:_bubbleView.frame toView:self.talkTableView];
        
        NSMutableArray* canPerfromActions = [[NSMutableArray alloc] init];
        //"重发消息"菜单
        if (_message.isSentFailure && _message.msgId==0 && _message.tagId>0 && !_message.isFile)
            [canPerfromActions addObject:@(PopupChatTapMenuItemTagResend)];
        //"复制"菜单
        [canPerfromActions addObject:@(PopupChatTapMenuItemTagCopy)];
        //"删除"菜单
        if (!_message.isWorking)
            [canPerfromActions addObject:@(PopupChatTapMenuItemTagDelete)];
        
        //执行弹出菜单
        [[PublicUI sharedInstance] popupChatTapMenuInView:self.talkTableView fromRect:rect target:self selectedAction:@selector(chatTapMenuAction:) cancelAction:@selector(dismissBubbleMask:) canPerformActions:canPerfromActions];
        
        //遮盖选择区效果
        if (!_bubbleViewMask) {
            _bubbleViewMask =[[UIView alloc] initWithFrame:CGRectZero];
            _bubbleViewMask.backgroundColor = [UIColor blackColor];
            _bubbleViewMask.alpha = 0.2;
        }
        _bubbleViewMask.frame = (CGRect){0, 0, _bubbleView.bounds.size};
        [_bubbleView addSubview:_bubbleViewMask];
        [_bubbleView bringSubviewToFront:_bubbleViewMask];
    }
}

#pragma mark - PopupMenu Action

//长按手势事件处理
- (void)longPressedAction:(UILongPressGestureRecognizer *)recognizer
{
    [self chatView:nil longPressed:recognizer data:nil];
}

//处理点击弹出菜单事件
- (void)chatTapMenuAction:(id)object
{
    PopupMenuItem* menuItem = object;
    switch (menuItem.tag) {
        //复制
        case PopupChatTapMenuItemTagCopy:
        {
            if (_message) {
                //复制到通用剪贴板
                [self copyToPasteboardWithMessage:_message];
                //复制到专用剪贴板
                NSDictionary* msgKey = @{@"messageId":@(_message.msgId), @"tagId":@(_message.tagId)};//[CTFrameParser keyForMessage:_message];
                if (msgKey) {
                    UIPasteboard *pasteBoard2 = [UIPasteboard pasteboardWithName:ENTBOOST_PASTE_BOARD_NAME create:YES];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:msgKey];
                    [pasteBoard2 setValue:data forPasteboardType:ENTBOOST_PASTE_BOARD_TYPE_MESSAGE_KEY];
                }
            }
        }
            break;
        //删除
        case PopupChatTapMenuItemTagDelete:
        {
            if (_message) {
                if ([self.delegate respondsToSelector:@selector(chatCell:deletedMessage:tagId:)])
                    [self.delegate chatCell:self deletedMessage:_message.msgId tagId:_message.tagId];
            }
        }
            break;
        //重发消息
        case PopupChatTapMenuItemTagResend:
        {
            if (_message) {
                if ([self.delegate respondsToSelector:@selector(chatCell:resendMessageWithTagId:)])
                    [self.delegate chatCell:self resendMessageWithTagId:_message.tagId];
            }
        }
            break;
    }
}

//移除蒙板
- (void)dismissBubbleMask:(id)object
{
    if (_bubbleViewMask)
        [_bubbleViewMask removeFromSuperview];
}

//复制富文本消息到通用剪贴板
- (void)copyToPasteboardWithMessage:(EBMessage*)message
{
    NSArray* chats = message.chats; //获取富文本信息内容
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard]; //获取通用剪贴板
    pasteboard.string = @"";
    //    pasteboard.image  = [[UIImage alloc] init];
    //    pasteboard.images = @[];
    
    NSMutableString *textContent = [[NSMutableString alloc] init]; //保存文本内容
    UIImage* firstImage; //保存第一个图片对象
    //    NSMutableArray<UIImage*>  *images = [[NSMutableArray alloc] init]; //保存其它图片对象
    
    //解析富文本消息内容
    for (int idx = 0; idx<chats.count; idx++) {
        EBChat* chatDot = chats[idx];
        switch (chatDot.type) {
            case EB_CHAT_ENTITY_TEXT:
            {
                NSString* text = ((EBChatText*)chatDot).text;
                [textContent appendString:text];
            }
                break;
            case EB_CHAT_ENTITY_RESOURCE:
            {
                EBChatResource* resDot = (EBChatResource*)chatDot;
                EBEmotion* expression = resDot.expression;
                
                UIImage* image;
                if (expression.dynamicFilepath)
                    image = [UIImage imageWithContentsOfFile:expression.dynamicFilepath];
                else
                    image = [UIImage imageNamed:@"loading_emotion"];
                
                if (image) {
                    //                    if (firstImage)
                    //                        [images addObject:image];
                    //                    else
                    firstImage = image;
                }
            }
                break;
            case EB_CHAT_ENTITY_IMAGE:
            {
                EBChatImage* imageDot = (EBChatImage*)chatDot;
                UIImage* image = imageDot.image;
                
                if (image) {
                    //                    if (firstImage)
                    //                        [images addObject:image];
                    //                    else
                    firstImage = image;
                }
            }
                break;
            case EB_CHAT_ENTITY_AUDIO:
            {
                [textContent appendString:@"[语音]"];
            }
                break;
        }
    }
    
    //复制内容至剪贴板
    if (textContent.length>0)
        pasteboard.string = textContent;
    if (firstImage)
        pasteboard.image = firstImage;
    //    if (images.count>0)
    //        pasteboard.images = images;
}

@end
