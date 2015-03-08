//
//  IMPDFAdjusterView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/6/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMPDFAdjusterView.h"
#import <QuartzCore/QuartzCore.h>

@implementation IMPDFAdjusterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIColor *bgcolor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"blankbg"]];
        self.backgroundColor = bgcolor;
        [bgcolor release];
        
        self.topview = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.topview.backgroundColor = MENU_BG_COLOR;
        self.topview.layer.cornerRadius = 15;
        self.topview.layer.borderWidth = 3;
        self.topview.layer.borderColor = [[UIColor whiteColor] CGColor];
        [self addSubview:self.topview];
        
        self.bottomview = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.bottomview.backgroundColor = MENU_BG_COLOR;
        self.bottomview.layer.cornerRadius = 15;
        self.bottomview.layer.borderWidth = 3;
        self.bottomview.layer.borderColor = [[UIColor whiteColor] CGColor];
        [self addSubview:self.bottomview];
        
        self.moveandscalelabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.moveandscalelabel.textColor = [UIColor whiteColor];//MENU_LIGHT_COLOR;
        self.moveandscalelabel.text = NSLS_TOUCH_TO_MOVE__;
        self.moveandscalelabel.textAlignment = NSTextAlignmentCenter;
        self.moveandscalelabel.shadowColor = MENU_DARK_COLOR;
        self.moveandscalelabel.shadowOffset = CGSizeMake(0,-1);
        self.moveandscalelabel.font = [UIFont boldSystemFontOfSize:20];
        self.moveandscalelabel.backgroundColor = [UIColor clearColor];
        [self.bottomview addSubview:self.moveandscalelabel];
        
        self.orientationcontrol = [[[UISegmentedControl alloc] initWithItems:@[NSLS_PORTRAIT, NSLS_LANDSCAPE]] autorelease];
        self.orientationcontrol.selectedSegmentIndex = 0;
        [self.topview addSubview:self.orientationcontrol];
        
        self.detailcontrol = [[[UISegmentedControl alloc] initWithItems:@[NSLS_NORMAL, NSLS_HIGH_DETAIL]] autorelease];
        self.detailcontrol.selectedSegmentIndex = 0;
        /*
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if([language isEqualToString:@"ru"])
        {
            // special case for russian
            self.detailcontrol.apportionsSegmentWidthsByContent = YES;
            [self.detailcontrol setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:14.0f]
                                                                                   forKey:UITextAttributeFont]
                                              forState:UIControlStateNormal];
        }
        */
        [self.topview addSubview:self.detailcontrol];
        
        self.backgroundLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.backgroundLabel.textColor = [UIColor whiteColor];
        self.backgroundLabel.text = NSLS_BACKGROUND_FILL;
        self.backgroundLabel.textAlignment = NSTextAlignmentRight;
        self.backgroundLabel.font = [UIFont systemFontOfSize:16];
        self.backgroundLabel.backgroundColor = [UIColor clearColor];
        self.backgroundLabel.shadowColor = MENU_DARK_COLOR;
        self.backgroundLabel.shadowOffset = CGSizeMake(0,-1);
        self.backgroundLabel.numberOfLines = 0;
        [self.topview addSubview:self.backgroundLabel];
        
        self.backgroundSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
        self.backgroundSwitch.on = YES;
        [self.topview addSubview:self.backgroundSwitch];
        
        self.paperSizeButton = [[[IMRoundedButton alloc] initWithFrame:CGRectZero] autorelease];
        [self.topview addSubview:self.paperSizeButton];
        
        self.lineWidthSlider = [[[UISlider alloc] initWithFrame:CGRectZero] autorelease];
        self.lineWidthSlider.value = 0.5f;
        [self.topview addSubview:self.lineWidthSlider];
        
        self.lineWidthLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.lineWidthLabel.textColor = [UIColor whiteColor];
        //self.lineWidthLabel.text = NSLS_LINE_WEIGHT__1;
        self.lineWidthLabel.textAlignment = NSTextAlignmentCenter;
        self.lineWidthLabel.font = [UIFont systemFontOfSize:16];
        self.lineWidthLabel.backgroundColor = [UIColor clearColor];
        self.lineWidthLabel.shadowColor = MENU_DARK_COLOR;
        self.lineWidthLabel.shadowOffset = CGSizeMake(0,-1);
        [self.topview addSubview:self.lineWidthLabel];
        
        self.treeview = [[[IMImageAdjusterTreeView alloc] initWithFrame:CGRectZero] autorelease];
        [self.bottomview addSubview:self.treeview];
        
        m_paperSizeAspect = 1;
        m_orientation = 0;
        m_validLayout = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    DEBUG_LOG(@"IMPDFAdjusterView layoutSubviews aspect = %f", m_paperSizeAspect);
    [super layoutSubviews];
    
    float w, h;
    if(m_orientation==1)
    {
        w = 552;
        h = 552*m_paperSizeAspect;
    }
    else
    {
        w = 552*m_paperSizeAspect;
        h = 552;
    }
    
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        self.topview.frame = CGRectMake(20, 20, self.bounds.size.width - 40, 236);
        self.bottomview.frame = CGRectMake(20, 276, self.bounds.size.width - 40, self.bounds.size.height - 296);
        self.orientationcontrol.frame = CGRectMake(50, 40, 280, 36);
        self.detailcontrol.frame = CGRectMake(50, 102, 280, 36);
        
        self.backgroundLabel.frame = CGRectMake(50, 164, 160, 40);
        self.backgroundSwitch.frame = CGRectMake(230, 170, 36, 36);
        
        float x = 0.5f*(self.bottomview.frame.size.width - w);
        float y = 0.5f*(self.bottomview.frame.size.height - 30 - h) + 30;
        self.treeview.frame = CGRectMake(x, y, w, h);
        
        float rx = self.topview.frame.size.width - 280 - 50;
        
        self.paperSizeButton.frame = CGRectMake(rx, 40, 280, 36);
        self.lineWidthLabel.frame = CGRectMake(rx, 125, 280, 24);
        self.lineWidthSlider.frame = CGRectMake(rx, 150, 280, 34);
        
        self.moveandscalelabel.frame = CGRectMake(0, 15, self.bottomview.frame.size.width, 40);
    }
    else
    {
        self.topview.frame = CGRectMake(20, 20, 350, self.bounds.size.height - 40);
        self.bottomview.frame = CGRectMake(390, 20, self.bounds.size.width - 410, self.bounds.size.height - 40);
        self.orientationcontrol.frame = CGRectMake(35, 40, 280, 36);
        self.detailcontrol.frame = CGRectMake(35, 102, 280, 36);
        
        self.backgroundLabel.frame = CGRectMake(35, 166+62, 160, 36);
        self.backgroundSwitch.frame = CGRectMake(215, 170+62, 36, 36);
        
        self.paperSizeButton.frame = CGRectMake(35, 164, 280, 36);
        
        float x = 0.5f*(self.bottomview.frame.size.width - w);
        float y = 0.5f*(self.bottomview.frame.size.height - 30 - h) + 30;
        self.treeview.frame = CGRectMake(x, y, w, h);
        
        float rx = 35;
        
        self.lineWidthLabel.frame = CGRectMake(rx, 330, self.topview.frame.size.width - 2*rx, 24);
        self.lineWidthSlider.frame = CGRectMake(rx, 355, self.topview.frame.size.width - 2*rx, 34);
        
        self.moveandscalelabel.frame = CGRectMake(0, 15, self.bottomview.frame.size.width, 40);
    }
    
    [self.paperSizeButton setButtonText:m_paperSizeLabel];
    
    m_validLayout = YES;
}

- (int)orientation
{
    return m_orientation;
}

- (void)setOrientation: (int)orientation
{
    if(orientation!=m_orientation)
    {
        m_orientation = orientation;
        self.treeview.drawScale = 0;
        if(m_validLayout) // just stops un-necessary re-layouts at start up
            [self setNeedsLayout];
    }
}

- (void)setPaperSizeAspect:(float)aspect
{
    if(aspect!=m_paperSizeAspect)
    {
        m_paperSizeAspect = aspect;
        if(m_validLayout) // just stops un-necessary re-layouts at start up
            [self setNeedsLayout];
    }
}

- (void)setPaperSizeLabel:(NSString *)label
{
    if(label!=m_paperSizeLabel)
    {
        NSString *tmp = m_paperSizeLabel;
        m_paperSizeLabel = [label retain];
        [tmp release];
        
        if(m_validLayout) // size of button is not valid until first layout
            [self.paperSizeButton setButtonText:m_paperSizeLabel];
    }
}

- (void)dealloc
{
    DEBUG_LOG(@"IMPDFAdjusterView dealloc");

    [_topview release];
    [_bottomview release];
    [_treeview release];
    [_orientationcontrol release];
    [_detailcontrol release];
    [_lineWidthLabel release];
    [_lineWidthSlider release];
    [_paperSizeButton release];
    [_backgroundLabel release];
    [_backgroundSwitch release];
    [_moveandscalelabel release];
    [m_paperSizeLabel release];
    
    [super dealloc];
}

@end
