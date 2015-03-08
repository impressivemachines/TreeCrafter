//
//  IMButtonView.m
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 6/7/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMPaneView.h"
#import "IMGlobal.h"

@implementation IMPaneView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // transparent background
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [IMGlobal drawMenuContainerWithBounds:self.bounds rightSide:self.isRightSide];
}


@end
