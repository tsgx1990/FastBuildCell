//
//  FBLineSpaceModel.m
//  FastBuildCell
//
//  Created by guanglong on 2017/2/7.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import "FBLineSpaceMaker.h"

#define FB_LINESPACE_WEAKSELF  __weak typeof(self) ws = self;

@interface FBLineSpaceMaker ()

@end

@implementation FBLineSpaceMaker

@synthesize setLabel, setTitle, setLineSpace;
@synthesize title, label, lineSpace;

- (FBLineSpaceMaker *(^)(UILabel *))setLabel
{
    if (!setLabel) {
        FB_LINESPACE_WEAKSELF;
        setLabel = ^FBLineSpaceMaker* (UILabel* lbl) {
            label = lbl;
            return ws;
        };
    }
    return setLabel;
}

- (FBLineSpaceMaker *(^)(NSString *))setTitle
{
    if (!setTitle) {
        FB_LINESPACE_WEAKSELF;
        setTitle = ^FBLineSpaceMaker* (NSString* text) {
            title = text;
            return ws;
        };
    }
    return setTitle;
}

- (FBLineSpaceMaker *(^)(CGFloat))setLineSpace
{
    if (!setLineSpace) {
        FB_LINESPACE_WEAKSELF;
        setLineSpace = ^FBLineSpaceMaker* (CGFloat space) {
            lineSpace = space;
            return ws;
        };
    }
    return setLineSpace;
}

@end

