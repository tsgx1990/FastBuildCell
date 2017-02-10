//
//  UITableViewCell+FastBuild.m
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "UITableViewCell+FastBuild.h"
#import <objc/runtime.h>

@implementation UITableViewCell (FastBuild)

- (void)setFb_indexPath:(NSIndexPath *)fb_indexPath
{
    objc_setAssociatedObject(self, @selector(fb_indexPath), fb_indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSIndexPath *)fb_indexPath
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFb_tableView:(UITableView *)fb_tableView
{
    objc_setAssociatedObject(self, @selector(fb_tableView), fb_tableView, OBJC_ASSOCIATION_ASSIGN);
}

- (UITableView *)fb_tableView
{
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - - override
- (UIView *)fb_concernedContentView
{
    return self.contentView;
}

@end
