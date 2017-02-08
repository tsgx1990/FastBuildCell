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

- (CGFloat)fb_heightAfterInitialization
{
    [self fb_layoutAfterInitialization];
    return [self lgl_fb_cellHeightFittingCompressedSize];
}

- (CGFloat)fb_heightAfterInitializationWithContentWidth:(CGFloat)contentViewWidth
{
    [self fb_layoutAfterInitializationWithContentWidth:contentViewWidth];
    return [self lgl_fb_cellHeightFittingCompressedSize];
}

- (void)fb_layoutAfterInitialization;
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
    [self fb_layoutAfterInitializationWithContentWidth:contentWidth];
}

- (void)fb_layoutAfterInitializationWithContentWidth:(CGFloat)contentViewWidth
{
    [self lgl_remakeConstraitsWithContentWidth:contentViewWidth];
    [self layoutIfNeeded]; // 在ios7中必须有
    
    CGFloat sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (sysVersion > 9.9) {
        CGSize s = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        self.bounds = CGRectMake(0, 0, s.width, s.height);
        [self sizeToFit];
        [self fb_lgl_removeUnavailableConstraints]; // ios10
    }
}

- (void)fb_lgl_removeUnavailableConstraints
{
    for (NSLayoutConstraint* constraint in self.contentView.constraints) {
        if (constraint.firstItem == self.contentView) {
            if (![constraint.identifier isEqualToString:@"123-456-lgl"]) {
                constraint.active = NO;
            }
        }
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

- (CGFloat)lgl_fb_cellHeightFittingCompressedSize
{
    CGFloat cellHeight = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
    return cellHeight;
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
        widthConstraint.identifier = @"123-456-lgl";
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
        heightConstraint.identifier = @"123-456-lgl";
        objc_setAssociatedObject(self, __func__, heightConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (sysVersion < 7.9) {
            [self.contentView addConstraint:heightConstraint];
        }
        else {
            heightConstraint.active = YES;
        }
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
