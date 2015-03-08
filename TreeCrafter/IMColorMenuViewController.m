//
//  IMColorMenuViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/11/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMColorMenuViewController.h"
#import "IMColorMenuView.h"

#import <QuartzCore/QuartzCore.h>

@interface IMColorMenuViewController ()

@end

@implementation IMColorMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.menuDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:ID_LEAFCOLOR], @"id_0_1",
                                NSLS_LEAF, @"t_0_1",
                                @"27", @"i_0_1",
                                [NSNumber numberWithInt:ID_ROOTCOLOR], @"id_0_2",
                                NSLS_TRUNK, @"t_0_2",
                                @"28", @"i_0_2",
                                [NSNumber numberWithInt:ID_BACKGROUNDCOLOR], @"id_0_3",
                                NSLS_BACKGROUND, @"t_0_3",
                                @"29", @"i_0_3",

                                [NSNumber numberWithInt:ID_COLORSIZE], @"id_1_1",
                                NSLS_SATURATION, @"t_1_1",
                                @"30", @"i_1_1",
                                [NSNumber numberWithInt:ID_COLORTRANSITION], @"id_1_2",
                                NSLS_SHARPNESS, @"t_1_2",
                                @"31", @"i_1_2",
                                nil];
    }
    return self;
}

- (void)loadView
{
    self.view = [[[IMColorMenuView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	IMColorMenuView *mv = (IMColorMenuView *)self.view;
    mv.tableView.delegate = self;
    mv.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    DEBUG_LOG(@"IMColorMenuVC viewDidLayoutSubviews");
    [self.view setNeedsDisplay];
}

- (int)widthForMenu
{
    return 130;
}

- (BOOL)isRightSide
{
    return YES;
}

// tableview delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
        return 4;
    else
        return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        if(indexPath.section==0)
            return 30;
        else
            return 50;
    }
    else
        return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    float left = 6;
    
    if(indexPath.row==0)
    {
        UILabel *label;
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        if(cell==nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HeaderCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
            label.tag = 1;
            label.font = [UIFont systemFontOfSize:14];
            label.textColor = MENU_BG_COLOR;
            label.backgroundColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.layer.cornerRadius = 3;
            [cell.contentView addSubview:label];
        }
        else
        {
            label = (UILabel *)[cell.contentView viewWithTag:1];
        }
        
        if(indexPath.section==0)
        {
            label.frame = CGRectMake(left, 0, 100, 20);
            label.text = NSLS_COLORS;
        }
        else if(indexPath.section==1)
        {
            label.frame = CGRectMake(left, 20, 100, 20);
            label.text = NSLS_GRADIENT;
        }
    }
    else
    {
        UIImageView *button;
        UILabel *label;
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
        if(cell==nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MenuCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            button = [[[UIImageView alloc] initWithFrame:CGRectMake(left+25, 5, 50, 50)] autorelease];
            button.tag = 1;
            //button.layer.cornerRadius = 6;
            [cell.contentView addSubview:button];
            
            label = [[[UILabel alloc] initWithFrame:CGRectMake(left, 55, 100, 20)] autorelease];
            label.tag = 2;
            label.font = [UIFont systemFontOfSize:14];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = MENU_BG_COLOR;
            label.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label];
        }
        else
        {
            button = (UIImageView *)[cell.contentView viewWithTag:1];
            label = (UILabel *)[cell.contentView viewWithTag:2];
        }
        
        //button.backgroundColor = MENU_LIGHT_COLOR;
        button.backgroundColor = [UIColor clearColor];
        button.image = nil;
        
        NSDictionary *dict= self.menuDictionary;
        
        id myid = [dict objectForKey:[NSString stringWithFormat:@"id_%ld_%ld", (long)indexPath.section, (long)indexPath.row]];
        if(myid!=nil)
        {
            int control = [myid intValue];
            
            NSString *imagename = (NSString *)[self.menuDictionary objectForKey:[NSString stringWithFormat:@"i_%ld_%ld", (long)indexPath.section, (long)indexPath.row]];
            
            if(control==[self.delegate currentControl])
            {
                if(imagename)
                {
                    button.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_s", imagename]];
                }
                else
                    button.backgroundColor = [UIColor colorWithRed:0.9 green:0.3 blue:0.5  alpha:1];
            }
            else if(imagename)
            {
                button.image = [UIImage imageNamed:imagename];
            }
            else
                button.backgroundColor = MENU_LIGHT_COLOR;
        }
        myid = [dict objectForKey:[NSString stringWithFormat:@"t_%ld_%ld", (long)indexPath.section, (long)indexPath.row]];
        if(myid!=nil)
            label.text = (NSString *)myid;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DEBUG_LOG(@"Select %d %d", indexPath.section, indexPath.row);
    if(indexPath.row==0)
        return;
    
    int control = ID_NONE;
    
    NSDictionary *dict = self.menuDictionary;
    
    id myid = [dict objectForKey:[NSString stringWithFormat:@"id_%ld_%ld", (long)indexPath.section, (long)indexPath.row]];
    if(myid!=nil)
        control = [myid intValue];
    
    if(control!=ID_NONE)
    {
        CGRect rct = [tableView rectForRowAtIndexPath:indexPath];
        float y = rct.origin.y - tableView.contentOffset.y + rct.size.height/2 + tableView.frame.origin.y;
        [self.delegate showControl:control y:y];
        
        [tableView reloadData];
    }
}

- (void)update
{
    [((IMColorMenuView *)self.view).tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view setNeedsDisplay];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMColorMenuVC dealloc");
    [_menuDictionary release];
    [super dealloc];
}

@end
