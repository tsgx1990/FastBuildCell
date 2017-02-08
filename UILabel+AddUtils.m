//
//  UILabel+AddUtils.m
//  TouTiao_student
//
//  Created by guanglong on 16/3/29.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "UILabel+AddUtils.h"
#import <objc/runtime.h>

@interface UILabel()

@property (nonatomic, copy) NSString* xtt_flagText;

@end

@implementation UILabel (AddUtils)

#define kXtt_flagText   @"kXtt_flagText"

- (void)setXtt_flagText:(NSString *)xtt_flagText
{
    objc_setAssociatedObject(self, kXtt_flagText, xtt_flagText, OBJC_ASSOCIATION_COPY);
}

- (NSString *)xtt_flagText
{
    return objc_getAssociatedObject(self, kXtt_flagText);
}

- (void)xtt_setText:(NSString *)text lineSpace:(CGFloat)lineSpace
{
    self.attributedText = [self xtt_attributedStringFromText:text lineSpace:lineSpace];
}

- (void)xtt_asyncSetText:(NSString *)text lineSpace:(CGFloat)lineSpace
{
    [self xtt_asyncSetText:text lineSpace:lineSpace complete:nil];
}

- (void)xtt_asyncSetText:(NSString *)text lineSpace:(CGFloat)lineSpace complete:(void(^)())complete
{
    self.xtt_flagText = text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSAttributedString *attributedString = [self xtt_attributedStringFromText:text lineSpace:lineSpace];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([text isEqualToString:self.xtt_flagText]) {
                self.attributedText = attributedString;
                if (complete) {
                    complete();
                }
            }
            else {
                self.attributedText = nil;
            }
        });
    });
}

- (NSAttributedString*)xtt_attributedStringFromText:(NSString *)text lineSpace:(CGFloat)lineSpace
{
    NSString* filterText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!filterText.length) {
        return nil;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:filterText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];//调整行间距
    [paragraphStyle setLineBreakMode:self.lineBreakMode];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, filterText.length)];
    return attributedString;
}

- (void)xtt_setText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString*)markedText markedTextColor:(UIColor*)markedTextColor
{
    self.attributedText = [self xtt_attributedStringFromText:text lineSpace:lineSpace markedText:markedText markedTextColor:markedTextColor];
}

- (void)xtt_asyncSetText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString*)markedText markedTextColor:(UIColor*)markedTextColor
{
    [self xtt_asyncSetText:text lineSpace:lineSpace markedText:markedText markedTextColor:markedTextColor complete:nil];
}

- (void)xtt_asyncSetText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString *)markedText markedTextColor:(UIColor *)markedTextColor complete:(void (^)())complete
{
    [self xtt_asyncSetText:text lineSpace:lineSpace markedText:markedText markedTextColor:markedTextColor markedRange:NSMakeRange(NSNotFound, 0) complete:complete];
}

- (void)xtt_setText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString *)markedText markedTextColor:(UIColor *)markedTextColor markedRange:(NSRange)markedRange
{
    self.attributedText = [self xtt_attributedStringFromText:text lineSpace:lineSpace markedText:markedText markedTextColor:markedTextColor markedRange:markedRange];
}

- (void)xtt_asyncSetText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString *)markedText markedTextColor:(UIColor *)markedTextColor markedRange:(NSRange)markedRange
{
    [self xtt_asyncSetText:text lineSpace:lineSpace markedText:markedText markedTextColor:markedTextColor markedRange:markedRange complete:nil];
}

- (void)xtt_asyncSetText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString *)markedText markedTextColor:(UIColor *)markedTextColor markedRange:(NSRange)markedRange complete:(void (^)())complete
{
    self.xtt_flagText = text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSAttributedString * attributedString = [self xtt_attributedStringFromText:text lineSpace:lineSpace markedText:markedText markedTextColor:markedTextColor markedRange:markedRange];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([text isEqualToString:self.xtt_flagText]) {
                self.attributedText = attributedString;
                if (complete) {
                    complete();
                }
            }
            else {
                self.attributedText = nil;
            }
        });
    });
}

- (NSAttributedString*)xtt_attributedStringFromText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString*)markedText markedTextColor:(UIColor*)markedTextColor
{
    return [self xtt_attributedStringFromText:text lineSpace:lineSpace markedText:markedText markedTextColor:markedTextColor markedRange:NSMakeRange(NSNotFound, 0)];
}

- (NSAttributedString*)xtt_attributedStringFromText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString*)markedText markedTextColor:(UIColor*)markedTextColor markedRange:(NSRange)markedRange
{
    NSString* filterText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!filterText.length) {
        return nil;
    }
    
    NSString* filterMarkedText = [markedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!filterMarkedText.length) {
        return [self xtt_attributedStringFromText:text lineSpace:lineSpace];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:filterText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, filterText.length)];
    
    NSRange searchRange = markedRange;
    if (NSEqualRanges(markedRange, NSMakeRange(NSNotFound, 0))) {
        searchRange = NSMakeRange(0, filterText.length);
    }
    NSInteger maxLocation = searchRange.location + searchRange.length;
    while (1) {
        NSRange mRange = [filterText rangeOfString:filterMarkedText options:NSCaseInsensitiveSearch range:searchRange];
        if (mRange.location == NSNotFound) {
            break;
        }
        else {
            [attributedString addAttribute:NSForegroundColorAttributeName value:markedTextColor range:mRange];
            searchRange.location = mRange.location + mRange.length;
            searchRange.length = maxLocation - searchRange.location;
        }
    }
    return attributedString;
}

+ (UILabel *)xtt_labelWithBackgroundColor:(UIColor *)backgroundColor textAlignment:(NSTextAlignment)textAlignment font:(UIFont *)font textColor:(UIColor *)textColor numberOfLines:(NSInteger)numberOfLines
{
    UILabel* label = [[self alloc] init];
    label.text = @"";
    label.backgroundColor = backgroundColor;
    label.textAlignment = textAlignment;
    label.font = font;
    label.textColor = textColor;
    label.numberOfLines = numberOfLines;
    return label;
}

@end
