//
//  CustomTableViewCell.m
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "CustomTableViewCell.h"
#import "UILabel+AddUtils.h"
#import "Masonry.h"

@interface CustomTableViewCell()

@property (nonatomic, strong) UILabel* titleLbl;
@property (nonatomic, strong) UIImageView* imgView;

@end

@implementation CustomTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLbl];
        [self.contentView addSubview:self.imgView];
        [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.top.mas_equalTo(10);
        }];
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.equalTo(_titleLbl.mas_bottom).offset(10);
            make.bottom.mas_equalTo(-5);
            make.size.mas_equalTo(40);
        }];
    }
    return self;
}

- (UILabel *)titleLbl
{
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.backgroundColor = [UIColor orangeColor];
        _titleLbl.numberOfLines = 0;
        _titleLbl.font = [UIFont systemFontOfSize:20];
    }
    return _titleLbl;
}

- (UIImageView*)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.backgroundColor = [UIColor redColor];
    }
    return _imgView;
}

- (CGFloat)cellHeightWithInfo:(CustomTableViewCellModel*)model
{
    [self fb_lsResetForModel:model make:^(NSObject *m) {
        m.fb_lsMakerForKey(@"")
        .setLabel(self.titleLbl)
        .setTitle(model.title)
        .setLineSpace(18);
    } set:^(FBLineSpaceMaker *maker) {
        [maker.label xtt_setText:maker.title lineSpace:maker.lineSpace];
    }];
    return self.fb_heightAfterInitialization;
}

- (instancetype)cellWithInfo:(CustomTableViewCellModel*)model
{
    CGFloat ls = model.fb_lsMakerForKey(@"").lineSpace;
    [self.titleLbl xtt_asyncSetText:model.title lineSpace:ls complete:nil];
//    [self.titleLbl xtt_setText:model.title lineSpace:ls];
    return self;
}

- (void)dealloc
{
    
}

@end
