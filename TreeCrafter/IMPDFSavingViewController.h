//
//  IMPDFSavingViewController.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/7/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMTreeModel.h"

@protocol IMPDFSavingViewControllerDelegate
- (void)pdfSaveDidSucceed:(BOOL)success;
@end

@interface IMPDFSavingViewController : UIViewController <IMTreeModelDelegate>

@property (assign, nonatomic) id <IMPDFSavingViewControllerDelegate> delegate;

@property (assign, atomic) BOOL userCancel;
@property (assign, atomic) float progress;

@property (assign, nonatomic) CGSize paperSize;
@property (assign, nonatomic) float drawScale;
@property (assign, nonatomic) CGPoint drawOrigin;
@property (assign, nonatomic) int quality;
@property (assign, nonatomic) BOOL hasBackground;
@property (assign, nonatomic) float lineWidth;

@end
