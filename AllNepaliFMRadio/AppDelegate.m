//
//  AppDelegate.m
//  All Nepali FM Radio
//
//  Created by Ireneo Decano on 17/3/15.
//  Copyright (c) 2015 Ireneo Decano. All rights reserved.
//

#import "AppDelegate.h"

#import "GAI.h"

#define kTrackingId @"UA-45896814-9"

@interface AppDelegate (){
    NSArray *sleepTimeArray;
    NSTimer *timer;
}

@end

@implementation AppDelegate
@synthesize originalArry;
@synthesize streamer;
@synthesize favoriteArray;
@synthesize favoriteIDArray;
@synthesize nSleepTimeIndex;
@synthesize nIndicatorRate;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    originalArry = [[NSMutableArray alloc] init];
    
    streamer = nil;
    
    nSleepTimeIndex = 0;
    sleepTimeArray = [[NSArray alloc]  initWithObjects:@"0", @"5", @"15", @"30", @"60", @"120", @"240", @"360", nil];
    
    //[self getUserDefaults];
   
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
//    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-45896814-9"];

//    self.tracker = [[GAI sharedInstance] trackerWithName:@"Radio"
//                                              trackingId:kTrackingId];
//    self.tracker.allowIDFACollection = YES;
    
//    [self showApplicationMainWindow];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    if (rect.size.width == 320) //iphone 5
        nIndicatorRate = 1.07;
    else if (rect.size.width == 375) //iphone 6
        nIndicatorRate = 1.03;
    else if (rect.size.width > 375) //ipad
        nIndicatorRate = 1.03;
    
    //Volume Controll
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    //Default Volume to iPhone Speaker
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
    return YES;
}

- (void) showApplicationMainWindow{
    UIStoryboard *storyboard;
    UIViewController *mainViewController;
    
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
        NSLog(@"sad");
    else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft)
        NSLog(@"asdf");
    else if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait)
        NSLog(@"ASdfasdf");
    
    if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone_Landscape" bundle:nil];
        mainViewController = [storyboard instantiateInitialViewController];
    }
    else if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
    {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone_Landscape" bundle:nil];
        mainViewController = [storyboard instantiateInitialViewController];
    }
    else if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)
    {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone_Portrait" bundle:nil];
        mainViewController = [storyboard instantiateInitialViewController];
    }

    self.window.rootViewController = mainViewController;
}

- (void) getUserDefaults{
    NSArray *arrayItem = [[NSUserDefaults standardUserDefaults] objectForKey:@"originalIDArray"];
    if (arrayItem == nil) originalArry = nil;
    else originalArry = (NSMutableArray *)arrayItem;
    
    arrayItem = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteIDArray"];
    if (arrayItem == nil) favoriteIDArray = nil;
    else favoriteIDArray = (NSMutableArray *)arrayItem;
    
    RadioModel *rModel;
    favoriteArray = [[NSMutableArray alloc] init];
    for (int i=0; i<favoriteIDArray.count; i++)
    {
        for (rModel in originalArry){
            if ([rModel.id isEqualToString:[favoriteIDArray objectAtIndex:i]])
                [favoriteArray addObject:rModel];
        }
    }
}

- (void) setSleepTimer{
    if (nSleepTimeIndex == 0){
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
    }else{
        NSString *strSleepTime = [sleepTimeArray objectAtIndex:nSleepTimeIndex];
//        [self performSelector:@selector(sleepMethod) withObject:nil afterDelay:[strSleepTime integerValue] * 60];
        timer = [NSTimer scheduledTimerWithTimeInterval:[strSleepTime integerValue] * 60
                                                 target:self
                                               selector:@selector(sleepMethod)
                                               userInfo:nil
                                                repeats:NO];
    }
}

- (void) sleepMethod{
    nSleepTimeIndex = 0;
    
    if (streamer){
        streamer = nil;
    }
    
    exit(0);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
