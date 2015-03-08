//
//  IMColorMenuView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/11/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMColorMenuView.h"
#import "IMGlobal.h"

@implementation IMColorMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
        [self addSubview:self.tableView];
        self.tableView.backgroundColor = MENU_BG_COLOR;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.frame = CGRectMake(10, 40, self.bounds.size.width-12, self.bounds.size.height-80);
}

- (void)drawRect:(CGRect)rect
{
    [IMGlobal drawMenuContainerWithBounds:self.bounds rightSide:YES];
    [IMGlobal drawSmallScrollArrowsForScrollView:self.tableView offset:10];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMColorMenuView dealloc");
    [_tableView release];
    
    [super dealloc];
}

@end
