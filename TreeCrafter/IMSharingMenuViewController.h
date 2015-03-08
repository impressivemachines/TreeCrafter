//
//  IMSharingMenuViewController.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/10/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMProtocol.h"

@interface IMSharingMenuViewController : UIViewController <IMMenuProtocol, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) id <IMPresentationProtocol> delegate;
@property (nonatomic, assign) int selectButton;

@end
