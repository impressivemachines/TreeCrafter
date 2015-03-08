//
//  IMShapeMenuViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/11/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMShapeMenuViewController.h"
#import "IMShapeMenuView.h"

#import <QuartzCore/QuartzCore.h>

@interface IMShapeMenuViewController ()

@end

@implementation IMShapeMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.menuDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                               // rational tree
                                [NSNumber numberWithInt:ID_TREETYPE], @"id_0_0_1",
                                NSLS_TREE_MODE, @"t_0_0_1",

                                [NSNumber numberWithInt:ID_ANGLEMODE], @"id_0_1_1",
                                NSLS_ANGLE_MODE, @"t_0_1_1",
                                [NSNumber numberWithInt:ID_SPREAD], @"id_0_1_2",
                                NSLS_SPREAD, @"t_0_1_2",
                                @"3", @"i_0_1_2",
                                [NSNumber numberWithInt:ID_BEND], @"id_0_1_3",
                                NSLS_BEND, @"t_0_1_3",
                                @"5", @"i_0_1_3", 
                                [NSNumber numberWithInt:ID_BALANCE], @"id_0_1_4",
                                NSLS_BALANCE, @"t_0_1_4",
                                @"4", @"i_0_1_4",
                                [NSNumber numberWithInt:ID_INTERVALSTART], @"id_0_2_1",
                                NSLS_INTERVALS, @"t_0_2_1",
                                [NSNumber numberWithInt:ID_INTERVALCOUNT], @"id_0_2_2",
                                NSLS_COMPLEXITY, @"t_0_2_2",

                                [NSNumber numberWithInt:ID_DETAIL], @"id_0_3_1",
                                NSLS_DETAIL, @"t_0_3_1",
                                @"8", @"i_0_3_1",
                                [NSNumber numberWithInt:ID_LENGTHRATIO], @"id_0_3_2",
                                NSLS_GROWTH, @"t_0_3_2",
                                @"9", @"i_0_3_2",
                                [NSNumber numberWithInt:ID_LENGTHBALANCE], @"id_0_3_3",
                                NSLS_SYMMETRY, @"t_0_3_3",
                                @"10", @"i_0_3_3",
                                [NSNumber numberWithInt:ID_ASPECT], @"id_0_3_4",
                                NSLS_ASPECT, @"t_0_3_4",
                                @"13", @"i_0_3_4",
                               
                                [NSNumber numberWithInt:ID_TRUNKWIDTH], @"id_0_4_1",
                            
                                NSLS_WIDTH, @"t_0_4_1",
                                @"14", @"i_0_4_1",
                                [NSNumber numberWithInt:ID_TRUNKTAPER], @"id_0_4_2",
                                NSLS_TAPER, @"t_0_4_2",
                                @"15", @"i_0_4_2",

                                [NSNumber numberWithInt:ID_APEXTYPE], @"id_0_5_1",
                                NSLS_APEX_MODE, @"t_0_5_1",
                                [NSNumber numberWithInt:ID_SPIKINESS], @"id_0_5_2",
                                NSLS_LENGTH, @"t_0_5_2",
                                @"17", @"i_0_5_2",

                                [NSNumber numberWithInt:ID_RANDOMWIGGLE], @"id_0_6_1",
                                NSLS_WIGGLE, @"t_0_6_1",
                                @"19", @"i_0_6_1",
                                [NSNumber numberWithInt:ID_RANDOMANGLE], @"id_0_6_2",
                                NSLS_ANGLES, @"t_0_6_2",
                                @"20", @"i_0_6_2",
                                [NSNumber numberWithInt:ID_RANDOMLENGTH], @"id_0_6_3",
                                NSLS_LENGTHS, @"t_0_6_3",
                                @"21", @"i_0_6_3",
                                [NSNumber numberWithInt:ID_RANDOMINTERVAL], @"id_0_6_4",
                                NSLS_INTERVALS, @"t_0_6_4",
                                @"22", @"i_0_6_4",
                                [NSNumber numberWithInt:ID_RANDOMSEED], @"id_0_6_5",
                                NSLS_REFRESH, @"t_0_6_5",
                                @"18", @"i_0_6_5",

                               // geometric tree
                                [NSNumber numberWithInt:ID_TREETYPE], @"id_1_0_1",
                                NSLS_TREE_MODE, @"t_1_0_1",

                                [NSNumber numberWithInt:ID_ANGLEMODE], @"id_1_1_1",
                                NSLS_ANGLE_MODE, @"t_1_1_1",
                                [NSNumber numberWithInt:ID_SPREAD], @"id_1_1_2",
                                NSLS_SPREAD, @"t_1_1_2",
                                @"3", @"i_1_1_2",
                                [NSNumber numberWithInt:ID_BEND], @"id_1_1_3",
                                NSLS_BEND, @"t_1_1_3",
                                @"5", @"i_1_1_3",
                                [NSNumber numberWithInt:ID_SPIN], @"id_1_1_4",
                                NSLS_SPIN, @"t_1_1_4",
                                @"6", @"i_1_1_4",
                                [NSNumber numberWithInt:ID_TWIST], @"id_1_1_5",
                                NSLS_TWIST, @"t_1_1_5",
                                @"7", @"i_1_1_5",

                                [NSNumber numberWithInt:ID_GEONODES], @"id_1_2_1",
                                NSLS_NODES, @"t_1_2_1",
                                [NSNumber numberWithInt:ID_BRANCHCOUNT], @"id_1_2_2",
                                NSLS_BRANCHES, @"t_1_2_2",

                                [NSNumber numberWithInt:ID_DETAIL], @"id_1_3_1",
                                NSLS_DETAIL, @"t_1_3_1",
                                @"8", @"i_1_3_1",
                                [NSNumber numberWithInt:ID_LENGTHRATIO], @"id_1_3_2",
                                NSLS_GROWTH, @"t_1_3_2",
                                @"9", @"i_1_3_2",
                                [NSNumber numberWithInt:ID_GEODELAY], @"id_1_3_3",
                                NSLS_DELAY, @"t_1_3_3",
                                @"11", @"i_1_3_3",
                                [NSNumber numberWithInt:ID_GEORATIO], @"id_1_3_4",
                                NSLS_GEORATIO, @"t_1_3_4",
                                @"12", @"i_1_3_4",
                                [NSNumber numberWithInt:ID_ASPECT], @"id_1_3_5",
                                NSLS_ASPECT, @"t_1_3_5",
                                @"13", @"i_1_3_5",

                                [NSNumber numberWithInt:ID_TRUNKWIDTH], @"id_1_4_1",
                                NSLS_WIDTH, @"t_1_4_1",
                                @"14", @"i_1_4_1",
                                [NSNumber numberWithInt:ID_TRUNKTAPER], @"id_1_4_2",
                                NSLS_TAPER, @"t_1_4_2",
                                @"15", @"i_1_4_2",

                                [NSNumber numberWithInt:ID_APEXTYPE], @"id_1_5_1",
                                NSLS_APEX_MODE, @"t_1_5_1",
                                [NSNumber numberWithInt:ID_SPIKINESS], @"id_1_5_2",
                                NSLS_LENGTH, @"t_1_5_2",
                                @"17", @"i_1_5_2",

                                [NSNumber numberWithInt:ID_RANDOMWIGGLE], @"id_1_6_1",
                                NSLS_WIGGLE, @"t_1_6_1",
                                @"19", @"i_1_6_1",
                                [NSNumber numberWithInt:ID_RANDOMANGLE], @"id_1_6_2",
                                NSLS_ANGLES, @"t_1_6_2",
                                @"20", @"i_1_6_2",
                                [NSNumber numberWithInt:ID_RANDOMLENGTH], @"id_1_6_3",
                                NSLS_LENGTHS, @"t_1_6_3",
                                @"21", @"i_1_6_3",
                                [NSNumber numberWithInt:ID_RANDOMINTERVAL], @"id_1_6_4",
                                NSLS_INTERVALS, @"t_1_6_4",
                                @"22", @"i_1_6_4",
                                [NSNumber numberWithInt:ID_RANDOMSEED], @"id_1_6_5",
                                NSLS_REFRESH, @"t_1_6_5",
                                @"18", @"i_1_6_5",
                                nil];
    }
    return self;
}

- (void)loadView
{
    self.view = [[[IMShapeMenuView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	IMShapeMenuView *mv = (IMShapeMenuView *)self.view;
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
    
    DEBUG_LOG(@"IMShapeMenuVC viewDidLayoutSubviews");
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
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int tree_type = (int)[self.delegate getParam:ID_TREETYPE];
    
    switch(section)
    {
        case 0:
            return 2;
        case 1:
            if(tree_type==0)
                return 5;
            else
                return 6;
        case 2:
            return 3;
        case 3:
            if(tree_type==0)
                return 5;
            else
                return 6;
        case 4:
            return 3;
        case 5:
            return 3;
        case 6:
        default:
            return 6;
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
            label.text = NSLS_SHAPE;
            label.frame = CGRectMake(left, 0, 100, 20);
        }
        else if(indexPath.section==1)
            label.text = NSLS_ANGLES;
        else if(indexPath.section==2)
            label.text = NSLS_BRANCHING;
        else if(indexPath.section==3)
            label.text = NSLS_SIZES;
        else if(indexPath.section==4)
            label.text = NSLS_TRUNK;
        else if(indexPath.section==5)
            label.text = NSLS_APEX;
        else
            label.text = NSLS_RANDOMIZE;
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
                else if(control==ID_TREETYPE)
                {
                    if([self.delegate getParam:ID_TREETYPE]==0)
                        button.image = [UIImage imageNamed:@"1a_s"];
                    else
                        button.image = [UIImage imageNamed:@"1b_s"];
                }
                else if(control==ID_ANGLEMODE)
                {
                    int angleMode = (int)[self.delegate getParam:ID_ANGLEMODE];
                    if(angleMode==0)
                        button.image = [UIImage imageNamed:@"2d_s"];
                    else if(angleMode==1)
                        button.image = [UIImage imageNamed:@"2b_s"];
                    else if(angleMode==2)
                        button.image = [UIImage imageNamed:@"2c_s"];
                    else
                        button.image = [UIImage imageNamed:@"2a_s"];
                }
                else if(control==ID_APEXTYPE)
                {
                    int apexType = (int)[self.delegate getParam:ID_APEXTYPE];
                    if(apexType==0)
                        button.image = [UIImage imageNamed:@"16a_s"];
                    else if(apexType==1)
                        button.image = [UIImage imageNamed:@"16b_s"];
                    else if(apexType==2)
                        button.image = [UIImage imageNamed:@"16c_s"];
                    else
                        button.image = [UIImage imageNamed:@"16d_s"];
                }
                else if(control==ID_INTERVALSTART || control==ID_INTERVALCOUNT || control==ID_GEONODES || control==ID_BRANCHCOUNT)
                {
                    //button.backgroundColor = [UIColor colorWithRed:0.9 green:0.3 blue:0.5  alpha:1];
                    int val = [self.delegate getParam:control];
                    button.image = [UIImage imageNamed:[NSString stringWithFormat:@"n%d_s", val]];
                }
            }
            else if(imagename)
            {
                button.image = [UIImage imageNamed:imagename];
            }
            else if(control==ID_TREETYPE)
            {
                if([self.delegate getParam:ID_TREETYPE]==0)
                    button.image = [UIImage imageNamed:@"1a"];
                else
                    button.image = [UIImage imageNamed:@"1b"];
            }
            else if(control==ID_ANGLEMODE)
            {
                int angleMode = (int)[self.delegate getParam:ID_ANGLEMODE];
                if(angleMode==0)
                    button.image = [UIImage imageNamed:@"2d"];
                else if(angleMode==1)
                    button.image = [UIImage imageNamed:@"2b"];
                else if(angleMode==2)
                    button.image = [UIImage imageNamed:@"2c"];
                else
                    button.image = [UIImage imageNamed:@"2a"];
            }
            else if(control==ID_APEXTYPE)
            {
                int apexType = (int)[self.delegate getParam:ID_APEXTYPE];
                if(apexType==0)
                    button.image = [UIImage imageNamed:@"16a"];
                else if(apexType==1)
                    button.image = [UIImage imageNamed:@"16b"];
                else if(apexType==2)
                    button.image = [UIImage imageNamed:@"16c"];
                else
                    button.image = [UIImage imageNamed:@"16d"];
            }
            else if(control==ID_INTERVALSTART || control==ID_INTERVALCOUNT || control==ID_GEONODES || control==ID_BRANCHCOUNT)
            {
                //button.backgroundColor = MENU_LIGHT_COLOR;
                int val = [self.delegate getParam:control];
                button.image = [UIImage imageNamed:[NSString stringWithFormat:@"n%d", val]];
            }
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
    
    if(control==ID_RANDOMSEED)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *button = (UIImageView *)[cell.contentView viewWithTag:1];
        button.image = [UIImage imageNamed:@"18_s"];
        [self performSelector:@selector(clearRandomSeed:) withObject:tableView afterDelay:0.25];
        [self.delegate randomSeedRefresh];
    }
    else if(control!=ID_NONE)
    {
        CGRect rct = [tableView rectForRowAtIndexPath:indexPath];
        float y = rct.origin.y - tableView.contentOffset.y + rct.size.height/2 + tableView.frame.origin.y;
        [self.delegate showControl:control y:y];
        
        [tableView reloadData];
        //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)clearRandomSeed:(UITableView *)tableView
{
    [tableView reloadData];
}

- (void)update
{
    DEBUG_LOG(@"update");
    [((IMShapeMenuView *)self.view).tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view setNeedsDisplay];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMShapeMenuVC dealloc");
    [_menuDictionary release];
    [super dealloc];
}

@end
