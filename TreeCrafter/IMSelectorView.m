//
//  IMSelectorView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/14/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMSelectorView.h"
#import "IMGlobal.h"

#import <QuartzCore/QuartzCore.h>

@implementation IMSelectorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor whiteColor];
        self.label.text = @"?";
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:self.label];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        //self.button.backgroundColor = [UIColor darkGrayColor];
        //self.button.layer.cornerRadius = 8;
        [self.button setImage:[UIImage imageNamed:@"X"] forState:UIControlStateNormal];
        [self addSubview:self.button];
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        
        m_choices[0] = nil;
        m_choices[1] = nil;
        m_choices[2] = nil;
        m_choices[3] = nil;
        
        m_selected_index = -1;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.label.frame = CGRectMake(50, 12, self.bounds.size.width-80, 20);
    self.button.frame = CGRectMake(18, 18, 24, 24);
    
    int i, count = 0;
    for(i=0; i<4; i++)
        if(m_choices[i])
            count++;
    
    float cw = (count-1)*60 + 50;
    float x = (self.bounds.size.width - cw)/2;
        
    for(i=0; i<4; i++)
        if(m_choices[i])
            m_choices[i].frame = CGRectMake(x + i*60, 60, 50, 50);
}

- (void)drawRect:(CGRect)rect
{
    [IMGlobal drawControlContainerWithBounds:self.bounds];
}

- (void)createChoices:(int)count
{
    if(count<0 || count>4)
        return;
    
    int i;
    for(i=0; i<count; i++)
    {
        if(!m_choices[i])
        {
            m_choices[i] = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
            //m_choices[i].layer.cornerRadius = 6;
            m_choices[i].tag = i;
            [m_choices[i] addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:m_choices[i]];
        }
        
        //if(i==m_selected_index)
        //    m_choices[i].backgroundColor = [UIColor colorWithRed:0.9 green:0.3 blue:0.5  alpha:1];
        //else
        //   m_choices[i].backgroundColor = MENU_LIGHT_COLOR;
    }
    for(; i<4; i++)
    {
        if(m_choices[i])
        {
            [m_choices[i] removeFromSuperview];
            [m_choices[i] release];
            m_choices[i] = nil;
        }
    }
}

- (void)update
{
    m_selected_index = (int)[self.delegate getParam:self.target];
    
    switch(self.target)
    {
        case ID_ANGLEMODE:
            if([self.delegate getParam:ID_TREETYPE]==0)
                [self createChoices:4];
            else
                [self createChoices:3];
            if(m_selected_index==0)
                [m_choices[0] setImage:[UIImage imageNamed:@"2d_s"] forState:UIControlStateNormal];
            else
                [m_choices[0] setImage:[UIImage imageNamed:@"2d"] forState:UIControlStateNormal];
            if(m_selected_index==1)
                [m_choices[1] setImage:[UIImage imageNamed:@"2b_s"] forState:UIControlStateNormal];
            else
                [m_choices[1] setImage:[UIImage imageNamed:@"2b"] forState:UIControlStateNormal];
            if(m_selected_index==2)
                [m_choices[2] setImage:[UIImage imageNamed:@"2c_s"] forState:UIControlStateNormal];
            else
                [m_choices[2] setImage:[UIImage imageNamed:@"2c"] forState:UIControlStateNormal];
            if([self.delegate getParam:ID_TREETYPE]==0)
            {
                if(m_selected_index==3)
                    [m_choices[3] setImage:[UIImage imageNamed:@"2a_s"] forState:UIControlStateNormal];
                else
                    [m_choices[3] setImage:[UIImage imageNamed:@"2a"] forState:UIControlStateNormal];
            }
            break;
            
        case ID_APEXTYPE:
            [self createChoices:4];
            if(m_selected_index==0)
                [m_choices[0] setImage:[UIImage imageNamed:@"16a_s"] forState:UIControlStateNormal];
            else
                [m_choices[0] setImage:[UIImage imageNamed:@"16a"] forState:UIControlStateNormal];
            if(m_selected_index==1)
                [m_choices[1] setImage:[UIImage imageNamed:@"16b_s"] forState:UIControlStateNormal];
            else
                [m_choices[1] setImage:[UIImage imageNamed:@"16b"] forState:UIControlStateNormal];
            if(m_selected_index==2)
                [m_choices[2] setImage:[UIImage imageNamed:@"16c_s"] forState:UIControlStateNormal];
            else
                [m_choices[2] setImage:[UIImage imageNamed:@"16c"] forState:UIControlStateNormal];
            if(m_selected_index==3)
                [m_choices[3] setImage:[UIImage imageNamed:@"16d_s"] forState:UIControlStateNormal];
            else
                [m_choices[3] setImage:[UIImage imageNamed:@"16d"] forState:UIControlStateNormal];
            break;
            
        case ID_ANIMENABLE:
            [self createChoices:2];
            if(m_selected_index==0)
                [m_choices[0] setImage:[UIImage imageNamed:@"23b_s"] forState:UIControlStateNormal];
            else
                [m_choices[0] setImage:[UIImage imageNamed:@"23b"] forState:UIControlStateNormal];
            if(m_selected_index==1)
                [m_choices[1] setImage:[UIImage imageNamed:@"23a_s"] forState:UIControlStateNormal];
            else
                [m_choices[1] setImage:[UIImage imageNamed:@"23a"] forState:UIControlStateNormal];
            break;
            
        case ID_TREETYPE:
            [self createChoices:2];
            if(m_selected_index==0)
                [m_choices[0] setImage:[UIImage imageNamed:@"1a_s"] forState:UIControlStateNormal];
            else
                [m_choices[0] setImage:[UIImage imageNamed:@"1a"] forState:UIControlStateNormal];
            if(m_selected_index==1)
                [m_choices[1] setImage:[UIImage imageNamed:@"1b_s"] forState:UIControlStateNormal];
            else
                [m_choices[1] setImage:[UIImage imageNamed:@"1b"] forState:UIControlStateNormal];
            break;
            
        default:
            [self createChoices:0];
            break;
    }
    
    [self setNeedsLayout];
}

- (void)buttonPress:(UIButton *)sender
{
    [self.delegate setParam:self.target value:sender.tag redraw:YES sender:self];
    [self update];
}

- (void)dealloc
{
    [_label release];
    [_button release];
    [m_choices[0] release];
    [m_choices[1] release];
    [m_choices[2] release];
    [m_choices[3] release];
    
    [super dealloc];
}
@end
