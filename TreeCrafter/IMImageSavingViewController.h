//
//  IMImageSavingViewController.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/Social.h>
#import "fractaltrees.h"
#import "IMTreeModel.h"

@protocol IMImageSavingViewControllerDelegate
- (void)imageSaveDidSucceed:(BOOL)success;
@end

@interface IMImageSavingViewController : UIViewController <IMTreeModelDelegate, MFMailComposeViewControllerDelegate>

@property (assign, nonatomic) id <IMImageSavingViewControllerDelegate> delegate;

@property (assign, atomic) BOOL userCancel;
@property (assign, atomic) float progress;

@property (assign, nonatomic) int shareMode;
@property (assign, nonatomic) float drawscale;
@property (assign, nonatomic) CGPoint draworigin;
@property (retain, nonatomic) NSString *headertext;
@property (retain, nonatomic) NSString *footertext;
@property (retain, nonatomic) UIImage *backgroundimage;
@property (assign, nonatomic) CGSize drawsize;
@property (retain, nonatomic) UIColor *textcolor;
@property (assign, nonatomic) int quality;
@property (retain, nonatomic) UIImage *image;
@property (assign, nonatomic) BOOL addLogo;

@end
