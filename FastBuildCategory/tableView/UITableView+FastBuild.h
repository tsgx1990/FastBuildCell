//
//  UITableView+FastBuild.h
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol UITableViewCacheDelegate <NSObject>

@optional
// 用于通过方法 - (CGFloat)cellHeightWithCellModels:(NSArray*)cellModels forIndexPath:(NSIndexPath*)indexPath; 返回cell高度时，决定是否使用缓存。
- (BOOL)tableView:(UITableView*)tableView usingHeightCacheForRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface UITableView (FastBuild)

@property (nonatomic, weak) id<UITableViewCacheDelegate> cacheDelegate;

// 该方法任何情况下都不会使用高度缓存
- (CGFloat)cellHeightForCellClass:(Class)cellClass withCallBlock:(void(^)(id calCell))calBlock;

// 如果对model设置了可以使用高度缓存，则该方法返回缓存的高度
- (CGFloat)cellHeightForCellClass:(Class)cellClass withInfo:(id)info;

// 在滑动过程中headerFooter的高度不会重复计算，故不用考虑缓存问题
- (CGFloat)headerFooterHeightForClass:(Class)headerFooterClass withCallBlock:(void(^)(id calCell))calBlock;
- (CGFloat)headerFooterHeightForClass:(Class)headerFooterClass withInfo:(id)info;


#pragma mark - - 快捷创建tableView的系列方法
#pragma mark - 使用以下方法的条件：
// 对于计算高度，需要实现cell的cellHeightWithInfo:或者cellWithInfo:方法
// 对于创建cell，必须要实现cell的cellWithInfo:方法
// 最重要的是，在configBlock中需要对model调用 configReuseCellClass: andIdentifier: inTableView:进行配置
// 考虑到tableView数据源的添加和删除操作，该方法建议在 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 中调用
- (void)registerClassWithCellModels:(NSArray *)cellModels modelConfigBlock:(void (^)(UITableView* tableView, id model))configBlock;

// 计算高度之后，默认情况会缓存cell高度
// 有两种方式决定是否适用高度缓存，
//一种是实现 UITableViewCacheDelegate 里的相关方法，
//另一种是对model直接调用 - useHeightCache: inScrollView: 方法

- (CGFloat)cellHeightWithCellModels:(NSArray*)cellModels forIndexPath:(NSIndexPath*)indexPath;
- (UITableViewCell*)cellWithCellModels:(NSArray*)cellModels forIndexPath:(NSIndexPath*)indexPath;


@end
