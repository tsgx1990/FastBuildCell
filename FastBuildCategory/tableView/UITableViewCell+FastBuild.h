//
//  UITableViewCell+FastBuild.h
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+FastBuild.h"

@interface UITableViewCell (FastBuild)

@property (nonatomic, retain) NSIndexPath* fb_indexPath;
@property (nonatomic, weak) UITableView* fb_tableView;

@end

// should maybe overrided
@interface UITableViewCell()

- (instancetype)cellWithInfo:(id)info;

- (CGFloat)cellHeightWithInfo:(id)info;

@end
