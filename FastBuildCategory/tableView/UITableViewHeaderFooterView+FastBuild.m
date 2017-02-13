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
    [self fb_setWeakValue:fb_tableView forkey:@selector(fb_tableView)];
}

- (UITableView *)fb_tableView
{
    return [self fb_weakValueForKey:_cmd];
}

#pragma mark - - override
- (UIView *)fb_concernedContentView
{
    return self.contentView;
}

@end
