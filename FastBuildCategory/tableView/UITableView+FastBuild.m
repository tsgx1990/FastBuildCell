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

@property (nonatomic, strong) NSCache* calCellCache;

@end

@implementation UITableView (FastBuild)

#define kCacheDelegate      @"kCacheDelegate"
- (void)setCacheDelegate:(id<UITableViewCacheDelegate>)cacheDelegate_
{
    objc_setAssociatedObject(self, kCacheDelegate, cacheDelegate_, OBJC_ASSOCIATION_ASSIGN);
}

- (id<UITableViewCacheDelegate>)cacheDelegate
{
    return objc_getAssociatedObject(self, kCacheDelegate);
}

#pragma mark - - cal cell height
- (CGFloat)cellHeightForCellClass:(Class)cellClass withCallBlock:(void (^)(id))calBlock
{
    UITableViewCell* cell = [self cellForClass:cellClass];
    if (calBlock) {
        calBlock(cell);
        return [self heightForCell:cell];
    }
    else {
        return 0;
    }
}

- (CGFloat)cellHeightForCellClass:(Class)cellClass withInfo:(id)info
{
    CGFloat cellHeight;
    if ([info usingHeightCacheInScrollView:self]) {
        CGFloat cellHeight = [info cellHeightInScrollView:self];
        // 如果cellHeight<0，表示并没有缓存的高度，因为cell默认高度为-1
        if (cellHeight >= 0) {
            return cellHeight;
        }
    }
    
    UITableViewCell* cell = [self cellForClass:cellClass];
    if ([cell respondsToSelector:@selector(cellHeightWithInfo:)]) {
        cellHeight = [cell cellHeightWithInfo:info];
    }
    else if ([cell respondsToSelector:@selector(cellWithInfo:)]) {
        cellHeight = [self heightForCell:[cell cellWithInfo:info]];
    }
    else {
        cellHeight = 0;
    }
    // 计算出cellHeight之后，缓存到model中
    [info cacheCellHeight:cellHeight inScrollView:self];
    return cellHeight;
}

#pragma mark - - cal header footer height
- (CGFloat)headerFooterHeightForClass:(Class)headerFooterClass withCallBlock:(void (^)(id))calBlock
{
    UITableViewHeaderFooterView* hfView = [self headerFooterForClass:headerFooterClass];
    if (calBlock) {
        calBlock(hfView);
        return [self heightForHeaderFooter:hfView];
    }
    else {
        return 0;
    }
}

- (CGFloat)headerFooterHeightForClass:(Class)headerFooterClass withInfo:(id)info
{
    UITableViewHeaderFooterView* hfView = [self headerFooterForClass:headerFooterClass];
    if ([hfView respondsToSelector:@selector(headerFooterHeightWithInfo:)]) {
        return [hfView headerFooterHeightWithInfo:info];
    }
    else if ([hfView respondsToSelector:@selector(headerFooterWithInfo:)]) {
        return [self heightForHeaderFooter:[hfView headerFooterWithInfo:info]];
    }
    else {
        return 0;
    }
}

#pragma mark - - private

#pragma mark - - cell
- (UITableViewCell*)cellForClass:(Class)cellClass
{
    UITableViewCell* cell = [self.calCellCache objectForKey:cellClass];
    if (!cell) {
        cell = [[cellClass alloc] init];
        [self.calCellCache setObject:cell forKey:cellClass];
    }
    return cell;
}

- (CGFloat)heightForCell:(UITableViewCell*)cell
{
    //    [cell layoutIfNeeded]; // 在ios7中必须有
    //    [cell.contentView layoutIfNeeded];
    //    CGFloat cellHeight = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
    //    return cellHeight;
    
    return cell.heightAfterInitialization;
}

#pragma mark - - header footer
- (UITableViewHeaderFooterView*)headerFooterForClass:(Class)headerFooterClass
{
    UITableViewHeaderFooterView* hfView = [self.calCellCache objectForKey:headerFooterClass];
    if (!hfView) {
        hfView = [[headerFooterClass alloc] initWithReuseIdentifier:nil];
        [self.calCellCache setObject:hfView forKey:headerFooterClass];
    }
    return hfView;
}

- (CGFloat)heightForHeaderFooter:(UITableViewHeaderFooterView*)hfView
{
    //    [hfView.contentView layoutIfNeeded];
    //    CGFloat hfHeight = [hfView.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
    //    return hfHeight;
    
    return [hfView heightAfterInitialization];
}

#pragma mark - -

#define kCalCellCache       @"calCellCache"
- (NSCache *)calCellCache
{
    NSCache* calCellCache = objc_getAssociatedObject(self, kCalCellCache);
    if (!calCellCache) {
        calCellCache = [[NSCache alloc] init];
        objc_setAssociatedObject(self, kCalCellCache, calCellCache, OBJC_ASSOCIATION_RETAIN);
    }
    return calCellCache;
}

/////////////////////////////
/////////////////////////////
/////////////////////////////

#pragma mark - - 快捷创建tableView的系列方法

- (void)registerClassWithCellModels:(NSArray *)cellModels modelConfigBlock:(void (^)(UITableView*, id))configBlock
{
    for (id model in cellModels) {
        configBlock(self, model);
        [model clearHeightCacheInScrollView:self]; // tabelView重新加载时默认清空高度缓存
        [model useHeightCache:YES inScrollView:self]; // 默认情况下使用高度缓存
        Class modelCellClass = [model reuseCellClassInScrollView:self];
        NSString* modelCellID = [model reuseIdentifierInScrollView:self];
        [self registerClass:modelCellClass forCellReuseIdentifier:modelCellID];
    }
}

- (CGFloat)cellHeightWithCellModels:(NSArray *)cellModels forIndexPath:(NSIndexPath *)indexPath
{
    NSObject* model = [self modelOfCellModels:cellModels atIndexPath:indexPath];
    
    BOOL usingHeightCache = [self usingHeightCacheForRowAtIndexPath:indexPath];
    if (usingHeightCache) {
        CGFloat cellHeight = [model cellHeightInScrollView:self];
        if (cellHeight >= 0) {
            return cellHeight;
        }
    }
    
    [model useHeightCache:usingHeightCache inScrollView:self];
    return [self cellHeightWithModel:model];
}

- (UITableViewCell *)cellWithCellModels:(NSArray *)cellModels forIndexPath:(NSIndexPath *)indexPath
{
    NSObject* model = [self modelOfCellModels:cellModels atIndexPath:indexPath];
    UITableViewCell* cell = [self rawCellOfCellModel:model atIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(cellWithInfo:)]) {
        return [cell cellWithInfo:model];
    }
    else {
        return cell;
    }
}

- (NSObject*)modelOfCellModels:(NSArray *)cellModels atIndexPath:(NSIndexPath *)indexPath
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

- (UITableViewCell*)rawCellOfCellModel:(NSObject*)cellModel atIndexPath:(NSIndexPath *)indexPath
{
    NSString* reuseID = [cellModel reuseIdentifierInScrollView:self];
    UITableViewCell* cell = [self dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    cell.tableView = self;
    cell.indexPath = indexPath;
    return cell;
}

- (CGFloat)cellHeightWithModel:(NSObject*)model
{
    // 不使用缓存，或者没有缓存的时候
    Class cellClass = [model reuseCellClassInScrollView:self];
    CGFloat cellHeight = [self cellHeightForCellClass:cellClass withInfo:model];
    return cellHeight;
}

- (__kindof UITableViewCell*)rawCalculateCellForModel:(NSObject *)model
{
    Class cellClass = [model reuseCellClassInScrollView:self];
    UITableViewCell* cell = [self cellForClass:cellClass];
    return cell;
}

- (__kindof UITableViewCell*)rawCellWithCellModels:(NSArray*)cellModels forIndexPath:(NSIndexPath*)indexPath;
{
    NSObject* model = [self modelOfCellModels:cellModels atIndexPath:indexPath];
    UITableViewCell* cell = [self rawCellOfCellModel:model atIndexPath:indexPath];
    return cell;
}

- (BOOL)usingHeightCacheForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self.cacheDelegate respondsToSelector:@selector(tableView:usingHeightCacheForRowAtIndexPath:)]) {
        return [self.cacheDelegate tableView:self usingHeightCacheForRowAtIndexPath:indexPath];
    }
    else {
        return YES; // 默认情况下使用高度缓存
    }
}

@end
