//
//  UIView+FastBuild.m
//  FastBuildCell
//
//  Created by guanglong on 2017/2/10.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import "UIView+FastBuild.h"
#import <objc/runtime.h>

@implementation UIView (FastBuild)

- (CGFloat)fb_heightAfterInitialization
{
    [self fb_layoutAfterInitialization];
    return [self fb_lgl_pri_cellHeightFittingCompressedSize];
}

- (CGFloat)fb_heightAfterInitializationWithContentWidth:(CGFloat)contentViewWidth
{
    [self fb_layoutAfterInitializationWithContentWidth:contentViewWidth];
    return [self fb_lgl_pri_cellHeightFittingCompressedSize];
}

- (void)fb_layoutAfterInitialization;
{
    CGFloat contentWidth = 0;
    if ([self respondsToSelector:@selector(viewContentViewWidth)]) {
        contentWidth = self.viewContentViewWidth;
    }
    else {
        CGFloat scrWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat scrHeight = [UIScreen mainScreen].bounds.size.height;
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
            {
                contentWidth = MAX(scrWidth, scrHeight);
                if ([self respondsToSelector:@selector(viewContentViewHorizonMargin)]) {
                    contentWidth -= self.viewContentViewHorizonMargin;
                }
            }
                break;
            default:
            {
                contentWidth = MIN(scrWidth, scrHeight);
                if ([self respondsToSelector:@selector(viewContentViewVerticalMargin)]) {
                    contentWidth -= self.viewContentViewVerticalMargin;
                }
            }
                break;
        }
    }
    [self fb_layoutAfterInitializationWithContentWidth:contentWidth];
}

- (void)fb_layoutAfterInitializationWithContentWidth:(CGFloat)contentViewWidth
{
    [self fb_lgl_pri_remakeConstraitsWithContentWidth:contentViewWidth];
    
    // 在ios10中 layoutIfNeeded 不会改变 subview 的 size，所以需要强制改变
    CGFloat sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (sysVersion > 9.9) {
        CGSize s = [self.fb_concernedContentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        self.bounds = CGRectMake(0, 0, s.width, s.height);
        [self sizeToFit];
        [self layoutIfNeeded];
        
        // 在 UITableViewHeaderFooterView 中需要加入下面一段
        {
            self.fb_concernedContentView.bounds = CGRectMake(0, 0, s.width, s.height);
//            [self.fb_concernedContentView sizeToFit]; // 可有可无
            [self.fb_concernedContentView layoutIfNeeded];
        }
        
        [self fb_lgl_pri_removeUnavailableConstraints];
    }
    else {
        [self layoutIfNeeded];
    }
}

- (void)fb_lsResetForModel:(NSObject *)model make:(void (^)(NSObject *m))makeBlock set:(void(^)(FBLineSpaceMaker* maker))setBlock
{
    makeBlock(model);
    [model fb_lsEnumerateMakersUsingBlock:^(NSString *key, FBLineSpaceMaker *maker) {
        setBlock(maker);
    }];
    [self fb_layoutAfterInitialization];
    
    [model fb_lsEnumerateMakersUsingBlock:^(NSString *key, FBLineSpaceMaker *maker) {
        
        [maker.label sizeToFit];
        CGFloat lblHeight = maker.label.frame.size.height + 1;
        int lineNum = (lblHeight + maker.lineSpace) / (maker.label.font.lineHeight + maker.lineSpace);
        if (lineNum < 2) {
            maker.setLineSpace(0);
            setBlock(maker);
        }
    }];
}

- (UIView *)fb_concernedContentView
{
    return self;
}

#pragma mark - - private
- (CGFloat)fb_lgl_pri_cellHeightFittingCompressedSize
{
    CGFloat cellHeight = [self.fb_concernedContentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
    return cellHeight;
}

- (void)fb_lgl_pri_remakeConstraitsWithContentWidth:(CGFloat)contentViewWidth
{
    CGFloat sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
    self.fb_concernedContentView.translatesAutoresizingMaskIntoConstraints = (sysVersion > 9.9);
    [self fb_lgl_pri_tryAddWidthConstraintWithContentWidth:contentViewWidth];
    [self fb_lgl_pri_tryAddHeightConstraint];
}

- (void)fb_lgl_pri_removeUnavailableConstraints
{
    for (NSLayoutConstraint* constraint in self.fb_concernedContentView.constraints) {
        if (constraint.firstItem == self.fb_concernedContentView) {
            if (![constraint.identifier isEqualToString:@"123-456-lgl"]) {
                constraint.active = NO;
            }
        }
    }
}

- (void)fb_lgl_pri_tryAddWidthConstraintWithContentWidth:(CGFloat)contentViewWidth
{
    CGFloat sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
    NSLayoutConstraint* widthConstraint = objc_getAssociatedObject(self, __func__);
    
    // 约束的宽度发生改变的情况
    if (widthConstraint && ABS(widthConstraint.constant - contentViewWidth) > 0.12) {
        if (sysVersion < 7.9) {
            [self.fb_concernedContentView removeConstraint:widthConstraint];
        }
        else {
            widthConstraint.active = NO;
        }
        widthConstraint = nil;
    }
    
    // 约束没有添加到 self.contentView 的情况
    if (widthConstraint && ![self.fb_concernedContentView.constraints containsObject:widthConstraint]) {
        if (sysVersion < 7.9) {
            [self.fb_concernedContentView addConstraint:widthConstraint];
        }
        else {
            widthConstraint.active = YES;
        }
    }
    
    // 约束还没创建的情况
    if (!widthConstraint) {
        widthConstraint = [NSLayoutConstraint constraintWithItem:self.fb_concernedContentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:contentViewWidth];
        widthConstraint.identifier = @"123-456-lgl";
        objc_setAssociatedObject(self, __func__, widthConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (sysVersion < 7.9) {
            [self.fb_concernedContentView addConstraint:widthConstraint];
        }
        else {
            widthConstraint.active = YES;
        }
    }
}

- (void)fb_lgl_pri_tryAddHeightConstraint
{
    CGFloat sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
    NSLayoutConstraint* heightConstraint = objc_getAssociatedObject(self, __func__);
    
    if (heightConstraint && ![self.fb_concernedContentView.constraints containsObject:heightConstraint]) {
        if (sysVersion < 7.9) {
            [self.fb_concernedContentView addConstraint:heightConstraint];
        }
        else {
            heightConstraint.active = YES;
        }
    }
    
    if (!heightConstraint) {
        heightConstraint = [NSLayoutConstraint constraintWithItem:self.fb_concernedContentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:0];
        heightConstraint.identifier = @"123-456-lgl";
        objc_setAssociatedObject(self, __func__, heightConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (sysVersion < 7.9) {
            [self.fb_concernedContentView addConstraint:heightConstraint];
        }
        else {
            heightConstraint.active = YES;
        }
    }
}

#pragma mark - - properties
- (void)setFb_clickBlock:(void (^)(NSIndexPath *))fb_clickBlock
{
    objc_setAssociatedObject(self, @selector(fb_clickBlock), fb_clickBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSIndexPath *))fb_clickBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFb_clickSenderBlock:(void (^)(NSIndexPath *, id))fb_clickSenderBlock
{
    objc_setAssociatedObject(self, @selector(fb_clickSenderBlock), fb_clickSenderBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSIndexPath *, id))fb_clickSenderBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFb_clickFlagBlock:(void (^)(NSIndexPath *, NSInteger))fb_clickFlagBlock
{
    objc_setAssociatedObject(self, @selector(fb_clickFlagBlock), fb_clickFlagBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSIndexPath *, NSInteger))fb_clickFlagBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFb_clickSenderFlagBlock:(void (^)(NSIndexPath *, id, NSInteger))fb_clickSenderFlagBlock
{
    objc_setAssociatedObject(self, @selector(fb_clickSenderFlagBlock), fb_clickSenderFlagBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSIndexPath *, id, NSInteger))fb_clickSenderFlagBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
