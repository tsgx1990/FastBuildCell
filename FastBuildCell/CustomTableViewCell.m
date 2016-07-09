//
//  CustomTableViewCell.m
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "CustomTableViewCell.h"
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

- (CGFloat)cellHeightWithInfo:(NSString*)title
{
    self.titleLbl.text = title;
    return self.heightAfterInitialization;
}

- (instancetype)cellWithInfo:(NSString*)title
{
    self.titleLbl.text = title;
    return self;
}

@end
