//
//  NSObject+FastBuild.h
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBLineSpaceMaker.h"

@interface NSObject (FastBuild)

@property (nonatomic, assign) CGFloat fb_lineSpace;

@property (nonatomic, readonly) FBLineSpaceMaker* (^fb_lsMakerForKey)(NSString* key);
- (void)fb_lsEnumerateMakersUsingBlock:(void(^)(NSString* key, FBLineSpaceMaker* maker))block;

// 配置model
- (void)configReuseCellClass:(Class)reuseCellClass andIdentifier:(NSString*)reuseIdentifier inScrollView:(UIScrollView*)scrollView;

- (Class)reuseCellClassInScrollView:(UIScrollView*)scrollView;
- (NSString*)reuseIdentifierInScrollView:(UIScrollView*)scrollView;

#pragma mark - - 是否使用缓存的cell高度
- (void)useHeightCache:(BOOL)usingHeightCache inScrollView:(UIScrollView*)scrollView;
- (BOOL)usingHeightCacheInScrollView:(UIScrollView*)scrollView;

#pragma mark - - 高度缓存
- (void)cacheCellHeight:(CGFloat)cellHeight inScrollView:(UIScrollView*)scrollView;

// 默认会返回-1
- (CGFloat)cellHeightInScrollView:(UIScrollView*)scrollView;

// 清理cell的高度缓存
- (void)clearHeightCacheInScrollView:(UIScrollView*)scrollView;


@end
