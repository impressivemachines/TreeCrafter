//
//  IMOrganizeMenuView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/11/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMOrganizeMenuView.h"
#import "IMGlobal.h"
#import "IMAppDelegate.h"

#include <QuartzCore/QuartzCore.h>

@implementation IMOrganizeMenuView

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
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //self.editButton.backgroundColor = MENU_LIGHT_COLOR;
        //self.editButton.layer.cornerRadius = 10;
        //self.editButton.layer.borderWidth = 2;
        //self.editButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        [self addSubview:self.editButton];
        
        self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //self.saveButton.backgroundColor = MENU_LIGHT_COLOR;
        //self.saveButton.layer.cornerRadius = 10;
        //self.saveButton.layer.borderWidth = 2;
        //self.saveButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        [self addSubview:self.saveButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.frame = CGRectMake(5, 60+16, self.bounds.size.width-15, self.bounds.size.height-120-32);
    self.editButton.frame = CGRectMake(20, self.bounds.size.height - 50, self.bounds.size.width-45, 30);
    self.saveButton.frame = CGRectMake(20, 20, self.bounds.size.width-45, 30);
    
    [self updateButtons];
}

- (void)drawRect:(CGRect)rect
{
    [IMGlobal drawMenuContainerWithBounds:self.bounds rightSide:NO];
    [IMGlobal drawSmallScrollArrowsForScrollView:self.tableView offset:54];
}

- (void)updateButtons
{
    if([self.tableView isEditing])
        [self.editButton setImage:[self imageForButtonSize:self.editButton.frame.size text:NSLS_CANCEL check:NO] forState:UIControlStateNormal];
    else
        [self.editButton setImage:[self imageForButtonSize:self.editButton.frame.size text:NSLS_EDIT check:NO] forState:UIControlStateNormal];
    
    IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.saveButton setImage:[self imageForButtonSize:self.saveButton.frame.size text:NSLS_SAVE_TREE check:app.treeSaved] forState:UIControlStateNormal];
}

- (UIImage *)imageForButtonSize:(CGSize)size text:(NSString *)text check:(BOOL)check
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    [MENU_LIGHT_COLOR set];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10];
    [path fill];
    
    
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    CGSize textsize = [text sizeWithFont:font constrainedToSize:rect.size lineBreakMode:NSLineBreakByClipping];
    
    [[UIColor whiteColor] set];
    
    //shadow highlight
    [text drawInRect:CGRectMake(0, 0.5f*(rect.size.height - textsize.height) + 1, rect.size.width, textsize.height) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    
    if(check)
        [[UIColor grayColor] set];
    else
        [MENU_DARK_COLOR set];
    
    [text drawInRect:CGRectMake(0, 0.5f*(rect.size.height - textsize.height), rect.size.width, textsize.height) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    
    /*if(check)
    {
        float x = size.width - 18;
        float y = size.height/2;
        
        path = [UIBezierPath bezierPath];
        path.lineWidth = 3;
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        [path moveToPoint:CGPointMake(x-4, y)];
        [path addLineToPoint:CGPointMake(x, y+6)];
        [path addLineToPoint:CGPointMake(x+8, y-6)];
        [path stroke];
    }*/
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)dealloc
{
    DEBUG_LOG(@"IMOrganizeMenuView dealloc");
    [_tableView release];
    [_editButton release];
    [_saveButton release];
    
    [super dealloc];
}

@end
