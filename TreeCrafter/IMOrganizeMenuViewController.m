//
//  IMOrganizeMenuViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/11/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMOrganizeMenuViewController.h"
#import "IMOrganizeMenuView.h"
#import "IMAppDelegate.h"

@interface IMOrganizeMenuViewController ()

@end

@implementation IMOrganizeMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    self.view = [[[IMOrganizeMenuView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DEBUG_LOG(@"IMOrganizeMenuVC viewDidLoad");
    
    IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.savedtrees = [app loadUserTrees];
    
    DEBUG_LOG(@"saved trees count = %d", [self.savedtrees count]);
    
    IMOrganizeMenuView *mv = (IMOrganizeMenuView *)self.view;
    [mv.saveButton addTarget:self action:@selector(addButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [mv.editButton addTarget:self action:@selector(editButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    mv.tableView.delegate = self;
    mv.tableView.dataSource = self;
    
    UITableView *tv = ((IMOrganizeMenuView *)self.view).tableView;
    [tv setEditing:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    DEBUG_LOG(@"IMOrganizeMenuVC viewWillDisappear");
    UITableView *tv = ((IMOrganizeMenuView *)self.view).tableView;
    [tv setEditing:NO animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    DEBUG_LOG(@"IMOrganizeMenuVC viewDidLayoutSubviews");
    [self.view setNeedsDisplay];
}

- (int)widthForMenu
{
    return 215;
}

- (BOOL)isRightSide
{
    return NO;
}

- (void)update
{
}

// tableview delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.savedtrees count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TREE_ICON_HEIGHT + 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *imageView;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
    if(cell==nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ImageCell"]
                autorelease];
        cell.showsReorderControl = TRUE;
        imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 5, TREE_ICON_WIDTH, TREE_ICON_HEIGHT)] autorelease];
        imageView.tag = 1;
        [cell.contentView addSubview:imageView];
    }
    else
        imageView = (UIImageView *)[cell.contentView viewWithTag:1];
    
    IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    imageView.image = [app loadUserTreeThumbnailForTreeAtIndex:(int)indexPath.row userTrees:self.savedtrees];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
        [app deleteUserTreeAtIndex:(int)indexPath.row userTrees:self.savedtrees];
        app.treeSaved = NO;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self performSelector:@selector(updateEditStatus) withObject:nil afterDelay:0.1];
    }
    //else if (editingStyle == UITableViewCellEditingStyleInsert) {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //}
}

// called after row delete
- (void)updateEditStatus
{
    IMOrganizeMenuView *v = (IMOrganizeMenuView *)self.view;
    
    if([self.savedtrees count]==0) // nothing left
    {
        [v.tableView setEditing:NO animated:YES]; // stop editing
        v.editButton.enabled = NO; // disable edit button
    }
    else if([self.savedtrees count]==MAX_SAVED_TREES-1)
    {
        v.saveButton.enabled = YES; // re-enable the save button for <100 trees saved
    }
    
    [v updateButtons];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.savedtrees count]<2)
        return NO;
    else
        return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSDictionary *p = [[self.savedtrees objectAtIndex:sourceIndexPath.row] retain];
    [self.savedtrees removeObjectAtIndex:sourceIndexPath.row];
    [self.savedtrees insertObject:p atIndex:destinationIndexPath.row];
    [p release];
    
    IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app saveUserTrees:self.savedtrees];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //DEBUG_LOG(@"select %d", indexPath.row);
    [self.delegate setTreeParameters:self.savedtrees[indexPath.row]];
    IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.treeSaved = YES;
    
    IMOrganizeMenuView *v = (IMOrganizeMenuView *)self.view;
    [v updateButtons];
}

- (void)addButtonPress:(id)sender
{
    DEBUG_LOG(@"IMOrganizeMenuVC addButtonPress");
    IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(app.treeSaved==NO)
    {
        [app addCurrentTreeToUserTrees:self.savedtrees];
        app.treeSaved = YES;
        
        IMOrganizeMenuView *v = (IMOrganizeMenuView *)self.view;
        UITableView *tv = v.tableView;
        
        [tv setEditing:NO animated:NO];
        
        if([self.savedtrees count]==MAX_SAVED_TREES)
            v.saveButton.enabled = NO; // disable saving
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [tv beginUpdates];
        [tv insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [tv endUpdates];
        
        [v updateButtons];
    }
}

- (void)editButtonPress:(id)sender
{
    DEBUG_LOG(@"IMOrganizeMenuVC editButtonPress");
    IMOrganizeMenuView *v = (IMOrganizeMenuView *)self.view;
    UITableView *tv = v.tableView;
    
    if(tv.editing || [self.savedtrees count]==0)
    {
        [tv setEditing:NO animated:YES];
    }
    else
    {
        [tv setEditing:YES animated:YES];
    }
    
    [v updateButtons];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view setNeedsDisplay];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMOrganizeMenuVC dealloc");
    
    [_savedtrees release];
    
    [super dealloc];
}
@end
