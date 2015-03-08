//
//  IMColorViewController.m
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMModalColorSelectorViewController.h"
#import "IMColorWheelControl.h"

@interface IMModalColorSelectorViewController ()

@end

@implementation IMModalColorSelectorViewController

- (id)initWithTitle:(NSString *)title
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        // Custom initialization
        self.contentSizeForViewInPopover = CGSizeMake(320, 322);
        [self setTitle:title];
        self.color = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:1];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setScrollEnabled:FALSE];
}

- (void)dealloc
{
    [m_color release];
    
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.delegate colorSelectionCancelled:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setColor:(UIColor *)color
{
    if(color != m_color)
    {
        UIColor *old = m_color;
        m_color = [color retain];
        [old release];
        [self.tableView reloadData];
    }
}

- (void)setColorNoReload:(UIColor *)color
{
    if(color != m_color)
    {
        UIColor *old = m_color;
        m_color = [color retain];
        [old release];
    }
}

-(UIColor *)color
{
    return [[m_color retain] autorelease];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1)
        return 170;
    else
        return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(indexPath.section==0)
    {
        UIView *view;
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"SwatchCell"];
        if(cell==nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CompletionCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            view = [[[UIView alloc] initWithFrame:CGRectMake(14, 5, 272, 34)] autorelease];
            view.tag = 1;
            [cell.contentView addSubview:view];
        }
        else
            view = [cell.contentView viewWithTag:1];
        view.backgroundColor = self.color;
    }
    else if(indexPath.section==1)
    {
        IMColorWheelControl *colorControl;
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"ColorCell"];
        if(cell==nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ColorCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            colorControl = [[[IMColorWheelControl alloc] initWithFrame:CGRectMake(5,5,290,160)] autorelease];
            [colorControl addTarget:self action:@selector(colorWheelValueChanged:) forControlEvents:UIControlEventValueChanged];
            colorControl.tag = 1;
            [cell.contentView addSubview:colorControl];
        }
        else
            colorControl = (IMColorWheelControl *)[cell.contentView viewWithTag:1];
        
        colorControl.color = self.color;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CompletionCell"];
        if(cell==nil)
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CompletionCell"] autorelease];
        cell.textLabel.text = NSLS_DONE
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==2)
        [self.delegate colorSelectionFinished:self];
}

- (void)colorWheelValueChanged:(IMColorWheelControl *)sender
{
    [self setColorNoReload:sender.color];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [[cell.contentView viewWithTag:1] setBackgroundColor:sender.color];

    [self.delegate colorSelectionChanged:self];
}


@end
