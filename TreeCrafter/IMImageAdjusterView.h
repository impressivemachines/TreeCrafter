//
//  IMImageAdjusterView.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/2/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMImageAdjusterTreeView.h"
#import "IMRoundedButton.h"
#import "IMImageAdjusterTreeView.h"

@interface IMImageAdjusterView : UIView <UITextFieldDelegate>
{
    int m_orientation;
    UIColor *m_textColor;
}

@property (nonatomic, retain) IMImageAdjusterTreeView *treeview;
@property (nonatomic, retain) UIView *topview;
@property (nonatomic, retain) UIView *bottomview;
@property (nonatomic, retain) UISegmentedControl *orientationcontrol;
@property (nonatomic, retain) UISegmentedControl *detailcontrol;
@property (nonatomic, retain) UITextField *titletext;
@property (nonatomic, retain) UITextField *footertext;
@property (nonatomic, retain) UILabel *imagelabel;
@property (nonatomic, retain) UILabel *textcolorlabel;
@property (nonatomic, retain) IMRoundedButton *addimagebutton;
@property (nonatomic, retain) IMRoundedButton *removeimagebutton;
@property (nonatomic, retain) IMRoundedButton *textcolorbutton;
@property (nonatomic, retain) UILabel *moveandscalelabel;

- (int)orientation;
- (void)setOrientation:(int)orientation;
- (void)setTextColor:(UIColor *)color;
- (UIColor *)textColor;

@end
