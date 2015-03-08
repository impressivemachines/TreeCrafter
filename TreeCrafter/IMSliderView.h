//
//  IMSliderView.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/13/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMProtocol.h"

@interface IMSliderView : UIView <IMControlProtocol>

@property (nonatomic, assign) id <IMTreeParamProtocol> delegate;

@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, assign) int target;

- (void)update;
@end
