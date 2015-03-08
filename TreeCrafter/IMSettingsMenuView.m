//
//  IMSettingsMenuView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/23/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMSettingsMenuView.h"
#import "IMGlobal.h"
#import <QuartzCore/QuartzCore.h>

@implementation IMSettingsMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.title = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.font = [UIFont boldSystemFontOfSize:20];
        self.title.textColor = MENU_DARK_COLOR;//MENU_BG_COLOR;
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.shadowColor = [UIColor whiteColor];
        self.title.shadowOffset = CGSizeMake(0,1);
        [self addSubview:self.title];
        
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftButton setImage:[UIImage imageNamed:@"Ldark"] forState:UIControlStateNormal];
        //self.leftButton.backgroundColor = [UIColor greenColor];
        [self addSubview:self.leftButton];
        
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rightButton setImage:[UIImage imageNamed:@"Rdark"] forState:UIControlStateNormal];
        //self.rightButton.backgroundColor = MENU_DARK_COLOR;
        [self addSubview:self.rightButton];
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelButton setImage:[UIImage imageNamed:@"Xdark"] forState:UIControlStateNormal];
        //self.cancelButton.backgroundColor = MENU_DARK_COLOR;
        [self addSubview:self.cancelButton];
        
        self.containerView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.containerView.backgroundColor = [UIColor clearColor];
        self.containerView.clipsToBounds = YES;
        [self addSubview:self.containerView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.containerView.frame = CGRectMake(8, 64, self.frame.size.width-16, self.frame.size.height-100);

    self.title.frame = CGRectMake(0, 2, self.frame.size.width, 60);
    float y = 17;
    float s = 30;
    float inset = 22;
    float dx = 20;
    self.cancelButton.frame = CGRectMake(inset,y,s,s);
    self.leftButton.frame = CGRectMake(self.frame.size.width-s-inset-s-dx,y,s,s);
    self.rightButton.frame = CGRectMake(self.frame.size.width-s-inset,y,s,s);
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [IMGlobal drawControlContainerWithBounds:self.bounds];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    float w = self.frame.size.width;
    float y = 60;
    float r = 40;
    
    [MENU_LIGHT_COLOR set];
    
    CGContextSetLineWidth(ctx, 2);
    
    float offset = 8;
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, offset, y);
    CGContextAddArcToPoint(ctx, offset, offset, r, offset, r-offset);
    CGContextAddArcToPoint(ctx, w-offset, offset, w-offset, r, r-offset);
    CGContextAddLineToPoint(ctx, w-offset, y);
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFill);
}

- (void)dealloc
{
    DEBUG_LOG(@"IMSettingsMenuView dealloc");

    [_title release];
    [_cancelButton release];
    [_leftButton release];
    [_rightButton release];
    [_containerView release];
    
    [super dealloc];
}

@end
