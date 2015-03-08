//
//  IMAnimationMenuViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/11/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMAnimationMenuViewController.h"
#import "IMAnimationMenuView.h"

#import <QuartzCore/QuartzCore.h>

@interface IMAnimationMenuViewController ()

@end

@implementation IMAnimationMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.menuDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:ID_ANIMENABLE], @"id_0_0_1",
                                    NSLS_ON_OFF, @"t_0_0_1",

                                    [NSNumber numberWithInt:ID_ANIMWINDDEPTH], @"id_0_1_1",
                                    NSLS_DEPTH, @"t_0_1_1",
                                    @"24", @"i_0_1_1",
                                    [NSNumber numberWithInt:ID_ANIMWINDRATE], @"id_0_1_2",
                                    NSLS_RATE, @"t_0_1_2",
                                    @"25", @"i_0_1_2",

                                    [NSNumber numberWithInt:ID_ANIMSPREAD_D], @"id_0_2_1",
                                    NSLS_SPREAD, @"t_0_2_1",
                                    @"3", @"i_0_2_1",
                                    [NSNumber numberWithInt:ID_ANIMBALANCE_D], @"id_0_2_2",
                                    NSLS_BALANCE, @"t_0_2_2",
                                    @"4", @"i_0_2_2",
                                    [NSNumber numberWithInt:ID_ANIMBEND_D], @"id_0_2_3",
                                    NSLS_BEND, @"t_0_2_3",
                                    @"5", @"i_0_2_3",
                                    [NSNumber numberWithInt:ID_ANIMLENGTHRATIO_D], @"id_0_2_4",
                                    NSLS_GROWTH, @"t_0_2_4",
                                    @"9", @"i_0_2_4",
                                    [NSNumber numberWithInt:ID_ANIMLENGTHBALANCE_D], @"id_0_2_5",
                                    NSLS_SYMMETRY, @"t_0_2_5",
                                    @"10", @"i_0_2_5",
                                    [NSNumber numberWithInt:ID_ANIMASPECT_D], @"id_0_2_6",
                                    NSLS_ASPECT, @"t_0_2_6",
                                    @"13", @"i_0_2_6",

                                    [NSNumber numberWithInt:ID_ANIMENABLE], @"id_1_0_1",
                                    NSLS_ON_OFF, @"t_1_0_1",

                                    [NSNumber numberWithInt:ID_ANIMWINDDEPTH], @"id_1_1_1",
                                    NSLS_DEPTH, @"t_1_1_1",
                                    @"24", @"i_1_1_1",
                                    [NSNumber numberWithInt:ID_ANIMWINDRATE], @"id_1_1_2",
                                    NSLS_RATE, @"t_1_1_2",
                                    @"25", @"i_1_1_2",

                                    [NSNumber numberWithInt:ID_ANIMSPREAD_D], @"id_1_2_1",
                                    NSLS_SPREAD, @"t_1_2_1",
                                    @"3", @"i_1_2_1",
                                    [NSNumber numberWithInt:ID_ANIMBEND_D], @"id_1_2_2",
                                    NSLS_BEND, @"t_1_2_2",
                                    @"5", @"i_1_2_2",
                                    [NSNumber numberWithInt:ID_ANIMSPIN_D], @"id_1_2_3",
                                    NSLS_SPIN, @"t_1_2_3",
                                    @"6", @"i_1_2_3",
                                    [NSNumber numberWithInt:ID_ANIMTWIST_D], @"id_1_2_4",
                                    NSLS_TWIST, @"t_1_2_4",
                                    @"7", @"i_1_2_4",
                                    [NSNumber numberWithInt:ID_ANIMLENGTHRATIO_D], @"id_1_2_5",
                                    NSLS_GROWTH, @"t_1_2_5",
                                    @"9", @"i_1_2_5",
                                    [NSNumber numberWithInt:ID_ANIMGEODELAY_D], @"id_1_2_6",
                                    NSLS_DELAY, @"t_1_2_6",
                                    @"11", @"i_1_2_6",
                                    [NSNumber numberWithInt:ID_ANIMGEORATIO_D], @"id_1_2_7",
                                    NSLS_GEORATIO, @"t_1_2_7",
                                    @"12", @"i_1_2_7",
                                    [NSNumber numberWithInt:ID_ANIMASPECT_D], @"id_1_2_8",
                                    NSLS_ASPECT, @"t_1_2_8",
                                    @"13", @"i_1_2_8",
                                    nil];
    }
    return self;
}

- (void)loadView
{
    self.view = [[[IMAnimationMenuView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	IMAnimationMenuView *mv = (IMAnimationMenuView *)self.view;
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
    
    DEBUG_LOG(@"IMAnimationMenuVC viewDidLayoutSubviews");
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int tree_type = (int)[self.delegate getParam:ID_TREETYPE];
    
    switch(section)
    {
        case 0:
            return 2;
        case 1:
            return 3;
        case 2:
        default:
            if(tree_type==0)
                return 7;
            else
                return 9;
    }
}

- (CGFloat)heightForLabelAtIndexPath:(NSIndexPath *)indexPath
{
    int tree_type = (int)[self.delegate getParam:ID_TREETYPE];
    id myid = [self.menuDictionary objectForKey:[NSString stringWithFormat:@"t_%d_%ld_%ld", tree_type, (long)indexPath.section, (long)indexPath.row]];
    if(myid!=nil)
    {
        NSString *s = (NSString *)myid;
        if([s rangeOfString:@"\n"].location != NSNotFound)
            return 40;
    }
    
    return 20;
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
        return 60 + [self heightForLabelAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    float left = 6;
    int tree_type = (int)[self.delegate getParam:ID_TREETYPE];
    
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
        
        label.frame = CGRectMake(left, 20, 100, 20);
        
        if(indexPath.section==0)
        {
            label.text = NSLS_ANIMATION;
            label.frame = CGRectMake(left, 0, 100, 20);
        }
        else if(indexPath.section==1)
            label.text = NSLS_WIND;
        else if(indexPath.section==2)
            label.text = NSLS_TARGETS;
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
            
            label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
            label.tag = 2;
            label.font = [UIFont systemFontOfSize:14];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = MENU_BG_COLOR;
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            [cell.contentView addSubview:label];
        }
        else
        {
            button = (UIImageView *)[cell.contentView viewWithTag:1];
            label = (UILabel *)[cell.contentView viewWithTag:2];
        }
        
        label.frame = CGRectMake(left, 55, 100, [self heightForLabelAtIndexPath:indexPath]);
        
        //button.backgroundColor = MENU_LIGHT_COLOR;
        button.backgroundColor = [UIColor clearColor];
        button.image = nil;
        
        id myid = [self.menuDictionary objectForKey:[NSString stringWithFormat:@"id_%d_%ld_%ld", tree_type, (long)indexPath.section, (long)indexPath.row]];
        if(myid!=nil)
        {
            int control = [myid intValue];
            
            NSString *imagename = (NSString *)[self.menuDictionary objectForKey:[NSString stringWithFormat:@"i_%d_%ld_%ld", tree_type, (long)indexPath.section, (long)indexPath.row]];

            if(control==[self.delegate currentControl])
            {
                if(imagename)
                {
                    button.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_s", imagename]];
                }
                else if(control==ID_ANIMENABLE)
                {
                    if([self.delegate getParam:ID_ANIMENABLE]==0)
                        button.image = [UIImage imageNamed:@"23b_s"];
                    else
                        button.image = [UIImage imageNamed:@"23a_s"];
                }
                else
                    button.backgroundColor = [UIColor colorWithRed:0.9 green:0.3 blue:0.5  alpha:1];
            }
            else if(imagename)
            {
                button.image = [UIImage imageNamed:imagename];
            }
            else if(control==ID_ANIMENABLE)
            {
                if([self.delegate getParam:ID_ANIMENABLE]==0)
                    button.image = [UIImage imageNamed:@"23b"];
                else
                    button.image = [UIImage imageNamed:@"23a"];
            }
            else
                button.backgroundColor = MENU_LIGHT_COLOR;
        }
        myid = [self.menuDictionary objectForKey:[NSString stringWithFormat:@"t_%d_%ld_%ld", tree_type, (long)indexPath.section, (long)indexPath.row]];
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
    int tree_type = (int)[self.delegate getParam:ID_TREETYPE];
    
    id myid = [self.menuDictionary objectForKey:[NSString stringWithFormat:@"id_%d_%ld_%ld", tree_type, (long)indexPath.section, (long)indexPath.row]];
    if(myid!=nil)
        control = [myid intValue];
    
    if(control==ID_ANIMENABLE)
    {
        [self.delegate setParam:ID_ANIMENABLE value:1-[self.delegate getParam:ID_ANIMENABLE] redraw:NO sender:self];
        [tableView reloadData];
        return;
    }
    
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
    [((IMAnimationMenuView *)self.view).tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view setNeedsDisplay];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMAnimationMenuVC dealloc");
    [_menuDictionary release];
    [super dealloc];
}

@end
