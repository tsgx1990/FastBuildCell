//
//  FBLineSpaceModel.m
//  FastBuildCell
//
//  Created by guanglong on 2017/2/7.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import "FBLineSpaceMaker.h"
#import <objc/runtime.h>

#define FB_LINESPACE_WEAKSELF  __weak typeof(self) ws = self;

@interface FBLineSpaceMaker ()

@property (nonatomic, assign) CGFloat p_lineSpace;
@property (nonatomic, weak) UILabel* p_label;
@property (nonatomic, copy) NSString* p_title;

@end

@implementation FBLineSpaceMaker

@synthesize setLabel, setTitle, setLineSpace;
@synthesize title, label, lineSpace;

- (FBLineSpaceMaker *(^)(UILabel *))setLabel
{
    if (!setLabel) {
        FB_LINESPACE_WEAKSELF;
        setLabel = ^FBLineSpaceMaker* (UILabel* lbl) {
            ws.p_label = lbl;
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
            ws.p_title = text;
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
            ws.p_lineSpace = space;
            return ws;
        };
    }
    return setLineSpace;
}

- (UILabel *)label
{
    return self.p_label;
}

- (NSString *)title
{
    return self.p_title;
}

- (CGFloat)lineSpace
{
    return self.p_lineSpace;
}

- (void)dealloc
{
    
}

@end

