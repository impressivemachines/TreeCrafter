//
//  IMSimpleColorSelectorViewController.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"

@protocol IMModalColorSelectorViewControllerDelegate
-(void)colorSelectionFinished:(id)sender;
-(void)colorSelectionCancelled:(id)sender;
-(void)colorSelectionChanged:(id)sender;
@end

@interface IMModalColorSelectorViewController : UITableViewController
{
    UIColor *m_color;
}

- (id)initWithTitle:(NSString *)title;

@property (assign, nonatomic) id <IMModalColorSelectorViewControllerDelegate> delegate;

- (void)setColor:(UIColor *)color;
- (UIColor *)color;

@end
