//
//  UITableViewCell+FastBuild.h
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (FastBuild)


@property (nonatomic, readonly) CGFloat heightAfterInitialization;

- (CGFloat)heightAfterInitializationWithContentWidth:(CGFloat)contentViewWidth;

@property (nonatomic, retain) NSIndexPath* indexPath;
@property (nonatomic, weak) UITableView* tableView;

@property (nonatomic, copy) void(^didSelectBlock)(NSIndexPath* indexPath);
@property (nonatomic, copy) void(^clickEventsBlock)(NSIndexPath* indexPath, id sender);
@property (nonatomic, copy) void(^clickFlagEventsBlock)(NSIndexPath* indexPath, id sender, int flag);

@end


@interface UITableViewCell()

- (instancetype)cellWithInfo:(id)info;

- (CGFloat)cellHeightWithInfo:(id)info;

// 在计算高度时指定contentView的宽度约束，不指定的话，将根据横屏或竖屏确定contentView的宽度
@property (nonatomic) CGFloat cellContentViewWidth;

// 在计算高度时制定contentView距左右的总边距，不指定的话，将根据横屏或竖屏确定contentView的宽度
@property (nonatomic) CGFloat cellContentViewHorizonMargin;
@property (nonatomic) CGFloat cellContentViewVerticalMargin;

@end
