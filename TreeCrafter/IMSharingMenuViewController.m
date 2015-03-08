//
//  IMSharingMenuViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/10/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMSharingMenuViewController.h"
#import "IMSharingMenuView.h"

#import <QuartzCore/QuartzCore.h>

@interface IMSharingMenuViewController ()

@end

@implementation IMSharingMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.selectButton = -1;
    }
    return self;
}

- (void)loadView
{
    self.view = [[[IMSharingMenuView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IMSharingMenuView *mv = (IMSharingMenuView *)self.view;
    mv.tableView.delegate = self;
    mv.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    DEBUG_LOG(@"IMSharingMenuVC viewDidLayoutSubviews");
    [self.view setNeedsDisplay];
}

- (int)widthForMenu
{
    return 110;
}

- (BOOL)isRightSide
{
    return NO;
}

// tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72+20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    UIImageView *button;
    UIView *overlay;
    
    float left = 10;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    if(cell==nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MenuCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        button = [[[UIImageView alloc] initWithFrame:CGRectMake(left, 0, 72, 72)] autorelease];
        button.tag = 1;
        [cell.contentView addSubview:button];
        
        overlay = [[[UIView alloc] initWithFrame:CGRectMake(left, 0, 72, 72)] autorelease];
        
        overlay.layer.cornerRadius = 12;
        overlay.tag = 2;
        [cell.contentView addSubview:overlay];
    }
    else
    {
        button = (UIImageView *)[cell.contentView viewWithTag:1];
        overlay = (UIView *)[cell.contentView viewWithTag:2];
    }
    
    if(self.selectButton==indexPath.row)
       overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    else
        overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    
    switch(indexPath.row)
    {
        case 0:
            button.image = [UIImage imageNamed:@"mailicon"];
            break;
        case 1:
            button.image = [UIImage imageNamed:@"twittericon"];
            break;
        case 2:
            button.image = [UIImage imageNamed:@"facebookicon"];
            break;
        case 3:
            button.image = [UIImage imageNamed:@"weiboicon"];
            break;
        case 4:
            button.image = [UIImage imageNamed:@"saveimage"];
            break;
        case 5:
            button.image = [UIImage imageNamed:@"savepdf"];
            break;
        case 6:
            button.image = [UIImage imageNamed:@"savevideo"];
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //DEBUG_LOG(@"Select %d %d", indexPath.section, indexPath.row);
    self.selectButton = (int)indexPath.row;
    [tableView reloadData];
    [self performSelector:@selector(clearSelection:) withObject:tableView afterDelay:0.25];
    
    int option;
    switch(indexPath.row)
    {
        case 0:
            option = SHAREMODE_EMAIL;
            break;
        case 1:
            option = SHAREMODE_TWITTER;
            break;
        case 2:
            option = SHAREMODE_FACEBOOK;
            break;
        case 3:
            option = SHAREMODE_WEIBO;
            break;
        case 4:
        default:
            option = SHAREMODE_CAMERAROLL;
            break;
        case 5:
            option = SHAREMODE_PDF;
            break;
        case 6:
            option = SHAREMODE_VIDEO;
    }
    
    [self.delegate performSharingWithOption:option];
}

- (void)clearSelection:(UITableView *)tableView
{
    self.selectButton = -1;
    [tableView reloadData];
}

- (void)update
{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view setNeedsDisplay];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMSharingMenuVC dealloc");
    [super dealloc];
}

@end
