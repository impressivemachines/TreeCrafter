//
//  IMVideoDurationViewController.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/11/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"

@protocol IMVideoDurationViewControllerDelegate
- (void)videoDurationVCDidFinishWithDuration:(int)duration durationLabel:(NSString *)label;
@end

@interface IMVideoDurationViewController : UITableViewController
{
    int m_selection;
}

@property (nonatomic, assign) id <IMVideoDurationViewControllerDelegate> delegate;

- (id)initWithDuration:(int)duration;


@end
