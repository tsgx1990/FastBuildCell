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

@property (nonatomic, strong) NSMutableDictionary* cellHeightCache;
@property (nonatomic, strong) NSMutableDictionary* usingHeightCacheStorage;

@property (nonatomic, strong) NSMutableDictionary* cellClassStorage;
@property (nonatomic, strong) NSMutableDictionary* reuseIdentifierStorage;

@property (nonatomic, readonly) NSMutableDictionary* fb_lgl_lsMakerMapper;

@end

@implementation NSObject (FastBuild)

- (void)setFb_lineSpace:(CGFloat)fb_lineSpace
{
    SEL keySel = @selector(fb_lineSpace);
    NSString* keyStr = NSStringFromSelector(keySel);
    [self willChangeValueForKey:keyStr];
    objc_setAssociatedObject(self, keySel, @(fb_lineSpace), OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:keyStr];
}

- (CGFloat)fb_lineSpace
{
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (FBLineSpaceMaker *(^)(NSString *))fb_lsMakerForKey
{
    FBLineSpaceMaker *(^lsForKeyBlock)(NSString *)  = objc_getAssociatedObject(self, _cmd);
    if (!lsForKeyBlock) {
        __weak typeof(self) ws = self;
        lsForKeyBlock = ^FBLineSpaceMaker*(NSString* key) {
            FBLineSpaceMaker* maker = [ws.fb_lgl_lsMakerMapper valueForKey:key];
            if (!maker) {
                maker = [FBLineSpaceMaker new];
                [ws.fb_lgl_lsMakerMapper setValue:maker forKey:key];
            }
            return maker;
        };
        objc_setAssociatedObject(self, _cmd, lsForKeyBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return lsForKeyBlock;
}

- (void)fb_lsEnumerateMakersUsingBlock:(void (^)(NSString *, FBLineSpaceMaker *))block
{
    [self.fb_lgl_lsMakerMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        block(key, obj);
    }];
}

- (NSMutableDictionary *)fb_lgl_lsMakerMapper
{
    NSMutableDictionary* mDic = objc_getAssociatedObject(self, _cmd);
    if (!mDic) {
        mDic = [NSMutableDictionary dictionaryWithCapacity:2];
        objc_setAssociatedObject(self, _cmd, mDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return mDic;
}

#pragma mark - - model配置
- (void)configReuseCellClass:(Class)reuseCellClass andIdentifier:(NSString *)reuseIdentifier inScrollView:(UIScrollView *)scrollView
{
    [self.cellClassStorage setValue:reuseCellClass forKey:[self storageKeyForScrollView:scrollView]];
    [self.reuseIdentifierStorage setValue:reuseIdentifier forKey:[self storageKeyForScrollView:scrollView]];
}

- (Class)reuseCellClassInScrollView:(UIScrollView *)scrollView
{
    return [self.cellClassStorage objectForKey:[self storageKeyForScrollView:scrollView]];
}

- (NSString*)reuseIdentifierInScrollView:(UIScrollView *)scrollView
{
    return [self.reuseIdentifierStorage valueForKey:[self storageKeyForScrollView:scrollView]];
}

#pragma mark - - 是否使用缓存的cell高度
- (void)useHeightCache:(BOOL)usingHeightCache inScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self cacheKeyOfScrollView:scrollView];
    [self.usingHeightCacheStorage setValue:@(usingHeightCache) forKey:key];
}

- (BOOL)usingHeightCacheInScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self cacheKeyOfScrollView:scrollView];
    NSNumber* usingObj = [self.usingHeightCacheStorage valueForKey:key];
    return usingObj ? [usingObj boolValue] : NO;
}

#pragma mark - - 高度缓存
- (void)cacheCellHeight:(CGFloat)cellHeight inScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self cacheKeyOfScrollView:scrollView];
    [self.cellHeightCache setValue:@(cellHeight) forKey:key];
}

- (CGFloat)cellHeightInScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self cacheKeyOfScrollView:scrollView];
    NSNumber* cellHeight = [self.cellHeightCache valueForKey:key];
    if (!cellHeight) {
        return -1;
    }
    else {
        return [cellHeight floatValue];
    }
}

- (void)clearHeightCacheInScrollView:(UIScrollView *)scrollView
{
    NSString* key = [self cacheKeyOfScrollView:scrollView];
    [self.cellHeightCache setValue:nil forKey:key];
}

#pragma mark - - private
- (NSString*)cacheKeyOfScrollView:(UIScrollView*)scrollView
{
    NSString* reuseID = [self reuseIdentifierInScrollView:scrollView];
    NSString* key = [NSString stringWithFormat:@"%p-%@", scrollView, reuseID];
    return key;
}

- (NSString*)storageKeyForScrollView:(UIScrollView*)scrollView
{
    NSString* key = [NSString stringWithFormat:@"%p", scrollView];
    return key;
}

#define kCellHeightCache       @"kCellHeightCache"
- (NSMutableDictionary *)cellHeightCache
{
    NSMutableDictionary* cellHeightCache = objc_getAssociatedObject(self, kCellHeightCache);
    if (!cellHeightCache) {
        cellHeightCache = [NSMutableDictionary dictionaryWithCapacity:2];
        objc_setAssociatedObject(self, kCellHeightCache, cellHeightCache, OBJC_ASSOCIATION_RETAIN);
    }
    return cellHeightCache;
}

#define kUsingHeightCacheStorage    @"kUsingHeightCacheStorage"
- (NSMutableDictionary *)usingHeightCacheStorage
{
    NSMutableDictionary* usingStorage = objc_getAssociatedObject(self, kUsingHeightCacheStorage);
    if (!usingStorage) {
        usingStorage = [NSMutableDictionary dictionaryWithCapacity:2];
        objc_setAssociatedObject(self, kUsingHeightCacheStorage, usingStorage, OBJC_ASSOCIATION_RETAIN);
    }
    return usingStorage;
}

#define kCellClassStorage   @"kCellClassStorage"
- (NSMutableDictionary *)cellClassStorage
{
    NSMutableDictionary* mDic = objc_getAssociatedObject(self, kCellClassStorage);
    if (!mDic) {
        mDic = [NSMutableDictionary dictionaryWithCapacity:6];
        objc_setAssociatedObject(self, kCellClassStorage, mDic, OBJC_ASSOCIATION_RETAIN);
    }
    return mDic;
}

#define kReuseIdentifierStorage     @"kReuseIdentifierStorage"
- (NSMutableDictionary *)reuseIdentifierStorage
{
    NSMutableDictionary* mDic = objc_getAssociatedObject(self, kReuseIdentifierStorage);
    if (!mDic) {
        mDic = [NSMutableDictionary dictionaryWithCapacity:6];
        objc_setAssociatedObject(self, kReuseIdentifierStorage, mDic, OBJC_ASSOCIATION_RETAIN);
    }
    return mDic;
}

@end
