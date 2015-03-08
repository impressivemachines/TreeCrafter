//
//  IMImageAdjusterViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/2/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMImageAdjusterViewController.h"
#import "IMImageAdjusterView.h"

@interface IMImageAdjusterViewController ()

@end

@implementation IMImageAdjusterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_detail = 0; // normal detail
    }
    return self;
}

- (void)loadView
{
    self.view = [[[IMImageAdjusterView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewDidLoad
{
    DEBUG_LOG(@"IMImageAdjusterViewController viewDidLoad");
    
    [super viewDidLoad];
	
    [self setTitle:NSLS_SAVE_IMAGE];
    
    UIBarButtonItem *barButton;
    
    barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(buttonDone:)];
    [[self navigationItem] setRightBarButtonItem:barButton];
    [barButton release];
    
    barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(buttonCancel:)];
    [[self navigationItem] setLeftBarButtonItem:barButton];
    [barButton release];
    
    IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
    [iv.orientationcontrol addTarget:self action:@selector(orientationChanged:) forControlEvents:UIControlEventValueChanged];
    [iv.detailcontrol addTarget:self action:@selector(detailChanged:) forControlEvents:UIControlEventValueChanged];
    [iv.addimagebutton addTarget:self action:@selector(addImageButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [iv.removeimagebutton addTarget:self action:@selector(removeImageButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [iv.textcolorbutton addTarget:self action:@selector(textColorButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    iv.orientation = 0;
    
    [iv.orientationcontrol setSelectedSegmentIndex:iv.orientation];
    [iv.detailcontrol setSelectedSegmentIndex:m_detail];
}

- (void)buttonCancel:(id)sender
{
    DEBUG_LOG(@"IMImageAdjusterViewController buttonCancel");

    [self cleanUpOnExit];
    [self.delegate imageAdjusterVCDidSucceed:NO];
}

- (void)buttonDone:(id)sender
{
    DEBUG_LOG(@"IMImageAdjusterViewController buttonDone");
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
    
    self.savingViewController = [[[IMImageSavingViewController alloc] init] autorelease];
    
    self.savingViewController.view.frame = self.view.bounds;
    self.savingViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.savingViewController.delegate = self;
    
    IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
    [iv.treeview destroyResources]; // this just removes the open gl buffer resources
    
    self.savingViewController.shareMode = SHAREMODE_CAMERAROLL;
    self.savingViewController.headertext = iv.treeview.headerText;
    self.savingViewController.footertext = iv.treeview.footerText;
    self.savingViewController.backgroundimage = iv.treeview.backgroundImage;
    self.savingViewController.textcolor = iv.treeview.textColor;
    self.savingViewController.addLogo = NO;
    self.savingViewController.quality = (m_detail ? QUALITY_HIGHDETAIL : QUALITY_NORMAL);
    
    float save_width, save_height;
    if(m_detail)
    {
        save_width = IMAGE_SAVE_WIDTH_HIGHDETAIL;
        save_height = IMAGE_SAVE_HEIGHT_HIGHDETAIL;
    }
    else
    {
        save_width = IMAGE_SAVE_WIDTH;
        save_height = IMAGE_SAVE_HEIGHT;
    }
    
    if(iv.orientation==1)
        self.savingViewController.drawsize = CGSizeMake(save_width, save_height);
    else
        self.savingViewController.drawsize = CGSizeMake(save_height, save_width);

    float scalefacor = self.savingViewController.drawsize.width / iv.treeview.bounds.size.width;
    self.savingViewController.drawscale = iv.treeview.drawScale * scalefacor;
    self.savingViewController.draworigin = CGPointMake(iv.treeview.drawOrigin.x * scalefacor, iv.treeview.drawOrigin.y * scalefacor);
    
    [self addChildViewController:self.savingViewController];
    [self.view addSubview:self.savingViewController.view];
    
    self.savingViewController.view.alpha = 0;
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.savingViewController.view.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [self.savingViewController didMoveToParentViewController:self];
                         self.view.userInteractionEnabled = YES;
                     }];
}

- (void)imageSaveDidSucceed:(BOOL)success
{
    // dismiss image saving VC
    [self.savingViewController willMoveToParentViewController:nil];
    [self.savingViewController.view removeFromSuperview];
    [self.savingViewController removeFromParentViewController];
    self.savingViewController = nil;
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
    
    if(success)
    {
        [self cleanUpOnExit];
        [self.delegate imageAdjusterVCDidSucceed:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
    [iv.treeview destroyResources];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    DEBUG_LOG(@"IMImageAdjusterViewController didRotateFromInterfaceOrientation");
    if(self.imagePopover)
    {
        [self.imagePopover dismissPopoverAnimated:YES];
        self.imagePopover = nil;
        
        IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
        iv.addimagebutton.enabled = YES;
    }
    
    if(self.colorPopover)
    {
        [self.colorPopover dismissPopoverAnimated:YES];
        self.colorPopover = nil;
    }
}

- (void)orientationChanged:(UISegmentedControl *)sender
{
    DEBUG_LOG(@"IMImageAdjusterViewController orientationChanged");
    IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
    [iv.titletext resignFirstResponder];
    [iv.footertext resignFirstResponder];
    
    iv.orientation = (int)[sender selectedSegmentIndex];
}

- (void)detailChanged:(UISegmentedControl *)sender
{
    DEBUG_LOG(@"IMImageAdjusterViewController detailChanged");
    IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
    [iv.titletext resignFirstResponder];
    [iv.footertext resignFirstResponder];
    
    m_detail = (int)[sender selectedSegmentIndex];
}

- (void)addImageButtonPress:(UIButton *)sender
{
    DEBUG_LOG(@"IMImageAdjusterViewController addImageButtonPress");
    IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
    [iv.titletext resignFirstResponder];
    [iv.footertext resignFirstResponder];
    
    if(!self.imagePopover)
    {
        sender.enabled = NO;
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        self.imagePopover = [[[UIPopoverController alloc] initWithContentViewController:picker] autorelease];
        self.imagePopover.delegate = self;
        [picker release];
        [self.imagePopover presentPopoverFromRect:sender.bounds
                                           inView:sender
                         permittedArrowDirections:UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? UIPopoverArrowDirectionUp : UIPopoverArrowDirectionLeft
                                         animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    DEBUG_LOG(@"IMImageAdjusterViewController imagePickerController:didFinishPickingMediaWithInfo");
    IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
    
    // reduce size of background image by two

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    CGSize newSize;
    
    newSize.width = (int)(0.5f * image.size.width);
    newSize.height = (int)(0.5f * image.size.height);
    
    //DEBUG_LOG(@"orientation = %d", image.imageOrientation);
    //DEBUG_LOG(@"new size = %f x %f", newSize.width, newSize.height);
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newSize.width,
                                                newSize.height,
                                                CGImageGetBitsPerComponent(image.CGImage),
                                                0,
                                                CGImageGetColorSpace(image.CGImage),
                                                CGImageGetBitmapInfo(image.CGImage));
    

    CGAffineTransform transform = CGAffineTransformIdentity;
    
    float aspect = newSize.width / newSize.height;
    
    switch (image.imageOrientation)
    {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            transform = CGAffineTransformScale(transform, 1/aspect, aspect);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            transform = CGAffineTransformScale(transform, 1/aspect, aspect);
            break;
            
        default:
            break;
    }
    
    switch (image.imageOrientation)
    {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        default:
            break;
    }
    
    CGContextConcatCTM(bitmap, transform);
    CGContextDrawImage(bitmap, CGRectMake(0, 0, newSize.width, newSize.height), image.CGImage);
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    
    CGContextRelease(bitmap);
    
    iv.treeview.backgroundImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    
    [self.imagePopover dismissPopoverAnimated:YES];
    self.imagePopover = nil;
    
    iv.addimagebutton.enabled = YES;
    
    if(iv.treeview.backgroundImage)
        iv.removeimagebutton.enabled = YES;
    
    //[iv.treeview setNeedsDisplay];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    DEBUG_LOG(@"IMImageAdjusterViewController imagePickerControllerDidCancel");
    
    // never gets called on ipad
    [self.imagePopover dismissPopoverAnimated:YES];
    self.imagePopover = nil;
    
    IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
    iv.addimagebutton.enabled = YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    DEBUG_LOG(@"IMImageAdjusterViewController popoverControllerDidDismissPopover");
    
    if(popoverController==self.imagePopover)
    {
        self.imagePopover = nil;
        
        IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
        iv.addimagebutton.enabled = YES;
    }
    else
    {
        self.colorPopover = nil;
    }
}

- (void)removeImageButtonPress:(UIButton *)sender
{
    DEBUG_LOG(@"IMImageAdjusterViewController removeImageButtonPress");
    IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
    [iv.titletext resignFirstResponder];
    [iv.footertext resignFirstResponder];

    iv.treeview.backgroundImage = nil;
    sender.enabled = NO;
}

- (void)textColorButtonPress:(UIButton *)sender
{
    DEBUG_LOG(@"IMImageAdjusterViewController textColorButtonPress");
    IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
    [iv.titletext resignFirstResponder];
    [iv.footertext resignFirstResponder];

    if(!self.colorPopover)
    {
        IMModalColorSelectorViewController *vc = [[IMModalColorSelectorViewController alloc] initWithTitle:NSLS_TEXT_COLOR];
        vc.delegate = self;
        vc.color = [iv textColor];
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        [vc release];
        
        self.colorPopover = [[[UIPopoverController alloc] initWithContentViewController:nc] autorelease];
        self.colorPopover.delegate = self;
        [nc release];
        
        [self.colorPopover presentPopoverFromRect:sender.bounds
                                           inView:sender
                         permittedArrowDirections:UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? UIPopoverArrowDirectionUp : UIPopoverArrowDirectionLeft
                                         animated:YES];
    }
}

-(void)colorSelectionChanged:(id)sender
{
}

-(void)colorSelectionCancelled:(id)sender
{
}

-(void)colorSelectionFinished:(id)sender
{
    DEBUG_LOG(@"IMImageAdjusterViewController colorSelectionFinished");
    
    IMModalColorSelectorViewController *vc = (IMModalColorSelectorViewController *)sender;
    IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
    iv.textColor = vc.color;
    
    [self.colorPopover dismissPopoverAnimated:YES];
    self.colorPopover = nil;
}

- (void)cleanUpOnExit
{
    IMImageAdjusterView *iv = (IMImageAdjusterView *)self.view;
    [iv.treeview destroyResources];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMImageAdjusterViewController dealloc");
    [_imagePopover release];
    [_colorPopover release];
    [_savingViewController release];
    [super dealloc];
}


@end
