//
//  IMPDFSavingViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/7/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMPDFSavingViewController.h"
#import "IMImageSavingView.h"
#import "IMAppDelegate.h"

@interface IMPDFSavingViewController ()

@end

@implementation IMPDFSavingViewController

- (id)init
{
    DEBUG_LOG(@"IMPDFSavingViewController init");
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    self.view = [[[IMImageSavingView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DEBUG_LOG(@"IMPDFSavingViewController viewWillAppear");
    
    IMImageSavingView *v = (IMImageSavingView *)self.view;
    v.titleLabel.text = NSLS_PREPARING_PDF_FILE;
    
    [v.cancelButton addTarget:self action:@selector(cancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DEBUG_LOG(@"IMPDFSavingViewController viewDidAppear");
    self.progress = 0;
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.impressivemachines.save_operation", 0);
    
    dispatch_async(myQueue, ^{
        IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        self.userCancel = NO;

        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:[NSString stringWithFormat:@"'%@-'yyyy-MM-dd-HH-mm-ss", NSLS_TREE]];
        NSString *filebasename = [dateFormatter stringFromDate:today];
        [dateFormatter release];
        
        NSString *docpath = [app pathForDocuments];
        app.pdffilepath = [docpath stringByAppendingPathComponent:[filebasename stringByAppendingPathExtension:@"pdf"]];
        
        UIGraphicsBeginPDFContextToFile(app.pdffilepath, CGRectMake(0, 0, self.paperSize.width, self.paperSize.height), [NSDictionary dictionaryWithObject:NSLS_CREATED_USING__ forKey:(id)kCGPDFContextCreator]);
        
        UIGraphicsBeginPDFPage();
        
        app.tree.delegate = self;
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        int error = [app.tree drawWithContext:context bounds:CGRectMake(0, 0, self.paperSize.width, self.paperSize.height) ox:self.drawOrigin.x oy:self.drawOrigin.y scale:self.drawScale quality:self.quality vertextarget:0 drawbackground:self.hasBackground linewidth:self.lineWidth animationtime:0];
        
        app.tree.delegate = nil;
        
        UIGraphicsEndPDFContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // the animation here is to dismiss this view before a potential fail alert
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.view.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 if(error==IME_OK)
                                 {
                                     // this assumes that we have disabled display updates
                                     float diagpaper = sqrt(self.paperSize.width * self.paperSize.width + self.paperSize.height * self.paperSize.height);
                                     float diagicon = sqrt(TREE_ICON_WIDTH * TREE_ICON_WIDTH + TREE_ICON_HEIGHT * TREE_ICON_HEIGHT);
                                     float scalechange = diagicon / diagpaper;
                                     float scale = self.drawScale * scalechange;
                                     float ox = 0.5f * TREE_ICON_WIDTH - (0.5f * self.paperSize.width - self.drawOrigin.x) * scalechange;
                                     float oy = 0.5f * TREE_ICON_HEIGHT - (0.5f * self.paperSize.height - self.drawOrigin.y) * scalechange;

                                     UIImage *image = [app.tree drawImageWithSize:CGSizeMake(TREE_ICON_WIDTH, TREE_ICON_HEIGHT) ox:ox oy:oy scale:scale quality:QUALITY_ICON adaptForDisplay:YES background:nil header:nil footer:nil textcolor:nil logo:NO error:NULL];

                                     if(image)
                                     {
                                         NSString *pngpath = [docpath stringByAppendingPathComponent:[filebasename stringByAppendingPathExtension:@"png"]];
                                         [UIImagePNGRepresentation(image) writeToFile:pngpath atomically:YES];
                                     }
                                     
                                     [self.delegate pdfSaveDidSucceed:YES];
                                 }
                                 else
                                 {
                                     if(error!=IME_CANCEL)
                                         [self failAlert];
                                     
                                     if(app.pdffilepath)
                                     {
                                         NSFileManager *manager = [NSFileManager defaultManager];
                                         if([manager fileExistsAtPath:app.pdffilepath])
                                         {
                                             DEBUG_LOG(@"deleting pdf file");
                                             [manager removeItemAtPath:app.pdffilepath error:nil];
                                         }
                                         app.pdffilepath = nil;
                                     }
                                     
                                     [self.delegate pdfSaveDidSucceed:NO];
                                 }
                             }];
        });
    });
    
    dispatch_release(myQueue);
}

- (void)cancelButtonPress:(UIButton *)sender
{
    DEBUG_LOG(@"IMPDFSavingViewController cancelButtonPress");
    self.userCancel = YES;
}

- (void)progressUpdate:(id)sender
{
    IMImageSavingView *v = (IMImageSavingView *)self.view;
    [v.progressBar setProgress:self.progress animated:NO];
}

- (BOOL)callbackForProgress:(float)progress
{
    self.progress = progress;
    
    [self performSelectorOnMainThread:@selector(progressUpdate:) withObject:self waitUntilDone:YES];
    
    return self.userCancel ? NO : YES;
}

- (void)failAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_UNABLE_TO_SAVE_PDF__
                                                    message:NSLS_AN_UNEXPECTED__
                                                   delegate:nil
                                          cancelButtonTitle:NSLS_OK
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUG_LOG(@"IMPDFSavingViewController dealloc");

    [super dealloc];
}

@end
