//
//  IMVideoAdjusterView.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/10/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMRoundedButton.h"
#import "IMImageAdjusterTreeView.h"

@interface IMVideoAdjusterView : UIView
{
    BOOL m_validLayout;
    NSString *m_durationLabel;
}

@property (nonatomic, retain) UIView *topview;
@property (nonatomic, retain) IMImageAdjusterTreeView *treeView;
@property (nonatomic, retain) IMRoundedButton *stopButton;
@property (nonatomic, retain) IMRoundedButton *playButton;
@property (nonatomic, retain) IMRoundedButton *lengthButton;
@property (nonatomic, retain) UILabel *moveandscalelabel;
@property (nonatomic, retain) UISlider *scrubSlider;

- (void)setDurationLabel:(NSString *)label;


@end
