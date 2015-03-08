//
//  IMSharingView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/7/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMSharingMenuView.h"
#import "IMGlobal.h"

@implementation IMSharingMenuView

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
    
    self.tableView.frame = CGRectMake(5, 40, self.bounds.size.width-15, self.bounds.size.height-80);
}

- (void)drawRect:(CGRect)rect
{
    [IMGlobal drawMenuContainerWithBounds:self.bounds rightSide:NO];
    [IMGlobal drawSmallScrollArrowsForScrollView:self.tableView offset:0];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMSharingMenuView dealloc");
    
    [_tableView release];
    
    [super dealloc];
}

@end
