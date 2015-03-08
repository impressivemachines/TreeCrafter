//
//  IMPDFAdjusterView.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/6/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMRoundedButton.h"
#import "IMImageAdjusterTreeView.h"

@interface IMPDFAdjusterView : UIView
{
    int m_orientation;
    float m_paperSizeAspect;
    BOOL m_validLayout;
    NSString *m_paperSizeLabel;
}

@property (nonatomic, retain) IMImageAdjusterTreeView *treeview;
@property (nonatomic, retain) UIView *topview;
@property (nonatomic, retain) UIView *bottomview;
@property (nonatomic, retain) UISegmentedControl *orientationcontrol;
@property (nonatomic, retain) UISegmentedControl *detailcontrol;
@property (nonatomic, retain) UISwitch *backgroundSwitch;
@property (nonatomic, retain) UILabel *backgroundLabel;
@property (nonatomic, retain) IMRoundedButton *paperSizeButton;
@property (nonatomic, retain) UILabel *lineWidthLabel;
@property (nonatomic, retain) UISlider *lineWidthSlider;
@property (nonatomic, retain) UILabel *moveandscalelabel;

- (int)orientation;
- (void)setOrientation:(int)orientation;
- (void)setPaperSizeLabel:(NSString *)label;
- (void)setPaperSizeAspect:(float)aspect;

@end
