//
//  IMPDFAdjusterViewController.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/6/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMPaperSizeViewController.h"
#import "IMPDFSavingViewController.h"
#import "IMPDFOrganizerViewController.h"

@protocol IMPDFAdjusterViewControllerDelegate
- (void)pdfAdjusterVCDidSucceed:(BOOL)success;
@end

@interface IMPDFAdjusterViewController : UIViewController <UIPopoverControllerDelegate, IMPaperSizeViewControllerDelegate, IMPDFSavingViewControllerDelegate, UIDocumentInteractionControllerDelegate, IMPDFOrganizerViewControllerDelegate>
{
    CGSize m_currentPaperSize;
    float m_linewidth;
    BOOL m_highdetail;
}

@property (assign, nonatomic) id <IMPDFAdjusterViewControllerDelegate> delegate;

@property (nonatomic, retain) UIPopoverController *paperSizePopover;
@property (nonatomic, retain) UIPopoverController *organizerPopover;

@property (nonatomic, retain) IMPDFSavingViewController *savingViewController;
@property (retain, nonatomic) UIDocumentInteractionController *dicController;

@end
