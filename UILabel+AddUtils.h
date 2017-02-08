//
//  UILabel+AddUtils.h
//  TouTiao_student
//
//  Created by guanglong on 16/3/29.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (AddUtils)

- (void)xtt_setText:(NSString *)text lineSpace:(CGFloat)lineSpace;
- (void)xtt_asyncSetText:(NSString *)text lineSpace:(CGFloat)lineSpace;
- (void)xtt_asyncSetText:(NSString *)text lineSpace:(CGFloat)lineSpace complete:(void(^)())complete;

- (void)xtt_setText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString*)markedText markedTextColor:(UIColor*)markedTextColor;
- (void)xtt_asyncSetText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString*)markedText markedTextColor:(UIColor*)markedTextColor;
- (void)xtt_asyncSetText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString*)markedText markedTextColor:(UIColor*)markedTextColor complete:(void(^)())complete;

- (void)xtt_setText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString *)markedText markedTextColor:(UIColor *)markedTextColor markedRange:(NSRange)markedRange;
- (void)xtt_asyncSetText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString *)markedText markedTextColor:(UIColor *)markedTextColor markedRange:(NSRange)markedRange;
- (void)xtt_asyncSetText:(NSString *)text lineSpace:(CGFloat)lineSpace markedText:(NSString *)markedText markedTextColor:(UIColor *)markedTextColor markedRange:(NSRange)markedRange complete:(void (^)())complete;


+ (UILabel*)xtt_labelWithBackgroundColor:(UIColor *)backgroundColor
                       textAlignment:(NSTextAlignment)textAlignment
                                font:(UIFont*)font
                           textColor:(UIColor*)textColor
                       numberOfLines:(NSInteger)numberOfLines;


@end
