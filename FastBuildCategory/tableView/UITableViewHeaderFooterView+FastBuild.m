//
//  UITableViewHeaderFooterView+FastBuild.m
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "UITableViewHeaderFooterView+FastBuild.h"
#import <objc/runtime.h>

@implementation UITableViewHeaderFooterView (FastBuild)

- (CGFloat)fb_heightAfterInitialization
{
    CGFloat contentWidth = 0;
    if ([self respondsToSelector:@selector(headerFooterContentViewWidth)]) {
        contentWidth = self.headerFooterContentViewWidth;
    }
    else {
        CGFloat scrWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat scrHeight = [UIScreen mainScreen].bounds.size.height;
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
            {
                contentWidth = MAX(scrWidth, scrHeight);
                if ([self respondsToSelector:@selector(headerFooterContentViewHorizonMargin)]) {
                    contentWidth -= self.headerFooterContentViewHorizonMargin;
                }
            }
                break;
            default:
            {
                contentWidth = MIN(scrWidth, scrHeight);
                if ([self respondsToSelector:@selector(headerFooterContentViewVerticalMargin)]) {
                    contentWidth -= self.headerFooterContentViewVerticalMargin;
                }
            }
                break;
        }
    }
    return [self fb_heightAfterInitializationWithContentWidth:contentWidth];
}

- (CGFloat)fb_heightAfterInitializationWithContentWidth:(CGFloat)contentViewWidth
{
    [self fb_lgl_pri_remakeConstraitsWithContentWidth:contentViewWidth];
    [self layoutIfNeeded];
    CGFloat hfHeight = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
    return hfHeight;
}

- (void)fb_lgl_pri_remakeConstraitsWithContentWidth:(CGFloat)contentViewWidth
{
    CGFloat sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
    self.contentView.translatesAutoresizingMaskIntoConstraints = (sysVersion > 9.9);
    [self fb_lgl_pri_tryAddWidthConstraintWithContentWidth:contentViewWidth];
    [self fb_lgl_pri_tryAddHeightConstraint];
}

- (void)fb_lgl_pri_tryAddWidthConstraintWithContentWidth:(CGFloat)contentViewWidth
{
    CGFloat sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
    NSLayoutConstraint* widthConstraint = objc_getAssociatedObject(self, __func__);
    
    // 约束的宽度发生改变的情况
    if (widthConstraint && ABS(widthConstraint.constant - contentViewWidth) > 0.12) {
        if (sysVersion < 7.9) {
            [self.contentView removeConstraint:widthConstraint];
        }
        else {
            widthConstraint.active = NO;
        }
        widthConstraint = nil;
    }
    
    // 约束没有添加到 self.contentView 的情况
    if (widthConstraint && ![self.contentView.constraints containsObject:widthConstraint]) {
        if (sysVersion < 7.9) {
            [self.contentView addConstraint:widthConstraint];
        }
        else {
            widthConstraint.active = YES;
        }
    }
    
    // 约束还没创建的情况
    if (!widthConstraint) {
        widthConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:contentViewWidth];
        objc_setAssociatedObject(self, __func__, widthConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (sysVersion < 7.9) {
            [self.contentView addConstraint:widthConstraint];
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
    
    if (heightConstraint && ![self.contentView.constraints containsObject:heightConstraint]) {
        if (sysVersion < 7.9) {
            [self.contentView addConstraint:heightConstraint];
        }
        else {
            heightConstraint.active = YES;
        }
    }
    
    if (!heightConstraint) {
        heightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:0];
        objc_setAssociatedObject(self, __func__, heightConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (sysVersion < 7.9) {
            [self.contentView addConstraint:heightConstraint];
        }
        else {
            heightConstraint.active = YES;
        }
    }
}

- (void)setFb_section:(NSInteger)fb_section
{
    objc_setAssociatedObject(self, @selector(fb_section), @(fb_section), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)fb_section
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setFb_tableView:(UITableView *)fb_tableView
{
    objc_setAssociatedObject(self, @selector(fb_tableView), fb_tableView, OBJC_ASSOCIATION_ASSIGN);
}

- (UITableView *)fb_tableView
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFb_didSelectBlock:(void (^)(NSInteger))fb_didSelectBlock
{
    objc_setAssociatedObject(self, @selector(fb_didSelectBlock), fb_didSelectBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSInteger))fb_didSelectBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFb_clickEventsBlock:(void (^)(NSInteger, id))fb_clickEventsBlock
{
    objc_setAssociatedObject(self, @selector(fb_clickEventsBlock), fb_clickEventsBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSInteger, id))fb_clickEventsBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFb_clickFlagEventsBlock:(void (^)(NSInteger, id, int))fb_clickFlagEventsBlock
{
    objc_setAssociatedObject(self, @selector(fb_clickFlagEventsBlock), fb_clickFlagEventsBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSInteger, id, int))fb_clickFlagEventsBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
