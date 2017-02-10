//
//  UITableViewHeaderFooterView+FastBuild.h
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+FastBuild.h"

@interface UITableViewHeaderFooterView (FastBuild)

@property (nonatomic, assign) NSInteger fb_section;
@property (nonatomic, weak) UITableView* fb_tableView;

@end

