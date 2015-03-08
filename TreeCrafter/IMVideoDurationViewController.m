//
//  IMVideoDurationViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/11/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMVideoDurationViewController.h"

@interface IMVideoDurationViewController ()

@property (nonatomic, retain) NSArray *durationLabels;
@property (nonatomic, retain) NSArray *durations;

@end

@implementation IMVideoDurationViewController

- (id)initWithDuration:(int)duration
{
    DEBUG_LOG(@"IMVideoDurationViewController initWithDuration");
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        [self setTitle:NSLS_CHOOSE_VIDEO_DURATION];
        
        self.durationLabels = @[NSLS_15_SEC, NSLS_30_SEC, NSLS_1_MIN, NSLS_2_MIN, NSLS_5_MIN];
        self.durations = @[
                           [NSNumber numberWithInt:15],
                           [NSNumber numberWithInt:30],
                           [NSNumber numberWithInt:60],
                           [NSNumber numberWithInt:120],
                           [NSNumber numberWithInt:300]
                           ];
        
        self.contentSizeForViewInPopover = CGSizeMake(320, 44*[self.durationLabels count]);
        
        m_selection = -1;
        int i = 0;
        for(NSNumber *n in self.durations)
        {
            if([n intValue]==duration)
            {
                m_selection = i;
                break;
            }
            i++;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    DEBUG_LOG(@"IMVideoDurationViewController viewDidLoad");
    [super viewDidLoad];
    
    self.tableView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.durationLabels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"DurationCell"];
    if(cell==nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DurationCell"]
                autorelease];
    
    cell.textLabel.text = self.durationLabels[indexPath.row];
    if(indexPath.row==m_selection)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *duration = self.durations[indexPath.row];
    [self.delegate videoDurationVCDidFinishWithDuration:[duration intValue] durationLabel:self.durationLabels[indexPath.row]];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMVideoDurationViewController dealloc");
    [_durationLabels release];
    [_durations release];
    [super dealloc];
}

@end
