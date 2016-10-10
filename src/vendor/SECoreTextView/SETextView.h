//
//  SETextView.h
//  SECoreTextView
//
//  Created by kishikawa katsumi on 2013/04/20.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "SELinkText.h"
#import "SETextAttachment.h"
#import "SECompatibility.h"
#import "NSMutableAttributedString+Helper.h"

typedef void(^SETextAttachmentDrawingBlock)(CGRect rect, CGContextRef context);

typedef NS_ENUM(NSUInteger, SETextAttachmentDrawingOptions) {
    SETextAttachmentDrawingOptionNone = 0,
    SETextAttachmentDrawingOptionNewLine  = 1 << 0
};

@protocol SETextViewDelegate;

@class SELinkText;

#if TARGET_OS_IPHONE
@interface SETextView : UIView <UITextInput, UITextInputTraits>
#else
@interface SETextView : NSView
#endif

@property (nonatomic, weak) IBOutlet id<SETextViewDelegate> delegate;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSAttributedString *attributedText;

@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *highlightedTextColor;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) CTLineBreakMode lineBreakMode;
@property (nonatomic) CGFloat lineSpacing;
@property (nonatomic) CGFloat lineHeight;
@property (nonatomic) CGFloat paragraphSpacing;
@property (nonatomic) CGFloat firstLineHeadIndent;
@property (nonatomic) CGFloat lineHeightMultiple;

@property (nonatomic) UIColor *selectedTextBackgroundColor;
@property (nonatomic) UIColor *linkHighlightColor;
@property (nonatomic) UIColor *linkRolloverEffectColor;

@property (nonatomic, readonly) CGRect layoutFrame;

@property (nonatomic, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, getter = isSelectable) BOOL selectable;
#if TARGET_OS_IPHONE
@property (nonatomic) BOOL showsEditingMenuAutomatically;
#endif

#if TARGET_OS_IPHONE
@property (nonatomic) NSRange selectedRange;
#else
@property (nonatomic, readonly) NSRange selectedRange;
#endif
@property (nonatomic, readonly) NSString *selectedText;
@property (nonatomic, readonly) NSAttributedString *selectedAttributedText;

@property (nonatomic) NSTimeInterval minimumLongPressDuration;

@property (nonatomic, getter = isEditable) BOOL editable;
@property (nonatomic, readonly, getter = isEditing) BOOL editing;
@property (nonatomic, readonly) CGRect caretRect;

@property (readwrite) UIView *inputView;
@property (readwrite) UIView *inputAccessoryView;

#if TARGET_OS_IPHONE
@property (nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (nonatomic) UITextAutocorrectionType autocorrectionType;
@property (nonatomic) UITextSpellCheckingType spellCheckingType;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic) UIKeyboardAppearance keyboardAppearance;
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic) BOOL enablesReturnKeyAutomatically;
@property (nonatomic, getter = isSecureTextEntry) BOOL secureTextEntry;
#endif

- (id)initWithFrame:(CGRect)frame;

+ (CGRect)frameRectWithAttributtedString:(NSAttributedString *)attributedString
                          constraintSize:(CGSize)constraintSize;
+ (CGRect)frameRectWithAttributtedString:(NSAttributedString *)attributedString
                          constraintSize:(CGSize)constraintSize
                             lineSpacing:(CGFloat)lineSpacing;
+ (CGRect)frameRectWithAttributtedString:(NSAttributedString *)attributedString
                          constraintSize:(CGSize)constraintSize
                             lineSpacing:(CGFloat)lineSpacing
                                    font:(UIFont *)font;
+ (CGRect)frameRectWithAttributtedString:(NSAttributedString *)attributedString
                          constraintSize:(CGSize)constraintSize
                             lineSpacing:(CGFloat)lineSpacing
                        paragraphSpacing:(CGFloat)paragraphSpacing
                                    font:(UIFont *)font;

- (void)addObject:(id)object size:(CGSize)size atIndex:(NSInteger)index customData:(NSDictionary*)customData;
- (void)addObject:(id)object size:(CGSize)size replaceRange:(NSRange)range customData:(NSDictionary*)customData;
#if TARGET_OS_IPHONE
///在末尾追加文本
- (void)insertAttributedText:(NSAttributedString *)attributedText;
///在尾部插入一个对象(一般是图片)
- (void)insertObject:(id)object size:(CGSize)size customData:(NSDictionary*)customData;
#endif

///清除选中状态
- (void)clearSelection;

///删除所有内容
- (void)clearAll;

///设置开始编辑状态，输入框将被设置为焦点
- (void)beginEditing;

///删除光标前的字符
- (void)deleteBackward;

@end

@protocol SETextViewDelegate <NSObject>

@optional
- (BOOL)textViewShouldBeginEditing:(SETextView *)textView;
- (BOOL)textViewShouldEndEditing:(SETextView *)textView;

- (void)textViewDidBeginEditing:(SETextView *)textView;
- (void)textViewDidEndEditing:(SETextView *)textView;

- (BOOL)textView:(SETextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(SETextView *)textView;

- (void)textViewDidChangeSelection:(SETextView *)textView;
- (void)textViewDidEndSelecting:(SETextView *)textView;

//- (BOOL)textView:(SETextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange;
//- (BOOL)textView:(SETextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange;

- (BOOL)textView:(SETextView *)textView clickedOnLink:(SELinkText *)link atIndex:(NSUInteger)charIndex;
- (BOOL)textView:(SETextView *)textView longPressedOnLink:(SELinkText *)link atIndex:(NSUInteger)charIndex;

/**粘贴内容事件
 * @param textView
 * @param sender
 * @return 外部执行结果：NO=内部不要执行默认操作；YES=内部要执行默认操作
 */
- (BOOL)textView:(SETextView *)textView paste:(id)sender;

//粘贴消息的回调事件
- (void)textView:(SETextView *)textView customPasteMessage:(id)sender;

@end
