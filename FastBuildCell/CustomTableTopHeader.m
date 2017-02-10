//
//  CustomTableTopHeader.m
//  FastBuildCell
//
//  Created by guanglong on 2017/2/10.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import "CustomTableTopHeader.h"
#import "UILabel+AddUtils.h"
#import "Masonry.h"

@interface CustomTableTopHeader ()

@property (nonatomic, strong) UILabel* titleLbl;

@end

@implementation CustomTableTopHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = self.contentView.backgroundColor = [UIColor purpleColor];
        [self.contentView addSubview:self.titleLbl];
        [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.top.mas_equalTo(10);
            make.bottom.mas_equalTo(-10);
        }];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UILabel *)titleLbl
{
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.backgroundColor = [UIColor greenColor];
        _titleLbl.numberOfLines = 0;
        _titleLbl.font = [UIFont systemFontOfSize:22];
    }
    return _titleLbl;
}

- (instancetype)fb_viewWithInfo:(NSString*)model
{
    [self fb_lsResetForModel:model make:^(NSObject *m) {
        m.fb_lsMakerForKey(@"")
        .setLabel(self.titleLbl)
        .setTitle(model)
        .setLineSpace(12);
    } set:^(FBLineSpaceMaker *maker) {
        [maker.label xtt_setText:maker.title lineSpace:maker.lineSpace];
    }];
    return self;
}

@end
