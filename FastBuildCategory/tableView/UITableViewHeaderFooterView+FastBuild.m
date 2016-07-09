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
    
    if ([self respondsToSelector:@selector(headerFooterContentViewWidth)]) {
        CGFloat customWidth = self.headerFooterContentViewWidth;
        contentWidth = customWidth < CGFLOAT_MIN ? contentWidth : customWidth;
    }
    return [self heightAfterInitializationWithContentWidth:contentWidth];
}

- (CGFloat)heightAfterInitializationWithContentWidth:(CGFloat)contentViewWidth
{
    [self remakeConstraitsWithContentWidth:contentViewWidth];
    [self layoutIfNeeded];
    CGFloat hfHeight = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
    return hfHeight;
}

- (void)remakeConstraitsWithContentWidth:(CGFloat)contentViewWidth
{
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint* widthConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:contentViewWidth];
    NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:0];
    
    NSArray* toAddConstraints = @[widthConstraint, heightConstraint];
    NSMutableArray* toRemoveConstraints = [NSMutableArray arrayWithCapacity:2];
    for (NSLayoutConstraint* constraint in self.contentView.constraints) {
        if (constraint.firstItem == self.contentView && constraint.secondItem == nil) {
            [toRemoveConstraints addObject:constraint];
        }
    }
    
    CGFloat sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (sysVersion < 8.0) {
        [self.contentView removeConstraints:toRemoveConstraints];
        [self.contentView addConstraints:toAddConstraints];
    }
    else {
        [NSLayoutConstraint deactivateConstraints:toRemoveConstraints];
        [NSLayoutConstraint activateConstraints:toAddConstraints];
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