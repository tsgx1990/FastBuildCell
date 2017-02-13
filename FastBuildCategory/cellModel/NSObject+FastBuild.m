//
//  NSObject+FastBuild.m
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "NSObject+FastBuild.h"
#import <objc/runtime.h>

@interface NSObject()

@property (nonatomic, retain, readonly) NSMutableDictionary* fb_lgl_pri_cellHeightCache;
@property (nonatomic, retain, readonly) NSMutableDictionary* fb_lgl_pri_usingHeightCacheStorage;

@property (nonatomic, retain, readonly) NSMutableDictionary* fb_lgl_pri_reuseIdentifierStorage;

@property (nonatomic, retain, readonly) NSMutableDictionary* fb_lgl_pri_lsMakerMapper;

@end

@implementation NSObject (FastBuild)

- (FBLineSpaceMaker *(^)(NSString *))fb_lsMakerForKey
{
    FBLineSpaceMaker *(^lsForKeyBlock)(NSString *)  = objc_getAssociatedObject(self, _cmd);
    if (!lsForKeyBlock) {
        __weak typeof(self) ws = self;
        lsForKeyBlock = ^FBLineSpaceMaker*(NSString* key) {
            FBLineSpaceMaker* maker = [ws.fb_lgl_pri_lsMakerMapper valueForKey:key];
            if (!maker) {
                maker = [FBLineSpaceMaker new];
                [ws.fb_lgl_pri_lsMakerMapper setValue:maker forKey:key];
            }
            return maker;
        };
        objc_setAssociatedObject(self, _cmd, lsForKeyBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return lsForKeyBlock;
}

- (void)fb_lsEnumerateMakersUsingBlock:(void (^)(NSString *, FBLineSpaceMaker *))block
{
    [self.fb_lgl_pri_lsMakerMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        block(key, obj);
    }];
}

- (void)fb_setWeakValue:(id)value forkey:(const void *)key
{
    NSHashTable* hashTable = objc_getAssociatedObject(self, key);
    if (!hashTable) {
        hashTable = [NSHashTable weakObjectsHashTable];
        objc_setAssociatedObject(self, key, hashTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [hashTable removeAllObjects];
    [hashTable addObject:value];
}

- (id)fb_weakValueForKey:(const void *)key
{
    NSHashTable* hashTable = objc_getAssociatedObject(self, key);
    return hashTable.anyObject;
}

#pragma mark - - view model 配置
- (void)fb_configReuseViewClass:(Class)reuseViewClass andIdentifier:(NSString *)reuseIdentifier inScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self fb_lgl_pri_storageKeyForScrollView:scrollView viewClass:(Class)reuseViewClass];
    NSDictionary* dic = @{@"class": reuseViewClass, @"id": reuseIdentifier};
    [self.fb_lgl_pri_reuseIdentifierStorage setValue:dic forKey:key];
}

- (Class)fb_reuseCellClassInScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self fb_lgl_pri_storageKeyForScrollView:scrollView viewClass:[UITableViewCell class]];
    return self.fb_lgl_pri_reuseIdentifierStorage[key][@"class"];
}

- (NSString*)fb_reuseCellIdentifierInScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self fb_lgl_pri_storageKeyForScrollView:scrollView viewClass:[UITableViewCell class]];
    return self.fb_lgl_pri_reuseIdentifierStorage[key][@"id"];
}

- (Class)fb_reuseHFClassInScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self fb_lgl_pri_storageKeyForScrollView:scrollView viewClass:[UITableViewHeaderFooterView class]];
    return self.fb_lgl_pri_reuseIdentifierStorage[key][@"class"];
}

- (NSString *)fb_reuseHFIdentifierInScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self fb_lgl_pri_storageKeyForScrollView:scrollView viewClass:[UITableViewHeaderFooterView class]];
    return self.fb_lgl_pri_reuseIdentifierStorage[key][@"id"];
}

#pragma mark - - 是否使用缓存的cell高度
- (void)fb_useHeightCache:(BOOL)usingHeightCache inScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self fb_lgl_pri_cacheKeyOfScrollView:scrollView];
    [self.fb_lgl_pri_usingHeightCacheStorage setValue:@(usingHeightCache) forKey:key];
}

- (BOOL)fb_usingHeightCacheInScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self fb_lgl_pri_cacheKeyOfScrollView:scrollView];
    NSNumber* usingObj = [self.fb_lgl_pri_usingHeightCacheStorage valueForKey:key];
    return usingObj ? [usingObj boolValue] : NO;
}

#pragma mark - - 高度缓存
- (void)fb_cacheCellHeight:(CGFloat)cellHeight inScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self fb_lgl_pri_cacheKeyOfScrollView:scrollView];
    [self.fb_lgl_pri_cellHeightCache setValue:@(cellHeight) forKey:key];
}

- (CGFloat)fb_cellHeightInScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self fb_lgl_pri_cacheKeyOfScrollView:scrollView];
    NSNumber* cellHeight = [self.fb_lgl_pri_cellHeightCache valueForKey:key];
    if (!cellHeight) {
        return -1;
    }
    else {
        return [cellHeight floatValue];
    }
}

- (void)fb_clearHeightCacheInScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self fb_lgl_pri_cacheKeyOfScrollView:scrollView];
    [self.fb_lgl_pri_cellHeightCache setValue:nil forKey:key];
}

#pragma mark - - private
- (NSString*)fb_lgl_pri_cacheKeyOfScrollView:(UIScrollView*)scrollView
{
    NSString* reuseID = [self fb_reuseCellIdentifierInScrollView:scrollView];
    NSString* key = [NSString stringWithFormat:@"%p-%@", scrollView, reuseID];
    return key;
}

- (NSString*)fb_lgl_pri_storageKeyForScrollView:(UIScrollView*)scrollView viewClass:(Class)reuseCellClass
{
    NSString* key = [NSString stringWithFormat:@"%p", scrollView];
    if ([reuseCellClass isSubclassOfClass:[UITableViewCell class]]) {
        key = [@"cell-" stringByAppendingString:key];
    }
    if ([reuseCellClass isSubclassOfClass:[UITableViewHeaderFooterView class]]) {
        key = [@"headerFooter-" stringByAppendingString:key];
    }
    return key;
}

- (NSMutableDictionary *)fb_lgl_pri_cellHeightCache
{
    NSMutableDictionary* cellHeightCache = objc_getAssociatedObject(self, _cmd);
    if (!cellHeightCache) {
        cellHeightCache = [NSMutableDictionary dictionaryWithCapacity:2];
        objc_setAssociatedObject(self, _cmd, cellHeightCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cellHeightCache;
}

- (NSMutableDictionary *)fb_lgl_pri_usingHeightCacheStorage
{
    NSMutableDictionary* usingStorage = objc_getAssociatedObject(self, _cmd);
    if (!usingStorage) {
        usingStorage = [NSMutableDictionary dictionaryWithCapacity:2];
        objc_setAssociatedObject(self, _cmd, usingStorage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return usingStorage;
}

- (NSMutableDictionary *)fb_lgl_pri_reuseIdentifierStorage
{
    NSMutableDictionary* mDic = objc_getAssociatedObject(self, _cmd);
    if (!mDic) {
        mDic = [NSMutableDictionary dictionaryWithCapacity:6];
        objc_setAssociatedObject(self, _cmd, mDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return mDic;
}

- (NSMutableDictionary *)fb_lgl_pri_lsMakerMapper
{
    NSMutableDictionary* mDic = objc_getAssociatedObject(self, _cmd);
    if (!mDic) {
        mDic = [NSMutableDictionary dictionaryWithCapacity:2];
        objc_setAssociatedObject(self, _cmd, mDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return mDic;
}

@end
