//
//  IMSettingsMenuViewController.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/23/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMProtocol.h"

@protocol IMSettingsMenuViewControllerDelegate
- (void)settingsMenuDidRequestDismissal;
@end

@interface IMSettingsMenuViewController : UIViewController
{
    int m_index;
    NSArray *m_titleNames;
}

@property (nonatomic, assign) id<IMSettingsMenuViewControllerDelegate> delegate;

@property (nonatomic, retain) UIView *currentView;
@property (nonatomic, retain) UIView *appearingView;

@end
