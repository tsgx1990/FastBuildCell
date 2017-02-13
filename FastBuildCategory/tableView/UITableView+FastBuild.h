//
//  UITableView+FastBuild.h
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBTableHeaderFooterView.h"

@protocol UITableViewCacheDelegate <NSObject>

@optional
// 用于通过方法 - (CGFloat)fb_cellHeightWithCellModels:(NSArray*)cellModels forIndexPath:(NSIndexPath*)indexPath; 返回cell高度时，决定是否使用缓存。
- (BOOL)tableView:(UITableView*)tableView usingHeightCacheForRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface UITableView (FastBuild)

@property (nonatomic, weak) id<UITableViewCacheDelegate> fb_cacheDelegate;

// 该方法任何情况下都不会使用高度缓存
- (CGFloat)fb_cellHeightForCellClass:(Class)cellClass withCallBlock:(void(^)(id calCell))calBlock;

// 如果对model设置了可以使用高度缓存，则该方法返回缓存的高度
- (CGFloat)fb_cellHeightForCellClass:(Class)cellClass withInfo:(id)info;

// 如果已经对model对应的cellClass进行了配置，则可以直接调用此方法获取cell高度
// 如果对model设置了可以使用高度缓存，则该方法返回缓存的高度
- (CGFloat)fb_cellHeightWithModel:(NSObject*)model;

// 如果已经对model对应的cellClass进行了配置，则可以调用该方法获取model所对应的用于计算高度的cell
// 特别注意：返回的cell尚未通过model计算高度
- (__kindof UITableViewCell*)fb_rawCalculateCellForModel:(NSObject*)model;

// 如果已经对model对应的cellClass进行了配置，则可以调用该方法获取model所对应的用于显示的cell
// 特别注意：返回的cell尚未通过model进行赋值。
- (__kindof UITableViewCell*)fb_rawCellWithCellModels:(NSArray*)cellModels forIndexPath:(NSIndexPath*)indexPath;

// 在滑动过程中headerFooter的高度不会重复计算，故不用考虑缓存问题
- (CGFloat)fb_headerFooterHeightForClass:(Class)headerFooterClass withCallBlock:(void(^)(id calCell))calBlock;
- (CGFloat)fb_headerFooterHeightForClass:(Class)headerFooterClass withInfo:(id)info;

// 实现 headerFooter 重用，需要调用的系列方法：
// 该方法同样适用于 cell 的重用
- (void)fb_registerClass:(Class)aClass forViewReuseIdentifier:(NSString *)identifier withInfo:(id)info;
- (CGFloat)fb_heightForHeaderFooterWithInfo:(id)info;
- (__kindof UITableViewHeaderFooterView*)fb_dequeueReusableHeaderFooterViewWithInfo:(id)info inSection:(NSInteger)section;


#pragma mark - - 快捷创建tableView的系列方法
#pragma mark - 使用以下方法的条件：
// 对于计算高度，需要实现cell的 fb_viewHeightWithInfo: 或者 fb_viewWithInfo: 方法
// 对于创建cell，必须要实现cell的fb_viewWithInfo:方法
// 最重要的是，在configBlock中需要对model调用 fb_configReuseViewClass: andIdentifier: inTableView:进行配置
// 考虑到tableView数据源的添加和删除操作，该方法建议在 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 中调用
- (void)fb_registerClassWithCellModels:(NSArray *)cellModels modelConfigBlock:(void (^)(UITableView* tableView, id model))configBlock;

// 计算高度之后，默认情况会缓存cell高度
// 有两种方式决定是否适用高度缓存，
//一种是实现 UITableViewCacheDelegate 里的相关方法，
//另一种是对model直接调用 -fb_useHeightCache: inScrollView: 方法

// 特别注意：通过实现 UITableViewCacheDelegate 中的方法决定是否使用高度缓存的方式，只对通过－fb_cellHeightWithCellModels: forIndexPath: 计算高度的方式有效。
// 最终是否决定使用缓存还是要由model的 -fb_useHeightCache: inScrollView: 方法决定

// 默认情况下，无论使用什么方式（但是model需要配置）计算高度，是否使用高度缓存的开关都是开启的

- (CGFloat)fb_cellHeightWithCellModels:(NSArray*)cellModels forIndexPath:(NSIndexPath*)indexPath;
- (__kindof UITableViewCell*)fb_cellWithCellModels:(NSArray*)cellModels forIndexPath:(NSIndexPath*)indexPath;


// FBTableHeaderFooterView

// 以下两个方法均需要 tableHeaderView 实现 fb_viewWithInfo: 方法
- (void)fb_reloadTableHeaderView:(FBTableHeaderFooterView*)tableHeaderView withInfo:(id)info;

- (void)fb_reloadTableFooterView:(FBTableHeaderFooterView*)tableFooterView withInfo:(id)info;


@end
