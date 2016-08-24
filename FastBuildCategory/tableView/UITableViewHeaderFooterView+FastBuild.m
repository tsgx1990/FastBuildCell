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

- (CGFloat)heightAfterInitialization
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
    return [self heightAfterInitializationWithContentWidth:contentWidth];
}

- (CGFloat)heightAfterInitializationWithContentWidth:(CGFloat)contentViewWidth
{
    [self lgl_remakeConstraitsWithContentWidth:contentViewWidth];
    [self layoutIfNeeded];
    CGFloat hfHeight = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
    return hfHeight;
}

- (void)lgl_remakeConstraitsWithContentWidth:(CGFloat)contentViewWidth
{
    CGFloat sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
    self.contentView.translatesAutoresizingMaskIntoConstraints = (sysVersion > 9.9);
    
    [self lgl_tryAddWidthConstraintWithContentWidth:contentViewWidth];
    [self lgl_tryAddHeightConstraint];
}

- (void)lgl_tryAddWidthConstraintWithContentWidth:(CGFloat)contentViewWidth
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

- (void)lgl_tryAddHeightConstraint
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

#define kSection    @"kSection"
- (void)setSection:(NSInteger)section_
{
    objc_setAssociatedObject(self, kSection, @(section_), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)section
{
    return [objc_getAssociatedObject(self, kSection) integerValue];
}

#define kTableView @"kTableView"
- (void)setTableView:(UITableView *)tableView_
{
    objc_setAssociatedObject(self, kTableView, tableView_, OBJC_ASSOCIATION_ASSIGN);
}

- (UITableView *)tableView
{
    return objc_getAssociatedObject(self, kTableView);
}

#define kDidSelectBlock     @"kDidSelectBlock"
- (void)setDidSelectBlock:(void (^)(NSInteger))didSelectBlock_
{
    objc_setAssociatedObject(self, kDidSelectBlock, didSelectBlock_, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSInteger))didSelectBlock
{
    return objc_getAssociatedObject(self, kDidSelectBlock);
}

#define kClickEventsBlock   @"kClickEventsBlock"
- (void)setClickEventsBlock:(void (^)(NSInteger, id))clickEventsBlock_
{
    objc_setAssociatedObject(self, kClickEventsBlock, clickEventsBlock_, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSInteger, id))clickEventsBlock
{
    return objc_getAssociatedObject(self, kClickEventsBlock);
}

#define kClickFlagEventsBlock   @"kClickFlagEventsBlock"
- (void)setClickFlagEventsBlock:(void (^)(NSInteger, id, int))clickFlagEventsBlock_
{
    objc_setAssociatedObject(self, kClickFlagEventsBlock, clickFlagEventsBlock_, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSInteger, id, int))clickFlagEventsBlock
{
    return objc_getAssociatedObject(self, kClickFlagEventsBlock);
}

@end
