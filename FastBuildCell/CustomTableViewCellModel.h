//
//  CustomTableViewCellModel.h
//  FastBuildCell
//
//  Created by guanglong on 2017/2/7.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomTableHeaderModel.h"

@interface CustomTableViewCellModel : NSObject

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subTitle;
@property (nonatomic, retain) CustomTableHeaderModel* headerModel;

@end
