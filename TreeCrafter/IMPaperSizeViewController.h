//
//  IMPaperSizeViewController.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"

@protocol IMPaperSizeViewControllerDelegate
- (void)paperSizeVCDidFinishWithSize:(CGSize)size label:(NSString *)label;
@end

@interface IMPaperSizeViewController : UITableViewController
{
    int m_selection;
}

- (id)initWithPaperSize:(CGSize)size;

@property (nonatomic, assign) id<IMPaperSizeViewControllerDelegate> delegate;

@end
