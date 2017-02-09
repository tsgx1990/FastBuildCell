//
//  UITableViewHeaderFooterView+FastBuild.h
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewHeaderFooterView (FastBuild)

@property (nonatomic, readonly) CGFloat fb_heightAfterInitialization;

- (CGFloat)fb_heightAfterInitializationWithContentWidth:(CGFloat)contentViewWidth;

@property (nonatomic, assign) NSInteger fb_section;
@property (nonatomic, weak) UITableView* fb_tableView;

@property (nonatomic, copy) void(^fb_didSelectBlock)(NSInteger section);
@property (nonatomic, copy) void(^fb_clickEventsBlock)(NSInteger section, id sender);
@property (nonatomic, copy) void(^fb_clickFlagEventsBlock)(NSInteger section, id sender, int flag);

@end


@interface UITableViewHeaderFooterView ()

- (instancetype)headerFooterWithInfo:(id)info;

- (CGFloat)headerFooterHeightWithInfo:(id)info;

// 在计算高度时指定contentView的宽度约束，不指定的话默认为屏幕宽度
@property (nonatomic) CGFloat headerFooterContentViewWidth;

@property (nonatomic) CGFloat headerFooterContentViewHorizonMargin;
@property (nonatomic) CGFloat headerFooterContentViewVerticalMargin;

@end
