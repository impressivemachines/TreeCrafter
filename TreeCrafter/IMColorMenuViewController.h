//
//  IMColorMenuViewController.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/11/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMProtocol.h"

@interface IMColorMenuViewController : UIViewController <IMMenuProtocol, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) id <IMPresentationProtocol, IMTreeParamProtocol> delegate;

@property (nonatomic, retain) NSDictionary *menuDictionary;

@end
