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
@property (nonatomic, strong) UILabel* subTitleLbl;
@property (nonatomic, strong) UIImageView* imgView;

@end

@implementation CustomTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLbl];
        [self.contentView addSubview:self.subTitleLbl];
        [self.contentView addSubview:self.imgView];
        [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.top.mas_equalTo(10);
        }];
        [self.subTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLbl.mas_left);
            make.right.equalTo(self.titleLbl.mas_right);
            make.top.equalTo(self.titleLbl.mas_bottom).offset(20);
        }];
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.equalTo(self.subTitleLbl.mas_bottom).offset(10);
            make.bottom.mas_equalTo(-10);
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

- (UILabel *)subTitleLbl
{
    if (!_subTitleLbl) {
        _subTitleLbl = [UILabel new];
        _subTitleLbl.backgroundColor = [UIColor cyanColor];
        _subTitleLbl.numberOfLines = 0;
        _subTitleLbl.font = [UIFont systemFontOfSize:16];
    }
    return _subTitleLbl;
}

- (UIImageView*)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.backgroundColor = [UIColor redColor];
    }
    return _imgView;
}

- (CGFloat)fb_viewHeightWithInfo:(CustomTableViewCellModel*)model
{
    [self fb_lsResetForModel:model make:^(NSObject *m) {
        
        m.fb_lsMakerForKey(@"1")
        .setLabel(self.titleLbl)
        .setTitle(model.title)
        .setLineSpace(18);
        m.fb_lsMakerForKey(@"2")
        .setLabel(self.subTitleLbl)
        .setTitle(model.subTitle)
        .setLineSpace(8);
        
    } set:^(FBLineSpaceMaker *maker) {
        [maker.label xtt_setText:maker.title lineSpace:maker.lineSpace];
    }];
    return self.fb_heightAfterInitialization;
}

- (instancetype)fb_viewWithInfo:(CustomTableViewCellModel*)model
{
    CGFloat ls1 = model.fb_lsMakerForKey(@"1").lineSpace;
    [self.titleLbl xtt_asyncSetText:model.title lineSpace:ls1 complete:nil];
//    [self.titleLbl xtt_setText:model.title lineSpace:ls];
    
    CGFloat ls2 = model.fb_lsMakerForKey(@"2").lineSpace;
    [self.subTitleLbl xtt_asyncSetText:model.subTitle lineSpace:ls2 complete:nil];
    
    return self;
}

- (void)dealloc
{
    
}

@end
