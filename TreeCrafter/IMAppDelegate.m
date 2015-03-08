//
//  IMAppDelegate.m
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMAppDelegate.h"
#import "IMRootViewController.h"
#import "IMTreeModel.h"
#import "IMTreeRender.h"

#import "iRate.h"

#ifdef DEBUG
#import <mach/mach.h>
#import <mach/mach_host.h>
#endif

@implementation IMAppDelegate

- (void)printMemoryStats
{
#ifdef DEBUG
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
    {
        NSLog(@"Failed to fetch vm statistics");
        return;
    }
    
    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
    double mb = 1024.0f*1024.0f;
    NSLog(@"Memory used: %f free: %f total: %f", mem_used/mb, mem_free/mb, mem_total/mb);
#endif
}

- (void)dealloc
{
    [_window release];
    [_rootViewController release];
    [_render release];
    [_tree release];
    [_pdffilepath release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if(getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled"))
    {
        NSLog(@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
        exit(0);
    }
    
    self.tree = [[[IMTreeModel alloc] init] autorelease];
    self.render = [[[IMTreeRender alloc] initWithTree:self.tree] autorelease];
    
    // load tree from saved file if it exists
    NSString *savedtreefile = [NSTemporaryDirectory() stringByAppendingPathComponent:CURRENT_TREE_FILE];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if([fileMgr fileExistsAtPath:savedtreefile])
    {
        NSDictionary *treeState = [NSDictionary dictionaryWithContentsOfFile:savedtreefile];
        if(treeState)
            [self.tree setTreeParameters:treeState];
    }
    
    NSString *docpath = [self pathForDocuments];
    if(docpath)
    {
        NSString *usertreefile = [docpath stringByAppendingPathComponent:TREE_FILE];
        if(![fileMgr fileExistsAtPath:usertreefile])
        {
            DEBUG_LOG(@"Copying startuptrees.plist");
            
            // copy over the bundle tree file at initial install
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            NSString *bundleFile = [bundlePath stringByAppendingPathComponent:@"startuptrees.plist"];
            [fileMgr copyItemAtPath:bundleFile toPath:usertreefile error:nil];
            
            // copy over the icon files
            NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:bundlePath error:nil];
            if(directoryContents)
            {
                NSString *cachePath = [[self userPathForDirectory:NSCachesDirectory] path];
                for(NSString *path in directoryContents)
                {
                    if([[path pathExtension] isEqualToString:@"png"] && [path length] > 32)
                    {
                        NSString *fullSrcPath = [bundlePath stringByAppendingPathComponent:path];
                        NSString *fullDstPath = [cachePath stringByAppendingPathComponent:path];
                        
                        DEBUG_LOG(@"Copying thumbnail %@ to %@", fullSrcPath, fullDstPath);
                        [fileMgr copyItemAtPath:fullSrcPath toPath:fullDstPath error:nil];
                    }
                }
            }
        }
    }
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.rootViewController = [[[IMRootViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidConnectNotification:) name:UIScreenDidConnectNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidDisconnectNotification:) name:UIScreenDidDisconnectNotification object:nil];
    
    m_useExternalDisplay = NO;
    self.treeSaved = NO;
    
    //[self purgeFiles];
    
    //[iRate sharedInstance].previewMode = YES;
    
    return YES;
}

- (void)setUseExternalDisplay:(BOOL)ed
{
    m_useExternalDisplay = ed;
    
    if(ed)
    {
        if([[UIScreen screens] count] > 1)
        {
            // external display present
            [self connectScreen:[[UIScreen screens] objectAtIndex:1]];
        }
    }
    else
        [self disconnectScreen];
}

- (BOOL)useExternalDisplay
{
    return m_useExternalDisplay;
}

- (void)connectScreen:(UIScreen *)screen
{
}

- (void)disconnectScreen
{
}

- (void)screenDidConnectNotification:(NSNotification *)notification
{
    UIScreen *screen = [notification object];
    //CGRect bounds = [screen bounds];
    //DEBUG_LOG(@"connected external display %f x %f", bounds.size.width, bounds.size.height);
    [self connectScreen:screen];

}

- (void)screenDidDisconnectNotification:(NSNotification *)notification
{
    DEBUG_LOG(@"disconnected external display");
    [self disconnectScreen];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    DEBUG_LOG(@"IMAppDelegate applicationWillResignActive");
#ifdef DEBUG
    [self printMemoryStats];
#endif
    [self.rootViewController appPause];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    DEBUG_LOG(@"IMAppDelegate applicationDidEnterBackground");
    
    // save current tree state to temp file in case app quits
    NSString *savedtreefile = [NSTemporaryDirectory() stringByAppendingPathComponent:CURRENT_TREE_FILE];
    [[self.tree treeParameters] writeToFile:savedtreefile atomically:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DEBUG_LOG(@"IMAppDelegate applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    DEBUG_LOG(@"IMAppDelegate applicationDidBecomeActive");
    [self.rootViewController appResume];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DEBUG_LOG(@"IMAppDelegate applicationWillTerminate");
}

- (void)purgeFiles
{
    NSURL *urlpath = [self userPathForDirectory:NSCachesDirectory];
    if(urlpath==nil)
        return;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:[urlpath path] error:nil];
    if(directoryContents)
    {
        for(NSString *path in directoryContents)
        {
            NSString *fullPath = [[urlpath path] stringByAppendingPathComponent:path];
            if([[fullPath pathExtension] isEqualToString:@"png"])
            {
                DEBUG_LOG(@"deleting icon file %@", fullPath);
                [fileMgr removeItemAtPath:fullPath error:nil];
            }
        }
    }
    
    urlpath = [self userPathForDirectory:NSDocumentDirectory];
    if(urlpath==nil)
        return;
    
    directoryContents = [fileMgr contentsOfDirectoryAtPath:[urlpath path] error:nil];
    if(directoryContents)
    {
        for(NSString *path in directoryContents)
        {
            NSString *fullPath = [[urlpath path] stringByAppendingPathComponent:path];
            if([[fullPath pathExtension] isEqualToString:@"pdf"])
            {
                DEBUG_LOG(@"deleting pdf file %@", fullPath);
                [fileMgr removeItemAtPath:fullPath error:nil];
            }
        }
    }
}

- (NSMutableArray *)loadUserTrees
{
    DEBUG_LOG(@"Load user trees");
    NSMutableArray *usertrees = [[[NSMutableArray alloc] initWithCapacity:MAX_SAVED_TREES] autorelease];
    
    NSURL *path = [self userPathForDirectory:NSDocumentDirectory];
    if(path==nil)
        return usertrees;
    
    path = [path URLByAppendingPathComponent:TREE_FILE];
    
    NSArray *loadedtrees = [NSArray arrayWithContentsOfURL:path];
    if(loadedtrees==nil)
        return usertrees;
    
    DEBUG_LOG(@"loaded %d trees from %@", [loadedtrees count], path);
    //[self dumpData:loadedtrees];
    
    NSDictionary *currentparams = [self.tree treeParameters];
    
    int count = 0;
    for(id item in loadedtrees)
    {
        DEBUG_LOG(@"validating %d", count);
        if(![item isKindOfClass:[NSDictionary class]])
        {
            DEBUG_LOG(@"failed because not a dictionary");
            break;
        }
        
        NSDictionary *loadedparams = (NSDictionary *)item;
        DEBUG_LOG(@"this dictionary has %d entries", [loadedparams count]);
        
        // check the version number
        id version = [loadedparams objectForKey:@"ParamsVersion"];
        if(version==nil)
        {
            DEBUG_LOG(@"failed because ParamsVersion not found");
            continue;
        }
        if(![version isKindOfClass:[NSNumber class]])
        {
            DEBUG_LOG(@"failed because ParamsVersion not an nsnumber");
            continue;
        }
        int params_version = [(NSNumber *)version intValue];
        if(params_version!=1)
        {
            DEBUG_LOG(@"failed because ParamsVersion incorrect");
            continue;
        }
        
        NSMutableDictionary *validatedparams = [[NSMutableDictionary alloc] initWithCapacity:MAX_SAVED_TREES];
        
        // pull out the properties and validate them all against defaults
        for(NSString *keyname in currentparams)
        {
            id valueid = [loadedparams objectForKey:keyname];
            if(valueid!=nil && [valueid isKindOfClass:[NSNumber class]])
            {
                // use the value in the loaded dictionary
                [validatedparams setObject:valueid forKey:keyname];
            }
            else
            {
                // copy over the value from the current tree
                NSNumber *numbercopy = [(NSNumber *)[currentparams objectForKey:keyname] copy];
                [validatedparams setObject:numbercopy forKey:keyname];
                [numbercopy release];
            }
        }
        
        // check for icon file property
        id iconid = [loadedparams objectForKey:@"IconFile"];
        if([iconid isKindOfClass:[NSString class]])
        {
            [validatedparams setObject:iconid forKey:@"IconFile"];
        }
        else
        {
            [validatedparams setObject:@"" forKey:@"IconFile"];
        }
        
        // add version number
        [validatedparams setObject:[NSNumber numberWithInt:1] forKey:@"ParamsVersion"];
        
        DEBUG_LOG(@"validated ok");
        count++;
        
        // add new dictionary to array
        [usertrees addObject:validatedparams];
        [validatedparams release];
        
        if([usertrees count]==MAX_SAVED_TREES)
            break;
    }
    
    DEBUG_LOG(@"ended up loading %d trees", [usertrees count]);
    //[self dumpData:usertrees];
    
    return usertrees;
}

- (void)saveUserTrees:(NSArray *)treeset
{
    if(treeset==nil)
        return;
    
    NSURL *path = [self userPathForDirectory:NSDocumentDirectory];
    if(path==nil)
        return;
    
    path = [path URLByAppendingPathComponent:TREE_FILE];
    
    DEBUG_LOG(@"saving %d trees to %@", [treeset count], path);
    [treeset writeToURL:path atomically:YES];
}

- (void)addCurrentTreeToUserTrees:(NSMutableArray *)treeset
{
    if(treeset==nil)
        return;
    
    if([treeset count]>=100)
        return;
    
    DEBUG_LOG(@"Adding current tree to saved trees");
    NSDictionary *currentparams = [self.tree treeParameters];
    NSMutableDictionary *newparams = [[NSMutableDictionary alloc] initWithDictionary:currentparams copyItems:YES];
    
    [newparams setObject:[NSNumber numberWithInt:1] forKey:@"ParamsVersion"];
    
    [self createUserTreeThumbnailForTree:newparams];
    
    [treeset insertObject:newparams atIndex:0];
    
    [newparams release];
    
    // save tree
    [self saveUserTrees:treeset];
}

- (void)deleteUserTreeAtIndex:(int)index userTrees:(NSMutableArray *)treeset
{
    DEBUG_LOG(@"Deleting tree from saved trees");
    NSDictionary *params = [treeset objectAtIndex:index];
    NSString *iconfile = [[params objectForKey:@"IconFile"] stringByAppendingPathExtension:@"png"];

    if([iconfile length]>0)
    {
        NSURL *urlpath = [self userPathForDirectory:NSCachesDirectory];
        if(urlpath!=nil)
        {
            urlpath = [urlpath URLByAppendingPathComponent:iconfile];
            DEBUG_LOG(@"deleting icon %@", urlpath);
            
            NSFileManager *manager = [NSFileManager defaultManager];
            if([manager fileExistsAtPath:[urlpath path]])
            {
                DEBUG_LOG(@"file exists so deleting");
                [manager removeItemAtURL:urlpath error:NULL];
            }
        }
    }
    
    [treeset removeObjectAtIndex:index];
    
    // save tree
    [self saveUserTrees:treeset];
}

- (void)createUserTreeThumbnailForTree:(NSMutableDictionary *)params
{
    DEBUG_LOG(@"Creating user tree thumbnail");
    
    [self.rootViewController disableDisplayUpdatesWithRedraw:NO];
    
    NSDictionary *currenttreeparams = self.tree.treeParameters;
    self.tree.treeParameters = params;
    
    UIImage *image = [self.tree drawImageWithSize:CGSizeMake(TREE_ICON_WIDTH, TREE_ICON_HEIGHT) ox:0 oy:0 scale:0 quality:QUALITY_ICON adaptForDisplay:YES background:nil header:nil footer:nil textcolor:nil logo:NO error:NULL];
    
    self.tree.treeParameters = currenttreeparams;
    
    [self.rootViewController enableDisplayUpdatesWithRedraw:YES];
    
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
	NSString *filename = [(NSString *)newUniqueIdString stringByAppendingPathExtension: @"png"];
    
    NSURL *urlpath = [self userPathForDirectory:NSCachesDirectory];
    if(urlpath!=nil && image!=nil)
    {
        urlpath = [urlpath URLByAppendingPathComponent:filename];
        DEBUG_LOG(@"saving icon %@", urlpath);
        [UIImagePNGRepresentation(image) writeToURL:urlpath atomically:YES];
        [params setObject:(NSString *)newUniqueIdString forKey:@"IconFile"];
    }
    else
    {
        [params setObject:@"" forKey:@"IconFile"];
    }
    
    CFRelease(newUniqueId);
	CFRelease(newUniqueIdString);
}

- (UIImage *)loadUserTreeThumbnailForTreeAtIndex:(int)index userTrees:(NSMutableArray *)treeset
{
    DEBUG_LOG(@"Loading tree thumbnail for position %d", index);
    NSMutableDictionary *params = treeset[index];
    NSString *iconfilename = [params objectForKey:@"IconFile"];
    if([iconfilename length]==0)
    {
        DEBUG_LOG(@"filename was invalid");
        [self createUserTreeThumbnailForTree:params];
        [self saveUserTrees:treeset]; // to save the icon name
        iconfilename = [params objectForKey:@"IconFile"];
    }
    
    if([iconfilename length]>0)
    {
        NSURL *urlpath = [self userPathForDirectory:NSCachesDirectory];
        if(urlpath!=nil)
        {
            urlpath = [urlpath URLByAppendingPathComponent:[iconfilename stringByAppendingPathExtension:@"png"]];
            NSFileManager *manager = [NSFileManager defaultManager];
            if(![manager fileExistsAtPath:[urlpath path]])
            {
                DEBUG_LOG(@"icon cache file not found so creating");
                [self createUserTreeThumbnailForTree:params];
                [self saveUserTrees:treeset]; // to save the icon name
                iconfilename = [params objectForKey:@"IconFile"];
                if([iconfilename length]==0)
                    return nil;
                urlpath = [self userPathForDirectory:NSCachesDirectory];
                urlpath = [urlpath URLByAppendingPathComponent:[iconfilename stringByAppendingPathExtension:@"png"]];
            }
            
            DEBUG_LOG(@"making UIImage with file %@", urlpath);
            UIImage *icon = [UIImage imageWithContentsOfFile:[urlpath path]];
            if(icon==nil)
                DEBUG_LOG(@"image was nil");
            return icon;
        }
        
    }

    return nil;
}

// NSDocumentDirectory
// NSCachesDirectory
- (NSURL *)userPathForDirectory:(NSSearchPathDirectory)type
{
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:type inDomains:NSUserDomainMask];
    
    NSURL *dir = nil;
    if([possibleURLs count] > 0)
        dir = [possibleURLs objectAtIndex:0];
    else
        NSLog(@"Failed to obtain application standard path");
    
    return dir;
}

- (NSString *)pathForDocuments
{
    NSURL *url = [self userPathForDirectory:NSDocumentDirectory];
    if(url==nil)
        return nil;
    else
        return [url path];
}


@end


