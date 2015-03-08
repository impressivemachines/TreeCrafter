//
//  IMImageSavingViewController.m
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMImageSavingViewController.h"
#import "IMAppDelegate.h"
#import "IMRoundedButton.h"
#import "IMImageSavingView.h"

@interface IMImageSavingViewController ()

@end

@implementation IMImageSavingViewController

- (id)init
{
    DEBUG_LOG(@"IMImageSavingViewController init");
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
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
    
    DEBUG_LOG(@"IMImageSavingViewController viewDidLoad");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DEBUG_LOG(@"IMImageSavingViewController viewWillAppear");

    IMImageSavingView *v = (IMImageSavingView *)self.view;
    
    if(self.shareMode==SHAREMODE_CAMERAROLL)
        v.titleLabel.text = NSLS_SAVING_IMAGE__;
    else
        v.titleLabel.text = NSLS_PREPARING_IMAGE;
    
    [v.cancelButton addTarget:self action:@selector(cancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DEBUG_LOG(@"IMImageSavingViewController viewDidAppear");
    self.progress = 0;

    dispatch_queue_t myQueue = dispatch_queue_create("com.impressivemachines.save_operation", 0);
    
    dispatch_async(myQueue, ^{
        IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        self.userCancel = NO;
        
        app.tree.delegate = self;
        
        int error;
        
        self.image = [app.tree drawImageWithSize:self.drawsize ox:self.draworigin.x oy:self.draworigin.y scale:self.drawscale quality:self.quality adaptForDisplay:NO background:self.backgroundimage header:self.headertext footer:self.footertext textcolor:self.textcolor logo:self.addLogo error:&error];
        
        app.tree.delegate = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // the animation here is to dismiss this view before a potential fail alert
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.view.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 if(self.image)
                                     [self shareImage];
                                 else
                                 {
                                     if(error!=IME_CANCEL)
                                         [self failAlert];
                                     [self.delegate imageSaveDidSucceed:NO];
                                 }
                             }];
        });
    });
    
    dispatch_release(myQueue);
}

- (void)failAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_UNABLE_TO_PROCESS__
                                                    message:NSLS_EITHER_CAMERA__2
                                                   delegate:nil
                                          cancelButtonTitle:NSLS_OK
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)shareImage
{
    DEBUG_LOG(@"IMImageSavingViewController shareImage");
    if(self.shareMode==SHAREMODE_CAMERAROLL)
    {
        //NSData* imageData =  UIImagePNGRepresentation(self.image); // get png representation
        //UIImage* pngImage = [UIImage imageWithData:imageData];
        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
    else if(self.shareMode==SHAREMODE_EMAIL)
    {
        if(![MFMailComposeViewController canSendMail])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_MAIL_UNAVAILABLE
                                                            message:NSLS_THIS_DEVICE_MAY__
                                                           delegate:nil
                                                  cancelButtonTitle:NSLS_OK
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            [self.delegate imageSaveDidSucceed:NO];
        }
        else
        {
            NSData *imageData = UIImagePNGRepresentation(self.image);//UIImageJPEGRepresentation(self.image, 0.9f);
            if(imageData==nil)
            {
                [self failAlert];
                [self.delegate imageSaveDidSucceed:NO];
            }
            else
            {            
                MFMailComposeViewController *mvc = [[MFMailComposeViewController alloc] init];
                mvc.mailComposeDelegate = self;
        
                [mvc setSubject:NSLS_CHECK_OUT_MY__];
                [mvc setMessageBody:[NSString stringWithFormat:@"<br><br><a href=\"http://treecrafter.com\">%@</a>", NSLS_CREATED_USING__] isHTML:YES];
                [mvc addAttachmentData:imageData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"%@.jpg", NSLS_TREE]];
                
                [self presentViewController:mvc animated:YES completion:^{}];
                [mvc release];
            }
        }
    }
    else if(self.shareMode==SHAREMODE_TWITTER || self.shareMode==SHAREMODE_FACEBOOK || self.shareMode==SHAREMODE_WEIBO)
    {
        NSString *serviceType;
        NSString *errorTitle;
        NSString *errorMessage;
        
        if(self.shareMode==SHAREMODE_TWITTER)
        {
            serviceType = SLServiceTypeTwitter;
            errorTitle = NSLS_TWITTER__;
            errorMessage = NSLS_THIS_DEVICE__T;
        }
        else if(self.shareMode==SHAREMODE_FACEBOOK)
        {
            serviceType = SLServiceTypeFacebook;
            errorTitle = NSLS_FACEBOOK__;
            errorMessage = NSLS_THIS_DEVICE__F;
        }
        else
        {
            serviceType = SLServiceTypeSinaWeibo;
            errorTitle = NSLS_SINA_WEIBO__;
            errorMessage = NSLS_THIS_DEVICE__S;
        }
        
        if(![SLComposeViewController isAvailableForServiceType:serviceType])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:NSLS_OK
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            [self.delegate imageSaveDidSucceed:NO];
        }
        else
        {
            SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:serviceType];
            if(vc==nil)
            {
                [self.delegate imageSaveDidSucceed:NO];
            }
            else
            {
                NSData* imageData =  UIImagePNGRepresentation(self.image); // get png representation
                UIImage* pngImage = [UIImage imageWithData:imageData];
                [vc addImage:pngImage];
                vc.completionHandler = ^(SLComposeViewControllerResult result) {
                    if(self.presentedViewController)
                    {
                        DEBUG_LOG(@"dismissing modal vc");
                        [self dismissViewControllerAnimated:YES completion:^{
                            [self.delegate imageSaveDidSucceed:YES];
                        }];
                    }
                    else
                    {
                        [self.delegate imageSaveDidSucceed:YES];
                    }
                };
                [self presentViewController:vc animated:YES completion: ^{}];
            }
        }
    }
    else
    {
        [self.delegate imageSaveDidSucceed:YES];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate imageSaveDidSucceed:YES]; // we dont care if the user cancelled
    }];
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

- (void)cancelButtonPress:(UIButton *)sender
{
    DEBUG_LOG(@"IMImageSavingViewController cancelButtonPress");
    self.userCancel = YES;
}

- (void)                   image: (UIImage *)image
        didFinishSavingWithError: (NSError *) error
                     contextInfo: (void *) contextInfo
{
    DEBUG_LOG(@"IMImageSavingViewController image:didFinishSavingWithError");
    if(error==nil)
        [self.delegate imageSaveDidSucceed:YES];
    else
    {
        [self failAlert];
        [self.delegate imageSaveDidSucceed:NO];
    }
} 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    DEBUG_LOG(@"IMImageSavingViewController didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUG_LOG(@"IMImageSavingViewController dealloc");
    
    [_headertext release];
    [_footertext release];
    [_backgroundimage release];
    [_textcolor release];
    [_image release];
    
    [super dealloc];
}

@end
