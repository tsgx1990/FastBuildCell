//
//  UITableViewHeaderFooterView+FastBuild.m
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "UITableViewHeaderFooterView+FastBuild.h"
#import <objc/runtime.h>

@implementation UITableViewHeaderFooterView (FastBuild)

- (void)setFb_section:(NSInteger)fb_section
{
    objc_setAssociatedObject(self, @selector(fb_section), @(fb_section), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)fb_section
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
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
