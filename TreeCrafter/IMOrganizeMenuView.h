//
//  IMOrganizeMenuView.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/11/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"

@interface IMOrganizeMenuView : UIView

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIButton *editButton;
@property (nonatomic, retain) UIButton *saveButton;

- (void)updateButtons;

@end
