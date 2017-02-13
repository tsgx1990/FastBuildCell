//
//  ViewController.m
//  FastBuildCell
//
//  Created by guanglong on 16/6/23.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "ViewController.h"
#import "CustomTableViewCell.h"
#import "CustomTableHeaderView.h"
#import "CustomTableTopHeader.h"
#import "Masonry.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UITableViewCacheDelegate>

@property (nonatomic, strong) CustomTableTopHeader* topHeader;
@property (nonatomic, strong) UITableView* mTableView;
@property (nonatomic, strong) NSArray* dataArray;

@property (nonatomic, strong) NSHashTable* hashTable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.mTableView];
    [self.mTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    // test hashTable
    self.hashTable = [NSHashTable weakObjectsHashTable];
    UIView* testView = [[UIView alloc] initWithFrame:CGRectMake(40, 40, 20, 20)];
    testView.backgroundColor = [UIColor darkGrayColor];
    [self.hashTable addObject:testView];
//    [self.view addSubview:testView];
}

- (void)getDataArray
{
    self.dataArray = @[
                       @"在ios8以上系统中，存在tableView在滑动过程中会重新计算cell高度的问题。虽然可以通过设置tableView.estimatedRowHeight，以及cell的约束，让系统自动计算cell的高度，但是这种方式却并不适合ios7。",
                       @"I  该轮子可以解决以下问题：",
                       @"1，为了兼容ios7，同时考虑到在ios8以上系统中cell高度会重新计算的问题",
                       @"2，计算并缓存cell高度，提升在ios8以上系统上tableView滑动的流畅性",
                       @"3，为了快速创建含有多类型cell的复杂tableView",
                       @"4，解耦",
                       @"5，瘦身viewController，将cell的赋值操作抽离出来，在自定义的cell中进行",
                       @"6，转屏的情况下仍能正确获取cell高度",
//
//                       @"II  该轮子使用起来也并不复杂：",
//                       
//                       @"III  特别说明：",
//                       @"1，headerFooter的高度没有重复计算的问题（转屏时会重新计算），所以不用考虑高度缓存问题",
//                       @"2，默认情况下会使用cell的高度缓存，而不是重新计算。也可以通过实现 UITableViewCacheDelegate协议的相关方法来控制是否使用缓存，或者调用model的 fb_clearHeightCacheInScrollView:方法强行清除该model的高度缓存",
//                       @"3，在[tableView reloadData] 的时候会清除所有cell的高度缓存",
//                       @"4，缓存的高度存储在model中，以model所属cell的reuseIdentifier和tableView组成的key值进行存取",
//                       
//                       @"IV  敬请期待：",
//                       @"后续将推出针对collectionView的快速构建功能，collectionViewCell的高度没有重复计算的问题",
//                       @"headerFooter复用仍需进一步完善"
                       ];
    
    NSMutableArray* mArr = @[].mutableCopy;
    for (NSString* title in self.dataArray) {
        CustomTableViewCellModel* model = CustomTableViewCellModel.new;
        model.title = title;
        model.subTitle = [title substringFromIndex:title.length*0.3];
        CustomTableHeaderModel* hModel = [CustomTableHeaderModel new];
        hModel.title = [title substringToIndex:title.length*0.7];
        model.headerModel = hModel;
        [mArr addObject:model];
    }
    self.dataArray = mArr;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self resetTableHeaderView];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getDataArray];
    [self.mTableView reloadData];
    [self resetTableHeaderView];
}

- (void)resetTableHeaderView
{
//    NSString* title = @"默认情况下会使用cell的高度缓存，而不是重新计算。也可以通过实现 UITableViewCacheDelegate协议的相关方法来控制是否使用缓存";
//    title = [title substringToIndex:arc4random()%(title.length-1) * 0.8];
    
    NSString* title = [self.dataArray[0] title];
    [self.mTableView fb_reloadTableHeaderView:self.topHeader withInfo:title];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - - UITableViewCacheDelegate
// 不实现该方法，会默认使用cell缓存
//- (BOOL)tableView:(UITableView *)tableView usingHeightCacheForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

#pragma mark - - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
//    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView fb_registerClassWithCellModels:self.dataArray modelConfigBlock:^(UITableView *tableView, id model) {
        [model fb_configReuseViewClass:[CustomTableViewCell class] andIdentifier:@"cellID" inScrollView:tableView];
    }];
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fb_cellHeightWithCellModels:self.dataArray forIndexPath:indexPath];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fb_cellWithCellModels:self.dataArray forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", self.hashTable.anyObject);
    [self.hashTable.anyObject removeFromSuperview];
}

#pragma mark - - header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CustomTableHeaderModel* hModel = [self.dataArray[section] headerModel];
    [tableView fb_registerClass:[CustomTableHeaderView class] forViewReuseIdentifier:@"headerID" withInfo:hModel];
    return [tableView fb_heightForHeaderFooterWithInfo:hModel];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CustomTableHeaderModel* hModel = [self.dataArray[section] headerModel];
    return [tableView fb_dequeueReusableHeaderFooterViewWithInfo:hModel inSection:section];
}

#pragma mark - - footer
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    return [UIView new];
//}

- (UITableView *)mTableView
{
    if (!_mTableView) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
//        _mTableView.fb_cacheDelegate = self;
    }
    return _mTableView;
}

- (CustomTableTopHeader *)topHeader
{
    if (!_topHeader) {
        _topHeader = [[CustomTableTopHeader alloc] init];
    }
    return _topHeader;
}

- (void)dealloc
{
    
}

@end
