//
//  IMSelectorView.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/14/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMProtocol.h"

@interface IMSelectorView : UIView <IMControlProtocol>
{
    UIButton *m_choices[4];
    int m_selected_index;
}

@property (nonatomic, assign) id <IMTreeParamProtocol> delegate;

@property (nonatomic, retain) UIButton *button;
@property (nonatomic, assign) int target;
@property (nonatomic, retain) UILabel *label;

- (void)update;
@end
