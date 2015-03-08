//
//  IMPDFOrganizerViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/13/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMPDFOrganizerViewController.h"
#import "IMAppDelegate.h"

@interface IMPDFOrganizerViewController ()

@end

@implementation IMPDFOrganizerViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        [self setTitle:NSLS_PDF_ORGANIZER];
        
        self.contentSizeForViewInPopover = CGSizeMake(320, 600);
        
        self.filenames = [[[NSMutableArray alloc] init] autorelease];
        self.filesizes = [[[NSMutableArray alloc] init] autorelease];
        
        IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *path = [app pathForDocuments];
        if(path)
        {
            NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:path error:nil];
            if(directoryContents)
            {
                for(NSString *file in directoryContents)
                {
                    if([[file pathExtension] isEqualToString:@"pdf"])
                    {
                        DEBUG_LOG(@"found pdf file %@", file);
                        NSNumber *fileSize = [[fileMgr attributesOfItemAtPath:[path stringByAppendingPathComponent:file] error:nil] objectForKey:NSFileSize];
                        if(fileSize==nil)
                            fileSize = [NSNumber numberWithInt:0];
                        [self.filesizes addObject:fileSize];
                        [self.filenames addObject:[file stringByDeletingPathExtension]];
                    }
                }
            }
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [self.filenames count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TREE_ICON_HEIGHT + 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    UIImageView *imageView;
    UILabel *label1, *label2, *label3;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"PDFCell"];
    if(cell==nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PDFCell"]
                autorelease];
        
        imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 5, TREE_ICON_WIDTH, TREE_ICON_HEIGHT)] autorelease];
        imageView.tag = 1;
        [cell.contentView addSubview:imageView];
        
        float w = 110;
        float h = 30;
        float x = 20+TREE_ICON_WIDTH;
        float y = 46;
        float ys = 5;
        
        label1 = [[[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)] autorelease];
        label1.font = [UIFont systemFontOfSize:16];
        label1.backgroundColor = [UIColor lightGrayColor];
        label1.textColor = [UIColor blackColor];
        label1.textAlignment = NSTextAlignmentLeft;
        label1.numberOfLines = 1;
        
        label1.tag = 2;
        [cell.contentView addSubview:label1];
        
        label2 = [[[UILabel alloc] initWithFrame:CGRectMake(x, y+h+ys, w, h)] autorelease];
        label2.font = [UIFont systemFontOfSize:16];
        label2.backgroundColor = [UIColor lightGrayColor];
        label2.textColor = [UIColor blackColor];
        label2.textAlignment = NSTextAlignmentLeft;
        label2.numberOfLines = 1;
        label2.tag = 3;
        [cell.contentView addSubview:label2];
        
        label3 = [[[UILabel alloc] initWithFrame:CGRectMake(x, y+h+ys+h+ys, w, h)] autorelease];
        label3.font = [UIFont systemFontOfSize:16];
        label3.backgroundColor = [UIColor lightGrayColor];
        label3.textColor = [UIColor blackColor];
        label3.textAlignment = NSTextAlignmentLeft;
        label3.numberOfLines = 1;
        label3.tag = 4;
        [cell.contentView addSubview:label3];
    }
    else
    {
        imageView = (UIImageView *)[cell.contentView viewWithTag:1];
        label1 = (UILabel *)[cell.contentView viewWithTag:2];
        label2 = (UILabel *)[cell.contentView viewWithTag:3];
        label3 = (UILabel *)[cell.contentView viewWithTag:4];
    }
    
    IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *docpath = [app pathForDocuments];
    NSString *filebasename = self.filenames[indexPath.row];
    NSString *imagefile = [docpath stringByAppendingPathComponent:[filebasename stringByAppendingPathExtension:@"png"]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:imagefile])
        imageView.image = [UIImage imageWithContentsOfFile:imagefile];
    else
        imageView.image = [UIImage imageNamed:@"null_tree"];

    NSArray *components = [filebasename componentsSeparatedByString:@"-"];
    if([components count]==7)
    {
        int year = [components[1] intValue];
        int month = [components[2] intValue];
        int day = [components[3] intValue];
        int hour = [components[4] intValue];
        int minute = [components[5] intValue];
        int second = [components[6] intValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateStyle:NSDateFormatterNoStyle];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setYear:year];
        [comps setMonth:month];
        [comps setDay:day];
        [comps setHour:hour];
        [comps setMinute:minute];
        [comps setSecond:second];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *date = [calendar dateFromComponents:comps];
        [comps release];
        [calendar release];
        
        label1.text = [NSString stringWithFormat:@" %@", [dateFormatter stringFromDate:date]];
        label2.text = [NSString stringWithFormat:@" %@", [timeFormatter stringFromDate:date]];
        
        NSNumber *fileSize = self.filesizes[indexPath.row];
        double mb = [fileSize doubleValue] / (1024*1024);
        
        if(mb>=1)
        {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setLocale:[NSLocale currentLocale]];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [numberFormatter setPositiveFormat:@"0.00"];
            label3.text = [NSString stringWithFormat:@" %@ %@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:mb]], NSLS_MB];
            [numberFormatter release];
        }
        else
        {
            label3.text = [NSString stringWithFormat:@" %.0f %@", mb*1024, NSLS_KB];
        }

        [dateFormatter release];
        [timeFormatter release];
    }
    else
    {
        label1.text = @" ?";
        label2.text = @" ?";
        label3.text = @" ?";
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *path = [app pathForDocuments];
        
        NSString *filebasename = self.filenames[indexPath.row];
        [fileMgr removeItemAtPath:[path stringByAppendingPathComponent:[filebasename stringByAppendingPathExtension:@"png"]] error:nil];
        [fileMgr removeItemAtPath:[path stringByAppendingPathComponent:[filebasename stringByAppendingPathExtension:@"pdf"]] error:nil];
        
        [self.filenames removeObjectAtIndex:indexPath.row];
        [self.filesizes removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate pdfOrganizerVCDidFinishWithFile:[self.filenames[indexPath.row] stringByAppendingPathExtension:@"pdf"]];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMPDFOrganizerVC dealloc");
    
    [_filenames release];
    [_filesizes release];
    
    [super dealloc];
}
@end
