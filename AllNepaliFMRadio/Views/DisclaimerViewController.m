//
//  DisclaimerViewController.m
//  All Nepali FM Radio
//
//  Created by Ireneo Decano on 20/3/15.
//  Copyright (c) 2015 Ireneo Decano. All rights reserved.
//

#import "DisclaimerViewController.h"
#import "FavoriteViewController.h"
#import "SubmitViewController.h"

#import "CustomAlert.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#define MY_BANNER_UNIT_ID @"ca-app-pub-7672726291086615/6702441485"

@interface DisclaimerViewController ()
{
    int isPortrait;
    int isOption;
    
    NSString * kGAIScreenName;
    
    int isShowAdmob_Portrait;
    int isShowAdmob_Landscape;
}
@end

@implementation DisclaimerViewController
@synthesize bannerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set screen name.
    self.screenName = @"Disclaimer Screen";

    if (self.interfaceOrientation == UIInterfaceOrientationPortrait){
        isPortrait = 0;
        self.portraitUIView.hidden = NO;
        self.landscapeUIView.hidden = YES;
    }else if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        isPortrait = 1;
        self.portraitUIView.hidden = YES;
        self.landscapeUIView.hidden = NO;
    }

    [self setLayout];
    
    isShowAdmob_Portrait = 0;
    isShowAdmob_Landscape = 0;
    [self showAdMob];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Disclaimer Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void) setLayout{
    self.menuUIView.hidden = YES;
    self.menuUIView01.hidden = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    singleTap.numberOfTapsRequired = 1;
    [self.menuUIView setUserInteractionEnabled:YES];
    [self.menuUIView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *singleTap01 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    singleTap01.numberOfTapsRequired = 1;
    [self.menuUIView01 setUserInteractionEnabled:YES];
    [self.menuUIView01 addGestureRecognizer:singleTap01];
    
    UIDevice *device = [UIDevice currentDevice];
    //Tell it to start monitoring the accelerometer for orientation
    [device beginGeneratingDeviceOrientationNotifications];
    //Get the notification centre for the app
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:device];
}

- (void) showAdMob{
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    if (isPortrait == 0 && isShowAdmob_Portrait == 0){
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            bannerView = [[GADBannerView alloc]
                          initWithFrame:CGRectMake((screenSize.size.width - GAD_SIZE_320x50.width) / 2, screenSize.size.height-GAD_SIZE_320x50.height, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
        else
            bannerView = [[GADBannerView alloc]
                          initWithFrame:CGRectMake((screenSize.size.width - GAD_SIZE_468x60
                                                    .width) / 2, screenSize.size.height-GAD_SIZE_468x60.height, GAD_SIZE_468x60.width, GAD_SIZE_468x60.height)];
        
        bannerView.rootViewController = self;
        [self.portraitUIView addSubview:bannerView];
        
        [bannerView loadRequest:[GADRequest request]];
        isShowAdmob_Portrait = 1;
    }
    
    if (isPortrait == 1 && isShowAdmob_Landscape == 0){
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            bannerView = [[GADBannerView alloc]
                          initWithFrame:CGRectMake((screenSize.size.width - GAD_SIZE_320x50.width) / 2, screenSize.size.height-GAD_SIZE_320x50.height, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
        else
            bannerView = [[GADBannerView alloc]
                          initWithFrame:CGRectMake((screenSize.size.width - GAD_SIZE_468x60
                                                    .width) / 2, screenSize.size.height-GAD_SIZE_468x60.height, GAD_SIZE_468x60.width, GAD_SIZE_468x60.height)];
        bannerView.adUnitID = MY_BANNER_UNIT_ID;
        
        bannerView.rootViewController = self;
        [self.landscapeUIView addSubview:bannerView];
        
        [bannerView loadRequest:[GADRequest request]];
        isShowAdmob_Landscape = 1;
    }
}

- (void) tapGesture: (UIGestureRecognizer *) gestureRecognizer{
    [self hideMenu];
}

- (void) hideMenu{
    [UIView animateWithDuration:1.0 delay:0.5 options: UIViewAnimationOptionCurveEaseIn animations:^{
        if (isPortrait == 0)
            self.menuUIView.hidden = YES;
        else
            self.menuUIView01.hidden = YES;
    }
    completion:^(BOOL finished){  }];
}

- (void) openMenu{
    [UIView animateWithDuration:1.0 delay:0.5 options: UIViewAnimationOptionCurveEaseIn animations:^{
        if (isPortrait == 0)
            self.menuUIView.hidden = NO;
        else
            self.menuUIView01.hidden = NO;
    }
    completion:^(BOOL finished){  }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pressOKButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressBackToListButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)pressOptionButton:(id)sender {
    if (isOption == 0){
        isOption = 1;
        
        [self openMenu];
    }else{
        isOption = 0;
        
        [self hideMenu];
    }
}

//Menu Buttons Events

- (IBAction)pressMenuHomeButton:(id)sender {
    [self hideMenu];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)pressMenuFavoriteButton:(id)sender {
    [self hideMenu];
    
    FavoriteViewController *favoriteViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"favoriteView"];
    
    [self.navigationController pushViewController:favoriteViewController animated:TRUE];
}

- (IBAction)pressMenuDisclaimerButton:(id)sender {
    [self hideMenu];
}

- (IBAction)pressMenuSubmitButton:(id)sender {
    [self hideMenu];
    
    SubmitViewController *submitViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"submitView"];
    
    [self.navigationController pushViewController:submitViewController animated:TRUE];
}

- (IBAction)pressMenuRuninBackgroundButton:(id)sender {
}

- (IBAction)pressMenuCloseButton:(id)sender {
    CustomAlert *alert = [[CustomAlert alloc] initWithTitle:@"Notification" message:@"Are you going to close app?" delegate:self  cancelButtonTitle:@"OK" otherButtonTitle:@"Cancel"];
    
    [alert showInView:self.view];
}
     

- (void) customAlertView:(CustomAlert *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0)
        exit(1);
    else
        [self hideMenu];
}


- (void)orientationChanged:(NSNotification *)note
{
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
        self.portraitUIView.hidden = YES;
        self.landscapeUIView.hidden = NO;
        isPortrait = 1;
        [self showAdMob];
    }else if([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait){
        self.portraitUIView.hidden = NO;
        self.landscapeUIView.hidden = YES;
        isPortrait = 0;
        [self showAdMob];
    }
}
@end
