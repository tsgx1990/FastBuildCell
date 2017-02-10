//
//  UITableView+FastBuild.m
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "UITableView+FastBuild.h"
#import "UITableViewCell+FastBuild.h"
#import "UITableViewHeaderFooterView+FastBuild.h"
#import "NSObject+FastBuild.h"
#import <objc/runtime.h>

@interface UITableView ()

@property (nonatomic, retain, readonly) NSCache* fb_lgl_pri_calCellCache;

@property (nonatomic, assign) UIInterfaceOrientation fb_lgl_pri_currentOrientation;
@property (nonatomic, assign) BOOL fb_lgl_pri_tmpKeepHeightCache;

@end

@implementation UITableView (FastBuild)

+ (void)load
{
    method_exchangeImplementations(class_getInstanceMethod(self.class, @selector(layoutSubviews)),
                                   class_getInstanceMethod(self.class, @selector(fb_lgl_pri_layoutSubviews)));
}

- (void)setFb_cacheDelegate:(id<UITableViewCacheDelegate>)fb_cacheDelegate
{
    objc_setAssociatedObject(self, @selector(fb_cacheDelegate), fb_cacheDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<UITableViewCacheDelegate>)fb_cacheDelegate
{
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - - cal cell height
- (CGFloat)fb_cellHeightForCellClass:(Class)cellClass withCallBlock:(void (^)(id))calBlock
{
    UITableViewCell* cell = [self fb_lgl_pri_cellForClass:cellClass];
    if (calBlock) {
        calBlock(cell);
        return [self fb_lgl_pri_heightForCell:cell];
    }
    else {
        return 0;
    }
}

- (CGFloat)fb_cellHeightForCellClass:(Class)cellClass withInfo:(id)info
{
    CGFloat cellHeight;
    if ([info fb_usingHeightCacheInScrollView:self]) {
        CGFloat cellHeight = [info fb_cellHeightInScrollView:self];
        // 如果cellHeight<0，表示并没有缓存的高度，因为cell默认高度为-1
        if (cellHeight >= 0) {
            return cellHeight;
        }
    }
    
    UITableViewCell* cell = [self fb_lgl_pri_cellForClass:cellClass];
    if ([cell respondsToSelector:@selector(fb_viewHeightWithInfo:)]) {
        cellHeight = [cell fb_viewHeightWithInfo:info];
    }
    else if ([cell respondsToSelector:@selector(fb_viewWithInfo:)]) {
        cellHeight = [self fb_lgl_pri_heightForCell:[cell fb_viewWithInfo:info]];
    }
    else {
        cellHeight = 0;
    }
    // 计算出cellHeight之后，缓存到model中
    [info fb_cacheCellHeight:cellHeight inScrollView:self];
    return cellHeight;
}

#pragma mark - - cal header footer height
- (CGFloat)fb_headerFooterHeightForClass:(Class)headerFooterClass withCallBlock:(void (^)(id))calBlock
{
    UITableViewHeaderFooterView* hfView = [self fb_lgl_pri_headerFooterForClass:headerFooterClass];
    if (calBlock) {
        calBlock(hfView);
        return [self fb_lgl_pri_heightForHeaderFooter:hfView];
    }
    else {
        return 0;
    }
}

- (CGFloat)fb_headerFooterHeightForClass:(Class)headerFooterClass withInfo:(id)info
{
    UITableViewHeaderFooterView* hfView = [self fb_lgl_pri_headerFooterForClass:headerFooterClass];
    if ([hfView respondsToSelector:@selector(fb_viewHeightWithInfo:)]) {
        return [hfView fb_viewHeightWithInfo:info];
    }
    else if ([hfView respondsToSelector:@selector(fb_viewWithInfo:)]) {
        return [self fb_lgl_pri_heightForHeaderFooter:[hfView fb_viewWithInfo:info]];
    }
    else {
        return 0;
    }
}

- (void)fb_reloadTableHeaderView:(FBTableHeaderFooterView *)tableHeaderView withInfo:(id)info
{
    [self fb_lgl_pri_resetTableHeaderFooterView:tableHeaderView withInfo:info];
    self.tableHeaderView = tableHeaderView;
}

- (void)fb_reloadTableFooterView:(FBTableHeaderFooterView *)tableFooterView withInfo:(id)info
{
    [self fb_lgl_pri_resetTableHeaderFooterView:tableFooterView withInfo:info];
    self.tableFooterView = tableFooterView;
}

- (void)fb_lgl_pri_resetTableHeaderFooterView:(FBTableHeaderFooterView *)headerFooterView withInfo:(id)info
{
    [headerFooterView fb_viewWithInfo:info];
    CGFloat h = headerFooterView.fb_heightAfterInitialization;
    headerFooterView.frame = CGRectMake(0, 0, 1, h);
}

#pragma mark - - private
- (void)fb_lgl_pri_layoutSubviews
{
    [self fb_lgl_pri_layoutSubviews];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (self.fb_lgl_pri_currentOrientation != UIInterfaceOrientationUnknown) {
        if (self.fb_lgl_pri_currentOrientation != orientation) {
            
            // ios10 延时reload是为了防止转屏等待时间过长（计算cell高度耗时）
            CGFloat sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
            if (sysVersion > 9.9) {
                [self performSelector:@selector(fb_lgl_pri_reloadWhenRotation) withObject:nil afterDelay:0 inModes:@[NSRunLoopCommonModes]];
            }
            else {
                [self fb_lgl_pri_reloadWhenRotation];
            }
        }
    }
    self.fb_lgl_pri_currentOrientation = orientation;
}

- (void)fb_lgl_pri_reloadWhenRotation
{
    // 因为转屏时，cell的高度会重新计算好，所以在 reloadRowsAtIndexPat... 时不需要重新计算cell高度
    self.fb_lgl_pri_tmpKeepHeightCache = YES;
    NSIndexPath* selectedIndexPath = self.indexPathForSelectedRow;
    [self reloadRowsAtIndexPaths:self.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    [self selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    self.fb_lgl_pri_tmpKeepHeightCache = NO;
}

- (void)setFb_lgl_pri_tmpKeepHeightCache:(BOOL)fb_lgl_pri_tmpKeepHeightCache
{
    objc_setAssociatedObject(self, @selector(fb_lgl_pri_tmpKeepHeightCache), @(fb_lgl_pri_tmpKeepHeightCache), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)fb_lgl_pri_tmpKeepHeightCache
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFb_lgl_pri_currentOrientation:(UIInterfaceOrientation)fb_lgl_pri_currentOrientation
{
    objc_setAssociatedObject(self, @selector(fb_lgl_pri_currentOrientation), @(fb_lgl_pri_currentOrientation), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIInterfaceOrientation)fb_lgl_pri_currentOrientation
{
    NSNumber* currentOrientation = objc_getAssociatedObject(self, _cmd);
    if (!currentOrientation) {
        return UIInterfaceOrientationUnknown;
    }
    return currentOrientation.integerValue;
}

#pragma mark - - cell
- (UITableViewCell*)fb_lgl_pri_cellForClass:(Class)cellClass
{
    UITableViewCell* cell = [self.fb_lgl_pri_calCellCache objectForKey:cellClass];
    if (!cell) {
        cell = [[cellClass alloc] init];
        [self.fb_lgl_pri_calCellCache setObject:cell forKey:cellClass];
    }
    return cell;
}

- (CGFloat)fb_lgl_pri_heightForCell:(UITableViewCell*)cell
{
//    [cell layoutIfNeeded]; // 在ios7中必须有
//    [cell.contentView layoutIfNeeded];
//    CGFloat cellHeight = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
//    return cellHeight;
    
    return cell.fb_heightAfterInitialization;
}

#pragma mark - - header footer
- (UITableViewHeaderFooterView*)fb_lgl_pri_headerFooterForClass:(Class)headerFooterClass
{
    UITableViewHeaderFooterView* hfView = [self.fb_lgl_pri_calCellCache objectForKey:headerFooterClass];
    if (!hfView) {
        hfView = [[headerFooterClass alloc] initWithReuseIdentifier:nil];
        [self.fb_lgl_pri_calCellCache setObject:hfView forKey:headerFooterClass];
    }
    return hfView;
}

- (CGFloat)fb_lgl_pri_heightForHeaderFooter:(UITableViewHeaderFooterView*)hfView
{
//    [hfView.contentView layoutIfNeeded];
//    CGFloat hfHeight = [hfView.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
//    return hfHeight;
    
    return [hfView fb_heightAfterInitialization];
}

#pragma mark - -
- (NSCache *)fb_lgl_pri_calCellCache
{
    NSCache* calCellCache = objc_getAssociatedObject(self, _cmd);
    if (!calCellCache) {
        calCellCache = [[NSCache alloc] init];
        objc_setAssociatedObject(self, _cmd, calCellCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return calCellCache;
}

/////////////////////////////
/////////////////////////////
/////////////////////////////

#pragma mark - - 快捷创建tableView的系列方法

- (void)fb_registerClassWithCellModels:(NSArray *)cellModels modelConfigBlock:(void (^)(UITableView*, id))configBlock
{
    for (id model in cellModels) {
        configBlock(self, model);
        if (self.fb_lgl_pri_tmpKeepHeightCache) {
            [model fb_clearHeightCacheInScrollView:self]; // tabelView重新加载时默认清空高度缓存
        }
        [model fb_useHeightCache:YES inScrollView:self]; // 默认情况下使用高度缓存
        Class modelCellClass = [model fb_reuseCellClassInScrollView:self];
        NSString* modelCellID = [model fb_reuseIdentifierInScrollView:self];
        [self registerClass:modelCellClass forCellReuseIdentifier:modelCellID];
    }
}

- (CGFloat)fb_cellHeightWithCellModels:(NSArray *)cellModels forIndexPath:(NSIndexPath *)indexPath
{
    NSObject* model = [self fb_lgl_pri_modelOfCellModels:cellModels atIndexPath:indexPath];
    
    BOOL usingHeightCache = [self fb_lgl_pri_usingHeightCacheForRowAtIndexPath:indexPath];
    if (usingHeightCache) {
        CGFloat cellHeight = [model fb_cellHeightInScrollView:self];
        if (cellHeight >= 0) {
            return cellHeight;
        }
    }
    
    [model fb_useHeightCache:usingHeightCache inScrollView:self];
    return [self fb_cellHeightWithModel:model];
}

- (UITableViewCell *)fb_cellWithCellModels:(NSArray *)cellModels forIndexPath:(NSIndexPath *)indexPath
{
    NSObject* model = [self fb_lgl_pri_modelOfCellModels:cellModels atIndexPath:indexPath];
    UITableViewCell* cell = [self fb_lgl_pri_rawCellOfCellModel:model atIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(fb_viewWithInfo:)]) {
        return [cell fb_viewWithInfo:model];
    }
    else {
        return cell;
    }
}

- (NSObject*)fb_lgl_pri_modelOfCellModels:(NSArray *)cellModels atIndexPath:(NSIndexPath *)indexPath
{
    NSObject* model = nil;
    if ([[cellModels firstObject] isKindOfClass:[NSArray class]]) {
        model = cellModels[indexPath.section][indexPath.row];
    }
    else {
        model = cellModels[indexPath.row];
    }
    return model;
}

- (UITableViewCell*)fb_lgl_pri_rawCellOfCellModel:(NSObject*)cellModel atIndexPath:(NSIndexPath *)indexPath
{
    NSString* reuseID = [cellModel fb_reuseIdentifierInScrollView:self];
    UITableViewCell* cell = [self dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    cell.fb_tableView = self;
    cell.fb_indexPath = indexPath;
    return cell;
}

- (CGFloat)fb_cellHeightWithModel:(NSObject*)model
{
    // 不使用缓存，或者没有缓存的时候
    Class cellClass = [model fb_reuseCellClassInScrollView:self];
    CGFloat cellHeight = [self fb_cellHeightForCellClass:cellClass withInfo:model];
    return cellHeight;
}

- (__kindof UITableViewCell*)fb_rawCalculateCellForModel:(NSObject *)model
{
    Class cellClass = [model fb_reuseCellClassInScrollView:self];
    UITableViewCell* cell = [self fb_lgl_pri_cellForClass:cellClass];
    return cell;
}

- (__kindof UITableViewCell*)fb_rawCellWithCellModels:(NSArray*)cellModels forIndexPath:(NSIndexPath*)indexPath;
{
    NSObject* model = [self fb_lgl_pri_modelOfCellModels:cellModels atIndexPath:indexPath];
    UITableViewCell* cell = [self fb_lgl_pri_rawCellOfCellModel:model atIndexPath:indexPath];
    return cell;
}

- (BOOL)fb_lgl_pri_usingHeightCacheForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self.fb_cacheDelegate respondsToSelector:@selector(tableView:usingHeightCacheForRowAtIndexPath:)]) {
        return [self.fb_cacheDelegate tableView:self usingHeightCacheForRowAtIndexPath:indexPath];
    }
    else {
        return YES; // 默认情况下使用高度缓存
    }
}

@end
