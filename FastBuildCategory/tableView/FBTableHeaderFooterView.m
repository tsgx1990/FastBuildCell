//
//  FBTableHeaderFooterView.m
//  FastBuildCell
//
//  Created by guanglong on 2017/2/10.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import "FBTableHeaderFooterView.h"

@implementation FBTableHeaderFooterView
@synthesize contentView;

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
}

- (UIView *)contentView
{
    if (!contentView) {
        contentView = [UIView new];
        [self addSubview:contentView];
    }
    return contentView;
}

- (UIView *)fb_concernedContentView
{
    return self.contentView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
