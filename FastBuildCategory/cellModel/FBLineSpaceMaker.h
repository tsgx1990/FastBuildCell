//
//  FBLineSpaceModel.h
//  FastBuildCell
//
//  Created by guanglong on 2017/2/7.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBLineSpaceMaker : NSObject

@property (nonatomic, readonly) FBLineSpaceMaker*(^setLabel)(UILabel* label);
@property (nonatomic, readonly) FBLineSpaceMaker*(^setTitle)(NSString* title);
@property (nonatomic, readonly) FBLineSpaceMaker*(^setLineSpace)(CGFloat lineSpace);

@property (nonatomic, readonly) CGFloat lineSpace;
@property (nonatomic, readonly) UILabel* label;
@property (nonatomic, readonly) NSString* title;

@end

