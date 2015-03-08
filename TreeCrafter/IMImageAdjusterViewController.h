//
//  IMImageAdjusterViewController.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/2/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMModalColorSelectorViewController.h"
#import "IMImageSavingViewController.h"

@protocol IMImageAdjusterViewControllerDelegate
- (void)imageAdjusterVCDidSucceed:(BOOL)success;
@end

@interface IMImageAdjusterViewController : UIViewController <UIPopoverControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, IMModalColorSelectorViewControllerDelegate, IMImageSavingViewControllerDelegate>
{
    int m_detail;
}

@property (assign, nonatomic) id <IMImageAdjusterViewControllerDelegate> delegate;

@property (nonatomic, retain) UIPopoverController *imagePopover;
@property (nonatomic, retain) UIPopoverController *colorPopover;
@property (nonatomic, retain) IMImageSavingViewController *savingViewController;

@end
