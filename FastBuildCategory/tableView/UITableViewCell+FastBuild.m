//
//  UITableViewCell+FastBuild.m
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "UITableViewCell+FastBuild.h"
#import <objc/runtime.h>

@implementation UITableViewCell (FastBuild)

- (CGFloat)heightAfterInitialization
{
    CGFloat contentWidth = 0;
    if ([self respondsToSelector:@selector(cellContentViewWidth)]) {
        contentWidth = self.cellContentViewWidth;
    }
    else {
        CGFloat scrWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat scrHeight = [UIScreen mainScreen].bounds.size.height;
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
            {
                contentWidth = MAX(scrWidth, scrHeight);
                if ([self respondsToSelector:@selector(cellContentViewHorizonMargin)]) {
                    contentWidth -= self.cellContentViewHorizonMargin;
                }
            }
                break;
            default:
            {
                contentWidth = MIN(scrWidth, scrHeight);
                if ([self respondsToSelector:@selector(cellContentViewVerticalMargin)]) {
                    contentWidth -= self.cellContentViewVerticalMargin;
                }
            }
                break;
        }
    }
    return [self heightAfterInitializationWithContentWidth:contentWidth];
}

- (CGFloat)heightAfterInitializationWithContentWidth:(CGFloat)contentViewWidth
{
    [self remakeConstraitsWithContentWidth:contentViewWidth];
    [self layoutIfNeeded]; // 在ios7中必须有
    CGFloat cellHeight = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
    return cellHeight;
}

- (void)remakeConstraitsWithContentWidth:(CGFloat)contentViewWidth
{
    CGFloat sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = (sysVersion > 9.9);
    NSLayoutConstraint* widthConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:contentViewWidth];
    NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:0];
    
    NSArray* toAddConstraints = @[widthConstraint, heightConstraint];
    NSMutableArray* toRemoveConstraints = [NSMutableArray arrayWithCapacity:2];
    for (NSLayoutConstraint* constraint in self.contentView.constraints) {
        if (constraint.firstItem == self.contentView && constraint.secondItem == nil) {
            [toRemoveConstraints addObject:constraint];
        }
    }
    
    if (sysVersion < 7.9) {
        [self.contentView removeConstraints:toRemoveConstraints];
        [self.contentView addConstraints:toAddConstraints];
    }
    else {
        [NSLayoutConstraint deactivateConstraints:toRemoveConstraints];
        [NSLayoutConstraint activateConstraints:toAddConstraints];
    }
}

#define kIndexPath  @"kIndexPath"
- (void)setIndexPath:(NSIndexPath *)indexPath_
{
    objc_setAssociatedObject(self, kIndexPath, indexPath_, OBJC_ASSOCIATION_RETAIN);
}

- (NSIndexPath *)indexPath
{
    return objc_getAssociatedObject(self, kIndexPath);
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
- (void)setDidSelectBlock:(void (^)(NSIndexPath *))didSelectBlock_
{
    objc_setAssociatedObject(self, kDidSelectBlock, didSelectBlock_, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSIndexPath *))didSelectBlock
{
    return objc_getAssociatedObject(self, kDidSelectBlock);
}

#define kClickEventsBlock   @"kClickEventsBlock"
- (void)setClickEventsBlock:(void (^)(NSIndexPath *, id))clickEventsBlock_
{
    objc_setAssociatedObject(self, kClickEventsBlock, clickEventsBlock_, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSIndexPath *, id))clickEventsBlock
{
    return objc_getAssociatedObject(self, kClickEventsBlock);
}

#define kClickFlagEventsBlock   @"kClickFlagEventsBlock"
- (void)setClickFlagEventsBlock:(void (^)(NSIndexPath*, id, int))clickFlagEventsBlock_
{
    objc_setAssociatedObject(self, kClickFlagEventsBlock, clickFlagEventsBlock_, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSIndexPath*, id, int))clickFlagEventsBlock
{
    return objc_getAssociatedObject(self, kClickFlagEventsBlock);
}

@end
