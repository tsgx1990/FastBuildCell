//
//  UIView+FastBuild.h
//  FastBuildCell
//
//  Created by guanglong on 2017/2/10.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+FastBuild.h"

@interface UIView (FastBuild)


@property (nonatomic, readonly) CGFloat fb_heightAfterInitialization;

- (CGFloat)fb_heightAfterInitializationWithContentWidth:(CGFloat)contentViewWidth;

- (void)fb_layoutAfterInitialization;

- (void)fb_layoutAfterInitializationWithContentWidth:(CGFloat)contentViewWidth;

- (void)fb_lsResetForModel:(NSObject *)model make:(void (^)(NSObject* m))makeBlock set:(void(^)(FBLineSpaceMaker* maker))setBlock;

@property (nonatomic, copy) void(^fb_clickBlock)(NSIndexPath* indexPath);
@property (nonatomic, copy) void(^fb_clickSenderBlock)(NSIndexPath* indexPath, id sender);
@property (nonatomic, copy) void(^fb_clickFlagBlock)(NSIndexPath* indexPath, NSInteger flag);
@property (nonatomic, copy) void(^fb_clickSenderFlagBlock)(NSIndexPath* indexPath, id sender, NSInteger flag);

// maybe overrided. 如果不重写，默认是view本身
@property (nonatomic, strong, readonly) UIView* fb_concernedContentView;

@end

@interface UIView()

// 在计算高度时指定 fb_concernedContentView 的宽度约束，不指定的话，将根据横屏或竖屏确定 fb_concernedContentView 的宽度
@property (nonatomic) CGFloat viewContentViewWidth;

// 在计算高度时制定 fb_concernedContentView 距左右的总边距，不指定的话，将根据横屏或竖屏确定 fb_concernedContentView 的宽度
@property (nonatomic) CGFloat viewContentViewHorizonMargin;
@property (nonatomic) CGFloat viewContentViewVerticalMargin;

@end
