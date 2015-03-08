//
//  IMPaperSizeViewController.m
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMPaperSizeViewController.h"

@interface IMPaperSizeViewController ()

@property (nonatomic, retain) NSArray *sizeLabels;
@property (nonatomic, retain) NSArray *sizeValues;

@end

@implementation IMPaperSizeViewController

- (id)initWithPaperSize:(CGSize)size
{
    DEBUG_LOG(@"IMPaperSizeViewController initWithPaperSize");
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        // Custom initialization
        [self setTitle:NSLS_CHOOSE_PAPER_SIZE];
        
        
        self.sizeLabels = @[
                            NSLS_POSTCARD__, // 4.25 x 6
                            NSLS_LETTER__, // 8.5 x 11
                            NSLS_POSTER__1, // 11 x 17
                            NSLS_POSTER__2, // 18 x 24
                            NSLS_POSTER__3, // 24 x 36
                            NSLS_A6__, //4.1 x 5.8 in
                            NSLS_A5__, //5.8 x 8.3 in
                            NSLS_A4__, //8.3 x 11.7 in
                            NSLS_A3__, //11.7 x 16.5 in
                            NSLS_A2__, //16.5 x 23.4 in
                            NSLS_A1__  //23.39 × 33.11 in
                            ];
        self.sizeValues = @[
                            [NSValue valueWithCGSize:CGSizeMake(306, 432)], // 4.25 x 6
                            [NSValue valueWithCGSize:CGSizeMake(612, 792)], // 8.5 x 11
                            [NSValue valueWithCGSize:CGSizeMake(792, 1224)], // 11 x 17
                            [NSValue valueWithCGSize:CGSizeMake(1296, 1728)], // 18 x 24
                            [NSValue valueWithCGSize:CGSizeMake(1728, 2592)], // 24 x 36
                            [NSValue valueWithCGSize:CGSizeMake(298, 420)],
                            [NSValue valueWithCGSize:CGSizeMake(420, 595)],
                            [NSValue valueWithCGSize:CGSizeMake(595, 842)],
                            [NSValue valueWithCGSize:CGSizeMake(842, 1191)],
                            [NSValue valueWithCGSize:CGSizeMake(1191, 1684)],
                            [NSValue valueWithCGSize:CGSizeMake(1684, 2384)],
                            ];
        
        self.contentSizeForViewInPopover = CGSizeMake(320, 44*[self.sizeLabels count]);
        
        m_selection = -1;
        int i = 0;
        for(NSValue *v in self.sizeValues)
        {
            CGSize s = [v CGSizeValue];
            if(s.width==size.width && s.height==size.height)
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
    DEBUG_LOG(@"IMPaperSizeViewController viewDidLoad");
    [super viewDidLoad];

    self.tableView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning
{
    DEBUG_LOG(@"IMPaperSizeViewController didReceiveMemoryWarning");
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
    return [self.sizeLabels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:@"PaperCell"];
    if(cell==nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PaperCell"]
                autorelease];
    
    cell.textLabel.text = self.sizeLabels[indexPath.row];
    if(indexPath.row==m_selection)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSValue *value = self.sizeValues[indexPath.row];
    CGSize s = [value CGSizeValue];
    [self.delegate paperSizeVCDidFinishWithSize:s label:self.sizeLabels[indexPath.row]];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMPaperSizeViewController dealloc");
    [_sizeLabels release];
    [_sizeValues release];
    [super dealloc];
}

@end
