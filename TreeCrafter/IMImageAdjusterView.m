//
//  IMImageAdjusterView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/2/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMImageAdjusterView.h"
#import <QuartzCore/QuartzCore.h>

@implementation IMImageAdjusterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        DEBUG_LOG(@"IMImageAdjusterView initWithFrame");
        
        // Initialization code
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
        
        self.titletext = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
        self.titletext.placeholder = NSLS_HEADER_MESSAGE;
        self.titletext.backgroundColor = [UIColor whiteColor];
        self.titletext.borderStyle = UITextBorderStyleRoundedRect;
        self.titletext.font = [UIFont systemFontOfSize:18];
        self.titletext.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.titletext.delegate = self;
        self.titletext.tag = 0;
        //self.titletext.layer.cornerRadius = 10;
        //self.titletext.layer.borderWidth = 2;
        //self.titletext.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        [self.topview addSubview:self.titletext];
        
        self.footertext = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
        self.footertext.placeholder = NSLS_FOOTER_MESSAGE;
        self.footertext.backgroundColor = [UIColor whiteColor];
        self.footertext.borderStyle = UITextBorderStyleRoundedRect;
        self.footertext.font = [UIFont systemFontOfSize:18];
        self.footertext.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.footertext.delegate = self;
        self.footertext.tag = 1;
        //self.footertext.layer.cornerRadius = 10;
        //self.footertext.layer.borderWidth = 2;
        //self.footertext.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [self.topview addSubview:self.footertext];
        
        
        self.addimagebutton = [[[IMRoundedButton alloc] initWithFrame:CGRectZero] autorelease];
        [self.topview addSubview:self.addimagebutton];
        
        self.textcolorbutton = [[[IMRoundedButton alloc] initWithFrame:CGRectZero] autorelease];
        [self.topview addSubview:self.textcolorbutton];
        
        self.removeimagebutton = [[[IMRoundedButton alloc] initWithFrame:CGRectZero] autorelease];
        self.removeimagebutton.enabled = NO;
        [self.topview addSubview:self.removeimagebutton];
        
        self.imagelabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.imagelabel.textColor = [UIColor whiteColor];
        self.imagelabel.text = NSLS_BACKGOUND_IMAGE;
        self.imagelabel.textAlignment = NSTextAlignmentRight;
        self.imagelabel.font = [UIFont systemFontOfSize:16];
        self.imagelabel.backgroundColor = [UIColor clearColor];
        self.imagelabel.shadowColor = MENU_DARK_COLOR;
        self.imagelabel.shadowOffset = CGSizeMake(0,-1);
        self.imagelabel.numberOfLines = 0;
        [self.topview addSubview:self.imagelabel];
        
        self.textcolorlabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.textcolorlabel.textColor = [UIColor whiteColor];
        self.textcolorlabel.text = NSLS_TEXT_COLOR;
        self.textcolorlabel.textAlignment = NSTextAlignmentRight;
        self.textcolorlabel.font = [UIFont systemFontOfSize:16];
        self.textcolorlabel.backgroundColor = [UIColor clearColor];
        self.textcolorlabel.shadowColor = MENU_DARK_COLOR;
        self.textcolorlabel.shadowOffset = CGSizeMake(0,-1);
        [self.topview addSubview:self.textcolorlabel];
        
        self.treeview = [[[IMImageAdjusterTreeView alloc] initWithFrame:CGRectZero] autorelease];
        [self.bottomview addSubview:self.treeview];
        
        m_textColor = [[UIColor colorWithHue:0 saturation:0 brightness:1 alpha:1] retain];
    }
    return self;
}

- (void)layoutSubviews
{
    DEBUG_LOG(@"IMImageAdjusterView layoutSubviews");
    [super layoutSubviews];
    
    float w, h;
    if(m_orientation==1)
    {
        w = 552;
        h = 552*0.75;
    }
    else
    {
        w = 552*0.75f;
        h = 552;
    }
    
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        self.topview.frame = CGRectMake(20, 20, self.bounds.size.width - 40, 236);
        self.bottomview.frame = CGRectMake(20, 276, self.bounds.size.width - 40, self.bounds.size.height - 296);
        
        float row3y = 160;
        float bix = 30;
        
        float x = 0.5f*(self.bottomview.frame.size.width - w);
        float y = 0.5f*(self.bottomview.frame.size.height - 30 - h) + 30;
        self.treeview.frame = CGRectMake(x, y, w, h);
        
        self.moveandscalelabel.frame = CGRectMake(0, 15, self.bottomview.frame.size.width, 40);
        self.orientationcontrol.frame = CGRectMake(50, 40, 280, 36);
        self.detailcontrol.frame = CGRectMake(50, 90, 280, 36);
        self.titletext.frame = CGRectMake(380, 40, 290, 36);
        self.footertext.frame = CGRectMake(380, 90, 290, 36);
        
        self.addimagebutton.frame = CGRectMake(190+bix, row3y, 90, 36);
        self.textcolorbutton.frame = CGRectMake(540+bix, row3y, 90, 36);
        self.removeimagebutton.frame = CGRectMake(290+bix, row3y, 90, 36);
        
        self.imagelabel.frame = CGRectMake(20+bix, row3y-2, 160, 40);
        self.textcolorlabel.frame = CGRectMake(390+bix, row3y-2, 140, 40);
    }
    else
    {
        self.topview.frame = CGRectMake(20, 20, 350, self.bounds.size.height - 40);
        self.bottomview.frame = CGRectMake(390, 20, self.bounds.size.width - 410, self.bounds.size.height - 40);
        
        float x = 0.5f*(self.bottomview.frame.size.width - w);
        float y = 0.5f*(self.bottomview.frame.size.height - 30 - h) + 30;
        self.treeview.frame = CGRectMake(x, y, w, h);
        
        self.moveandscalelabel.frame = CGRectMake(0, 15, self.bottomview.frame.size.width, 40);
        
        self.orientationcontrol.frame = CGRectMake(35, 40, 280, 36);
        self.detailcontrol.frame = CGRectMake(35, 90, 280, 36);
        
        self.titletext.frame = CGRectMake(35, 166, 280, 36);
        self.footertext.frame = CGRectMake(35, 216, 280, 36);
        
        self.textcolorlabel.frame = CGRectMake(35, 290, 180, 40);
        self.textcolorbutton.frame = CGRectMake(225, 292, 90, 36);
        
        self.imagelabel.frame = CGRectMake(35, 366, 180, 40);
        self.addimagebutton.frame = CGRectMake(225, 368, 90, 36);
        self.removeimagebutton.frame = CGRectMake(225, 418, 90, 36);
    }
    
    [self.addimagebutton setButtonText:NSLS_ADD];
    [self.removeimagebutton setButtonText:NSLS_REMOVE];
    [self.textcolorbutton setButtonColor:m_textColor];
    self.treeview.textColor = m_textColor;
}

// orientation property

- (int)orientation
{
    return m_orientation;
}

- (void)setOrientation: (int)orientation
{
    m_orientation = orientation;
    self.treeview.drawScale = 0;
    [self setNeedsLayout];
}

// text color property

- (void)setTextColor:(UIColor *)color
{
    if(m_textColor!=color)
    {
        UIColor *oldColor = m_textColor;
        m_textColor = [color retain];
        [oldColor release];
        
        [self.textcolorbutton setButtonColor:m_textColor];
        [self.treeview setTextColor:m_textColor];
    }
}

- (UIColor *)textColor
{
    return [[m_textColor retain] autorelease];
}

// text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // turn off view interaction
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag==0)
    {
        // header
        self.treeview.headerText = textField.text;
    }
    else
    {
        // footer
        self.treeview.footerText = textField.text;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.titletext resignFirstResponder];
    [self.footertext resignFirstResponder];
    
    [super touchesBegan:touches withEvent:event];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMImageAdjusterView dealloc");
    
    [m_textColor release];
    [_treeview release];
    [_topview release];
    [_bottomview release];
    [_orientationcontrol release];
    [_detailcontrol release];
    [_titletext release];
    [_footertext release];
    [_imagelabel release];
    [_textcolorlabel release];
    [_addimagebutton release];
    [_removeimagebutton release];
    [_textcolorbutton release];
    [_moveandscalelabel release];
    
    [super dealloc];
}

@end
