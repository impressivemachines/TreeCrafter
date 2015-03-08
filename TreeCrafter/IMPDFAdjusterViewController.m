//
//  IMPDFAdjusterViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/6/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMPDFAdjusterViewController.h"
#import "IMPDFAdjusterView.h"
#import "IMAppDelegate.h"

@interface IMPDFAdjusterViewController ()

@end

@implementation IMPDFAdjusterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    DEBUG_LOG(@"IMPDFAdjusterViewController init");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        m_linewidth = 1;
        m_currentPaperSize = CGSizeMake(612, 792); // letter
        m_highdetail = NO;
    }
    return self;
}

- (void)loadView
{
    self.view = [[[IMPDFAdjusterView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:NSLS_SAVE_PDF_FILE];
    
    UIBarButtonItem *barButtonCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(buttonCancel:)];
    [[self navigationItem] setLeftBarButtonItem:barButtonCancel];
    [barButtonCancel release];
    
    UIBarButtonItem *barButtonOrganize = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(buttonOrganize:)];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(buttonDone:)];
    UIBarButtonItem *barSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barSpacer.width = 20;
    [[self navigationItem] setRightBarButtonItems:@[barButtonDone, barSpacer, barButtonOrganize]];
    [barButtonOrganize release];
    [barButtonDone release];
    [barSpacer release];
    
    IMPDFAdjusterView *iv = (IMPDFAdjusterView *)self.view;
    
    [iv.orientationcontrol addTarget:self action:@selector(orientationChanged:) forControlEvents:UIControlEventValueChanged];
    
    [iv.detailcontrol addTarget:self action:@selector(detailChanged:) forControlEvents:UIControlEventValueChanged];
    
    [iv.paperSizeButton addTarget:self action:@selector(paperSizeButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [iv setPaperSizeLabel:NSLS_LETTER__];
    [iv setPaperSizeAspect:8.5f/11.0f]; // aspect must be <1
    
    [iv.lineWidthSlider addTarget:self action:@selector(lineWidthSliderChanged:) forControlEvents:UIControlEventValueChanged];
    iv.lineWidthSlider.continuous = YES;
    [iv.lineWidthSlider setValue:0.5f];
    [self lineWidthSliderChanged:iv.lineWidthSlider];
    
    [iv.backgroundSwitch addTarget:self action:@selector(backgroundSwitchChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    DEBUG_LOG(@"IMPDFAdjusterViewController didRotateFromInterfaceOrientation");
    if(self.paperSizePopover)
    {
        [self.paperSizePopover dismissPopoverAnimated:YES];
        self.paperSizePopover = nil;
        
        IMPDFAdjusterView *iv = (IMPDFAdjusterView *)self.view;
        iv.paperSizeButton.enabled = YES;
    }
}

- (void)orientationChanged:(UISegmentedControl *)sender
{
    IMPDFAdjusterView *iv = (IMPDFAdjusterView *)self.view;
    iv.orientation = (int)[sender selectedSegmentIndex];
}

- (void)detailChanged:(UISegmentedControl *)sender
{
    if([sender selectedSegmentIndex]==0)
        m_highdetail = NO;
    else
        m_highdetail = YES;
}

- (void)lineWidthSliderChanged:(UISlider *)sender
{
    m_linewidth = 0.1f*expf(4.60517f*sender.value);
    
    IMPDFAdjusterView *iv = (IMPDFAdjusterView *)self.view;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setPositiveFormat:@"0.00"];
    iv.lineWidthLabel.text = [NSString stringWithFormat:NSLS_LINE_WEIGHT__2, [numberFormatter stringFromNumber:[NSNumber numberWithFloat:m_linewidth]]];
    [numberFormatter release];

    iv.treeview.lineWidth = 0.01f * (int)(m_linewidth * 100 + 0.5f);
}

- (void)backgroundSwitchChanged:(UISwitch *)sender
{
    IMPDFAdjusterView *iv = (IMPDFAdjusterView *)self.view;
    iv.treeview.hasBackground = sender.isOn;
}

- (void)paperSizeButtonPress:(UIButton *)sender
{
    DEBUG_LOG(@"IMPDFAdjusterViewController paperSizeButtonPress");
    if(!self.paperSizePopover)
    {
        IMPDFAdjusterView *iv = (IMPDFAdjusterView *)self.view;
        [iv.treeview destroyResources];
        
        sender.enabled = NO;
        IMPaperSizeViewController *paperVC = [[IMPaperSizeViewController alloc] initWithPaperSize:m_currentPaperSize];
        paperVC.delegate = self;
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:paperVC];
        [paperVC release];
        
        self.paperSizePopover = [[[UIPopoverController alloc] initWithContentViewController:nc] autorelease];
        self.paperSizePopover.delegate = self;
        [nc release];
        
        [self.paperSizePopover presentPopoverFromRect:sender.bounds
                                               inView:sender
                             permittedArrowDirections:UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? UIPopoverArrowDirectionUp : UIPopoverArrowDirectionLeft
                                             animated:YES];
    }
}

- (void)paperSizeVCDidFinishWithSize:(CGSize)size label:(NSString *)label
{
    IMPDFAdjusterView *iv = (IMPDFAdjusterView *)self.view;
    
    m_currentPaperSize = size;
    iv.treeview.drawScale = 0;
    [iv setPaperSizeLabel:label];
    [iv setPaperSizeAspect:size.width/size.height];
    
    [self.paperSizePopover dismissPopoverAnimated:YES];
    self.paperSizePopover = nil;
    
    iv.paperSizeButton.enabled = YES;
}

- (void)buttonOrganize:(UIBarButtonItem *)sender
{
    DEBUG_LOG(@"IMPDFAdjusterViewController buttonOrganize");
    if(!self.organizerPopover)
    {
        //[self disableBarButtons];
        
        IMPDFAdjusterView *iv = (IMPDFAdjusterView *)self.view;
        [iv.treeview destroyResources];
        
        IMPDFOrganizerViewController *organizerVC = [[IMPDFOrganizerViewController alloc] init];
        organizerVC.delegate = self;
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:organizerVC];
        [organizerVC release];
        
        self.organizerPopover = [[[UIPopoverController alloc] initWithContentViewController:nc] autorelease];
        self.organizerPopover.delegate = self;
        [nc release];
        
        [self.organizerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        [self.organizerPopover dismissPopoverAnimated:YES];
        self.organizerPopover = nil;
    }
}

- (void)pdfOrganizerVCDidFinishWithFile:(NSString *)path
{
    DEBUG_LOG(@"IMPDFAdjusterViewController pdfOrganizerVCDidFinishWithFile");
    
    [self.organizerPopover dismissPopoverAnimated:path==nil];
    self.organizerPopover = nil;

    //[self enableBarButtons];
    
    if(path)
    {
        IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSURL *pdfurl = [NSURL fileURLWithPath:[[app pathForDocuments] stringByAppendingPathComponent:path]];
        
        self.dicController = [UIDocumentInteractionController interactionControllerWithURL:pdfurl];
        if(self.dicController)
        {
            [self disableBarButtons];
            self.dicController.delegate = self;
            [self.dicController presentPreviewAnimated:YES];
        }
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    DEBUG_LOG(@"IMPDFAdjusterViewController popoverControllerDidDismissPopover");
    
    if(popoverController==self.paperSizePopover)
    {
        self.paperSizePopover = nil;
        
        IMPDFAdjusterView *iv = (IMPDFAdjusterView *)self.view;
        iv.paperSizeButton.enabled = YES;
    }
    else if(popoverController==self.organizerPopover)
    {
        self.organizerPopover = nil;
        
        //[self enableBarButtons];
    }
}

- (void)disableBarButtons
{
    NSArray *buttonItems = [[self navigationItem] rightBarButtonItems];
    [buttonItems[0] setEnabled:NO];
    [buttonItems[2] setEnabled:NO];
    
    [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
}

- (void)enableBarButtons
{
    NSArray *buttonItems = [[self navigationItem] rightBarButtonItems];
    [buttonItems[0] setEnabled:YES];
    [buttonItems[2] setEnabled:YES];
    
    [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
}

- (void)buttonDone:(id)sender
{
    DEBUG_LOG(@"IMPDFAdjusterViewController buttonDone");
    
    if(self.organizerPopover)
    {
        [self.organizerPopover dismissPopoverAnimated:NO];
        self.organizerPopover = nil;
    }
    
    [self disableBarButtons];
    
    IMPDFAdjusterView *iv = (IMPDFAdjusterView *)self.view;
    [iv.treeview destroyResources]; // removes opengl resources to give more mmeory for pdf viewer
    
    self.savingViewController = [[[IMPDFSavingViewController alloc] init] autorelease];
    
    self.savingViewController.view.frame = self.view.bounds;
    self.savingViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.savingViewController.delegate = self;

    if(iv.orientation==0)
        self.savingViewController.paperSize = m_currentPaperSize; // portrait
    else
        self.savingViewController.paperSize = CGSizeMake(m_currentPaperSize.height, m_currentPaperSize.width);
    
    float scalefacor = self.savingViewController.paperSize.width / iv.treeview.bounds.size.width;
    
    self.savingViewController.drawScale = iv.treeview.drawScale * scalefacor;
    self.savingViewController.drawOrigin = CGPointMake(iv.treeview.drawOrigin.x * scalefacor, iv.treeview.drawOrigin.y * scalefacor);
    self.savingViewController.quality = (m_highdetail ? QUALITY_HIGHDETAIL : QUALITY_NORMAL);
    self.savingViewController.hasBackground = iv.treeview.hasBackground;
    self.savingViewController.lineWidth = m_linewidth; // specified relative to normal width
    
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

- (void)buttonCancel:(id)sender
{
    DEBUG_LOG(@"IMPDFAdjusterViewController buttonCancel");
    
    if(self.organizerPopover)
    {
        [self.organizerPopover dismissPopoverAnimated:NO];
        self.organizerPopover = nil;
    }
    
    [self cleanUpOnExit];
    [self.delegate pdfAdjusterVCDidSucceed:NO];
}

- (void)pdfSaveDidSucceed:(BOOL)success
{
    // dismiss pdf saving VC
    [self.savingViewController willMoveToParentViewController:nil];
    [self.savingViewController.view removeFromSuperview];
    [self.savingViewController removeFromParentViewController];
    self.savingViewController = nil;
    
    if(success)
    {
        IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSURL *pdfurl = [NSURL fileURLWithPath:app.pdffilepath];
        
        self.dicController = [UIDocumentInteractionController interactionControllerWithURL:pdfurl];
        if(self.dicController)
        {
            self.dicController.delegate = self;
            [self.dicController presentPreviewAnimated:YES];
        }
        else
        {
            // this is just so we have an out if the dic controller fails
            [self enableBarButtons];
        }
    }
    else
    {
        [self enableBarButtons];
    }
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    DEBUG_LOG(@"end of preview");
    [self enableBarButtons];
    
    //[self cleanUpOnExit];
    //[self.delegate pdfAdjusterVCDidSucceed:YES];
}

- (void)cleanUpOnExit
{
}

- (void)dealloc
{
    DEBUG_LOG(@"IMPDFAdjusterViewController dealloc");
    
    [_paperSizePopover release];
    [_organizerPopover release];
    
    [_savingViewController release];
    [_dicController release];
    
    [super dealloc];
}

@end
