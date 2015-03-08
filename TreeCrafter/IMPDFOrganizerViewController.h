//
//  IMPDFOrganizerViewController.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/13/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "fractaltrees.h"

@protocol IMPDFOrganizerViewControllerDelegate
- (void)pdfOrganizerVCDidFinishWithFile:(NSString *)path;
@end

@interface IMPDFOrganizerViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *filenames;
@property (nonatomic, retain) NSMutableArray *filesizes;

@property (nonatomic, assign) id<IMPDFOrganizerViewControllerDelegate> delegate;

- (id)init;

@end
