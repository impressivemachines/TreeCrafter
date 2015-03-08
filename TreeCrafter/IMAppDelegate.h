//
//  IMAppDelegate.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"

@class IMTreeModel;
@class IMTreeRender;
@class IMRootViewController;
@class IMTreeViewController;
//@class IMExternalViewController;

@interface IMAppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL m_useExternalDisplay;
}

@property (retain, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL keepMenuPosition;

@property (retain, nonatomic) IMRootViewController *rootViewController;

@property (retain, nonatomic) IMTreeModel *tree;
@property (assign, nonatomic) BOOL treeSaved;

@property (retain, nonatomic) IMTreeRender *render;

@property (retain, nonatomic) NSString *pdffilepath;

- (void)setUseExternalDisplay:(BOOL)ed;
- (BOOL)useExternalDisplay;

- (NSMutableArray *)loadUserTrees;
- (void)saveUserTrees:(NSArray *)treeset;
- (void)addCurrentTreeToUserTrees:(NSMutableArray *)treeset;
- (void)deleteUserTreeAtIndex:(int)index userTrees:(NSMutableArray *)treeset;
- (UIImage *)loadUserTreeThumbnailForTreeAtIndex:(int)index userTrees:(NSMutableArray *)treeset;
- (NSString *)pathForDocuments;

@end
