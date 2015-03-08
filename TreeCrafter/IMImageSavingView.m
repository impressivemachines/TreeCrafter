//
//  IMImageSavingView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/30/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMImageSavingView.h"
#import "IMGlobal.h"

@implementation IMImageSavingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.titleLabel.font = [UIFont systemFontOfSize:18];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 0;
        [self addSubview:self.titleLabel];
        
        self.progressBar = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault] autorelease];
        [self addSubview:self.progressBar];
        
        self.cancelButton = [[[IMRoundedButton alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:self.cancelButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float w = 320;
    float h = 200;
    float x = self.bounds.size.width/2 - w/2;
    float y = self.bounds.size.height/2 - h/2;
    
    self.titleLabel.frame = CGRectMake(x+30, y+30, w-60, 44);
    self.progressBar.frame = CGRectMake(x+30, y+h/2-5, w-60, 40);
    self.cancelButton.frame = CGRectMake(x+ w/2 - 50, y+h/2 + 40, 100, 36);
    [self.cancelButton setButtonText:NSLS_CANCEL];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    float w = 320;
    float h = 200;
    [IMGlobal drawControlContainerWithBounds:CGRectMake(self.bounds.size.width/2 - w/2,
                                                        self.bounds.size.height/2 - h/2,
                                                        w, h)];
}

- (void)dealloc
{
    DEBUG_LOG(@"ImageSavingView dealloc");
    [_titleLabel release];
    [_progressBar release];
    [_cancelButton release];
    
    [super dealloc];
}

@end
