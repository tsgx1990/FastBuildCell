//
//  CustomTableHeaderView.m
//  FastBuildCell
//
//  Created by guanglong on 2017/2/9.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import "CustomTableHeaderView.h"
#import "UILabel+AddUtils.h"
#import "Masonry.h"

@interface CustomTableHeaderView ()

@property (nonatomic, strong) UILabel* titleLbl;

@end

@implementation CustomTableHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLbl];
        [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(3);
            make.right.mas_equalTo(-3);
            make.top.mas_equalTo(12);
            make.bottom.mas_equalTo(-12);
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
        _titleLbl.backgroundColor = [UIColor brownColor];
        _titleLbl.numberOfLines = 0;
        _titleLbl.font = [UIFont systemFontOfSize:22];
    }
    return _titleLbl;
}

- (CGFloat)headerFooterHeightWithInfo:(CustomTableHeaderModel*)model
{
    [self fb_lsResetForModel:model make:^(NSObject *m) {
        
        m.fb_lsMakerForKey(@"1")
        .setLabel(self.titleLbl)
        .setTitle(model.title)
        .setLineSpace(15);
        
    } set:^(FBLineSpaceMaker *maker) {
        [maker.label xtt_setText:maker.title lineSpace:maker.lineSpace];
    }];
    
    return self.fb_heightAfterInitialization;
}

- (instancetype)headerFooterWithInfo:(CustomTableHeaderModel*)model
{
    CGFloat ls = model.fb_lsMakerForKey(@"1").lineSpace;
    [self.titleLbl xtt_asyncSetText:model.title lineSpace:ls complete:nil];
    return self;
}

@end
