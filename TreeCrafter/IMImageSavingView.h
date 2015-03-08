//
//  IMImageSavingView.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/30/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMRoundedButton.h"

@interface IMImageSavingView : UIView

@property (retain, nonatomic) UIProgressView *progressBar;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) IMRoundedButton *cancelButton;

@end
