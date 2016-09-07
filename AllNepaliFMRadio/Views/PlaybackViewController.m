//
//  PlaybackViewController.m
//  All Nepali FM Radio
//
//  Created by Ireneo Decano on 18/3/15.
//  Copyright (c) 2015 Ireneo Decano. All rights reserved.
//

#import "PlaybackViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "JSON.h"

#import "CustomAlert.h"
#import "AppDelegate.h"
#import "FavoriteViewController.h"
#import "DisclaimerViewController.h"
#import "SubmitViewController.h"
//#import "ProgressHUD.h"
#import "MBProgressHUD.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#define jsonValidationURL  @"aHR0cDovL3JhZGlvLml0ZWNobmVwYWwubmV0OjgwODAvdmFsaWRhdGUucGhw"
#define MY_BANNER_UNIT_ID @"ca-app-pub-7672726291086615/6702441485"

@interface PlaybackViewController (){
    int isPlay;
    int isSoundOnOff;
    int nVolumeValue;
    int nCurrentVolumeValue;
    int isFavorite;
    int isSleepTimer;
    int isMenu;
    int isValidation;
    
    int isPortrait;
    int isOption;
    
    NSMutableData *webData;
    NSString * kGAIScreenName;
    
    NSMutableArray *favoriteArray;
    NSMutableArray *favoriteIDArray;
    
    MBProgressHUD *HUD;
    int isShowProgressHUD;
    
    int isShowAdmob_Portrait;
    int isShowAdmob_Landscape;
}

@end

@implementation PlaybackViewController
@synthesize currentRadioModel;
@synthesize isOriginalFavorite;
@synthesize streamer;
@synthesize volumeViewSlider;
@synthesize volumeViewSlider01;
@synthesize volumeView;
@synthesize volumeView01;
@synthesize appDelegate;
@synthesize bannerView;

#pragma mark -
#pragma mark AudioStream Callback Functions

- (void)metaDataUpdated:(NSString *)metaData
{
    //remove extra matadata
    metaData =[metaData stringByReplacingOccurrencesOfString:@"'" withString:@""];
    metaData =[metaData stringByReplacingOccurrencesOfString:@"StreamTitle=" withString:@""];
    NSArray *listItems = [metaData componentsSeparatedByString:@";"];
    
    if ([listItems count] > 0)
    {
        //        songTitle.text = [listItems objectAtIndex:0];
        //        [songTitle sizeToFit];
        //        [self scroll];
        //
    }
    
    [self hideHUD];
    isShowProgressHUD = 0;
}

- (void)streamError
{
    NSString *strMessage = [NSString stringWithFormat:@"Stream is Currently not available for “%@”. Please try again later.", currentRadioModel.station_name];
    
    CustomAlert *alert = [[CustomAlert alloc] initWithTitle:@"Oops...!" message:strMessage delegate:self cancelButtonTitle:@"Back" otherButtonTitle:@""];
    
    [alert showInView:self.view];
    
    NSLog(@"Stream Error.");
    
    [self hideHUD];
    isShowProgressHUD = 0;
}

- (void) customAlertView:(CustomAlert *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (isValidation == 0){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (isMenu != 1){
        if (buttonIndex == 0){
            if (appDelegate.streamer)
                [self stopRadio];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        if (buttonIndex == 0)
            exit(1);
        else
            [self hideMenu];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"Playback Screen";
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait){
        isPortrait = 0;
        self.portraitUIView.hidden = NO;
        self.landscapeUIView.hidden = YES;
    }else if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        isPortrait = 1;
        self.portraitUIView.hidden = YES;
        self.landscapeUIView.hidden = NO;
    }
    
    [self initDatas];
    [self setLayout];
    [self setButtonLayout];
    
    isShowAdmob_Portrait = 0;
    isShowAdmob_Landscape = 0;
    [self showAdMob];
    
    isValidation = 1;
    
    //    NSData *plainData = [jsonValidationURL dataUsingEncoding:NSUTF8StringEncoding];
    //    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    //    NSLog(@"%@", base64String);
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:jsonValidationURL options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    //    NSLog(@"%@", decodedString);
    
    NSURL *url = [NSURL URLWithString:decodedString];
    //    NSLog(@"url : %@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"i0S-aLlNepALIfMri0s" forHTTPHeaderField:@"User-Agent"];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if( theConnection )
    {
        webData= [NSMutableData data];
    }
    else
    {
        NSLog(@"theConnection is NULL");
        
    }
    
    [self stopRadio];
    
    isShowProgressHUD = 1;
    NSString *strMessage = [NSString stringWithFormat:@"Please Wait,  Loading “%@”", currentRadioModel.station_name];
    [self showHUD:strMessage];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
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
        bannerView.adUnitID = MY_BANNER_UNIT_ID;
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Playback Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self hideHUD];
    isShowProgressHUD = 0;
}
#pragma mark -
#pragma mark Connection management

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    int responseStatusCode = (int)[httpResponse statusCode];
    
    if (responseStatusCode == 200)
    {
        [self stopRadio];
        [self playRadio];
        isValidation = 1;
    }else{
        [self hideHUD];
        isShowProgressHUD = 0;
        isValidation = 0;
        NSString *strMessage = [NSString stringWithFormat:@"Stream is Currently not available for “%@”. Please try again later.", currentRadioModel.station_name];
        CustomAlert *alert = [[CustomAlert alloc] initWithTitle:@"Oops…! " message:strMessage delegate:self cancelButtonTitle:@"Back to Radio List" otherButtonTitle:@""];
        
        [alert showInView:self.view];
        NSLog(@"Validation Error.");
    }
    
    [webData setLength: 0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"ERROR with theConenction : %@",[error localizedDescription]);
    
    [self hideHUD];
    isShowProgressHUD = 0;
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *theResponse=[[NSString alloc] initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
//    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:@"i0S-aLlNepALIfMri0s", @"UserAgent", nil];
    //    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    NSDictionary *dicResponse=[theResponse JSONValue];
    NSLog(@"dicResponse %@?",dicResponse);
    
    NSString *status = [dicResponse objectForKey:@"status"];
    
    if ([status isEqual:@"ok"])
    {
        NSLog(@"SUCCESS!!!!");
    }
    else{
        NSLog(@"ERROR");
    }
}

- (void) playRadio{
    if (isShowProgressHUD == 0){
        NSString *strMessage = [NSString stringWithFormat:@"Please Wait, Loading “%@”", currentRadioModel.station_name];
        [self showHUD:strMessage];
    }
    isPlay = 1;
    
    NSString *escapedValue = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(nil, (CFStringRef)currentRadioModel.url, NULL, NULL, kCFStringEncodingUTF8));
    
    NSString *redirectString = [NSString stringWithFormat:@"%@/", escapedValue];
    NSURL *url = [NSURL URLWithString:redirectString];

    appDelegate.streamer = [[AudioStreamer alloc] initWithURL:url];
    [appDelegate.streamer addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
    [appDelegate.streamer setDelegate:self];
    [appDelegate.streamer setDidUpdateMetaDataSelector:@selector(metaDataUpdated:)];
    [appDelegate.streamer setDidErrorSelector:@selector(streamError)];;
    [appDelegate.streamer start];
    [self buttonChange];
}

- (void) stopRadio{
    isPlay = 0;
    appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.streamer setDelegate:self];
    if (appDelegate.streamer){
        [appDelegate.streamer stop];
        appDelegate.streamer = nil;
    }
    [self buttonChange];
}

- (void) initDatas{
    isPlay = 1;
    isSoundOnOff = 1;
    isSleepTimer = 0;
    isMenu = 0;
    
    favoriteArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < appDelegate.favoriteArray.count; i ++)
         [favoriteArray addObject:[appDelegate.favoriteArray objectAtIndex:i]];
    
    favoriteIDArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < appDelegate.favoriteIDArray.count; i ++)
        [favoriteIDArray addObject:[appDelegate.favoriteIDArray objectAtIndex:i]];
    
    isFavorite = 0;
    //isFavorite
    appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.favoriteArray == nil){
        isFavorite = 0;
    }else{
        RadioModel *tempRadioModel;
        
        for(tempRadioModel in favoriteArray){
            if (currentRadioModel.id == tempRadioModel.id && currentRadioModel.address == tempRadioModel.address && currentRadioModel.url == tempRadioModel.url && currentRadioModel.station_name == tempRadioModel.station_name && currentRadioModel.website_address == currentRadioModel.website_address)
                isFavorite = 1;
        }
    }
    
}

- (void) setLayout{
    self.menuUIView.hidden = YES;
    self.menuUIView01.hidden =  YES;
    
    self.sleepTimerUIView.hidden = YES;
    self.sleepTimerUIView01.hidden = YES;
    
    self.volumeUIView.hidden = YES;
    self.volumeUIView01.hidden = YES;
    
    self.lblStationName.text = currentRadioModel.station_name;
    self.lblAddress.text = currentRadioModel.address;
    
    self.lblStationName01.text = currentRadioModel.station_name;
    self.lblAddress01.text = currentRadioModel.address;
    
    if (isFavorite == 1){
        self.imgFavorite.hidden = NO;
        self.imgFavorite01.hidden = NO;
    }else{
        self.imgFavorite.hidden = YES;
        self.imgFavorite01.hidden = YES;
    }
    
    if (appDelegate.nSleepTimeIndex == 0){
        self.imgAlarm.hidden = YES;
        self.lblAarmText.hidden = YES;
        
        self.imgAlarm01.hidden = YES;
        self.lblAarmText01.hidden = YES;
    }else{
        self.imgAlarm.hidden = NO;
        self.lblAarmText.hidden = NO;
        
        self.imgAlarm01.hidden = NO;
        self.lblAarmText01.hidden = NO;
        
        if (appDelegate.nSleepTimeIndex == 1){
            self.lblAarmText.text = @"5 mins";
            self.lblAarmText01.text = @"5 mins";
        }else if (appDelegate.nSleepTimeIndex == 2){
            self.lblAarmText.text = @"15 mins";
            self.lblAarmText01.text = @"15 mins";
        }else if (appDelegate.nSleepTimeIndex == 3){
            self.lblAarmText.text = @"30 mins";
            self.lblAarmText01.text = @"30 mins";
        }else if (appDelegate.nSleepTimeIndex == 4){
            self.lblAarmText.text = @"1 hr";
            self.lblAarmText01.text = @"1 hr";
        }else if (appDelegate.nSleepTimeIndex == 5){
            self.lblAarmText.text = @" 2 hrs";
            self.lblAarmText01.text = @" 2 hrs";
        }else if (appDelegate.nSleepTimeIndex == 6){
            self.lblAarmText.text = @"4 hrs";
            self.lblAarmText01.text = @"4 hrs";
        }else if (appDelegate.nSleepTimeIndex == 7){
            self.lblAarmText.text = @"6 hrs";
            self.lblAarmText01.text = @"6 hrs";
        }
        
        [appDelegate setSleepTimer];
        
    }
    
    if (appDelegate.nSleepTimeIndex == 0){
        [self.btnNone setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        [self.btnNone01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
    }else{
        [self.btnNone setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
        [self.btnNone01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    }
    
    if (appDelegate.nSleepTimeIndex == 1){
        [self.btn5min setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        [self.btn5min01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
    }else{
        [self.btn5min setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
        [self.btn5min01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    }
    
    if (appDelegate.nSleepTimeIndex == 2){
        [self.btn15min setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        [self.btn15min01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
    }else{
        [self.btn15min setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
        [self.btn15min01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    }
    
    if (appDelegate.nSleepTimeIndex == 3){
        [self.btn30min setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        [self.btn30min01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
    }else{
        [self.btn30min setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
        [self.btn30min01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    }
    
    if (appDelegate.nSleepTimeIndex == 4){
        [self.btn1hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        [self.btn1hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
    }else{
        [self.btn1hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
        [self.btn1hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    }
    
    if (appDelegate.nSleepTimeIndex == 5){
        [self.btn2hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        [self.btn2hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
    }else{
        [self.btn2hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
        [self.btn2hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    }
    
    if (appDelegate.nSleepTimeIndex == 6){
        [self.btn4hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        [self.btn4hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
    }else{
        [self.btn4hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
        [self.btn4hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    }
    
    if (appDelegate.nSleepTimeIndex == 7){
        [self.btn6hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        [self.btn6hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
    }else{
        [self.btn6hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
        [self.btn6hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    }
    
    // Register for Route Change notifications
    AVAudioSession *session = [ AVAudioSession sharedInstance ];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleRouteChange:)
                                                 name: AVAudioSessionRouteChangeNotification
                                               object: session];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    
    // Find the volume view slider
    for (UIView *view in [volumeView subviews]){
        if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
            volumeViewSlider = (UISlider *) view;
        }
    }
    
    for (UIView *view in [volumeView01 subviews]){
        if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
            volumeViewSlider01 = (UISlider *) view;
        }
    }
    
    [volumeViewSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [volumeViewSlider01 addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    nVolumeValue = (int)(volumeViewSlider.value * 100);
    nCurrentVolumeValue = nVolumeValue;
    self.lblVolume.text = [NSString stringWithFormat:@"%d", nVolumeValue];
    self.lblVolume01.text = [NSString stringWithFormat:@"%d", nVolumeValue];
    self.volumeUIView.hidden = YES;
    self.volumeUIView01.hidden = YES;
    
    self.alertUIView.hidden = YES;
    self.alertUIView01.hidden = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    singleTap.numberOfTapsRequired = 1;
    [self.menuUIView setUserInteractionEnabled:YES];
    [self.menuUIView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *singleTap01 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureTimer:)];
    singleTap01.numberOfTapsRequired = 1;
    [self.sleepTimerUIView setUserInteractionEnabled:YES];
    [self.sleepTimerUIView addGestureRecognizer:singleTap01];
    
    UITapGestureRecognizer *singleTap02 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    singleTap02.numberOfTapsRequired = 1;
    [self.menuUIView01 setUserInteractionEnabled:YES];
    [self.menuUIView01 addGestureRecognizer:singleTap02];
    
    UITapGestureRecognizer *singleTap03 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureTimer:)];
    singleTap03.numberOfTapsRequired = 1;
    [self.sleepTimerUIView01 setUserInteractionEnabled:YES];
    [self.sleepTimerUIView01 addGestureRecognizer:singleTap03];
    
    
    UIDevice *device = [UIDevice currentDevice];
    //Tell it to start monitoring the accelerometer for orientation
    [device beginGeneratingDeviceOrientationNotifications];
    //Get the notification centre for the app
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:device];
}

//-----menu view------
- (void) tapGesture: (UIGestureRecognizer *) gestureRecognizer{
    [self hideMenu];
}

- (void) hideMenu{
    isMenu = 0;
    [UIView animateWithDuration:1.0 delay:0.5 options: UIViewAnimationOptionCurveEaseIn animations:^{
        if (isPortrait == 0)
            self.menuUIView.hidden = YES;
        else
            self.menuUIView01.hidden = YES;

    }
    completion:^(BOOL finished){ }];
}

- (void) openMenu{
    isMenu = 1;
    [UIView animateWithDuration:1.0 delay:0.5 options: UIViewAnimationOptionCurveEaseIn animations:^{
        if (isPortrait == 0)
            self.menuUIView.hidden = NO;
        else
            self.menuUIView01.hidden = NO;
    }
    completion:^(BOOL finished){  }];
}
//-----menu view end ----

//-----sleep timer view------
- (void) tapGestureTimer: (UIGestureRecognizer *) gestureRecognizer{
    [self hideSleepTimer];
}

- (void) hideSleepTimer{
    [UIView animateWithDuration:1.0 delay:0.5 options: UIViewAnimationOptionCurveEaseIn animations:^{
        if (isPortrait == 0)
            self.sleepTimerUIView.hidden = YES;
        else
            self.sleepTimerUIView01.hidden = YES;
    }
    completion:^(BOOL finished){ }];
    
}

- (void) openSleepTimer{
    [UIView animateWithDuration:1.0 delay:0.5 options: UIViewAnimationOptionCurveEaseIn animations:^{
        if (isPortrait == 0)
            self.sleepTimerUIView.hidden = NO;
        else
            self.sleepTimerUIView01.hidden = NO;
    }
    completion:^(BOOL finished){ }];
}
//-----sleep timer view end----

- (IBAction)sliderValueChanged:(UISlider *)sender {
    nVolumeValue = (int)(sender.value * 100);
    self.lblVolume.text = [NSString stringWithFormat:@"%d", nVolumeValue];
    self.volumeUIView.hidden = NO;

    self.lblVolume01.text = [NSString stringWithFormat:@"%d", nVolumeValue];
    self.volumeUIView01.hidden = NO;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    [super touchesBegan:touches withEvent:event];
    
    if (touch.view != self.volumeUIView && touch.view != self.volumeViewSlider)
        self.volumeUIView.hidden = YES;
    
    if (touch.view != self.volumeUIView01 && touch.view != self.volumeViewSlider01)
        self.volumeUIView01.hidden = YES;
}

- (void) setButtonLayout{
    [self.btnNone addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn5min addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn15min addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn30min addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn1hour addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn2hour addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn4hour addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn6hour addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnNone01 addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn5min01 addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn15min01 addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn30min01 addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn1hour01 addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn2hour01 addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn4hour01 addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn6hour01 addTarget:self action:@selector(pressTimerButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) pressTimerButton:(UIButton *)sender{
    if ((int)sender.tag < 20 && (int)sender.tag >= 10)
        appDelegate.nSleepTimeIndex = (int)sender.tag - 10;
    else if ((int)sender.tag > 20)
        appDelegate.nSleepTimeIndex = (int)sender.tag - 20;
    
    if (sender.tag == 10){
        [self.btnNone setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm.hidden = YES; self.lblAarmText.hidden = YES;
    }else
        [self.btnNone setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 11){
        [self.btn5min setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm.hidden = NO; self.lblAarmText.hidden = NO;
        self.lblAarmText.text = @"5 mins";
    }else
        [self.btn5min setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 12){
        [self.btn15min setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm.hidden = NO; self.lblAarmText.hidden = NO;
        self.lblAarmText.text = @"15 mins";
    }else
        [self.btn15min setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 13){
        [self.btn30min setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm.hidden = NO; self.lblAarmText.hidden = NO;
        self.lblAarmText.text = @"30 mins";
    }else
        [self.btn30min setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 14){
        [self.btn1hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm.hidden = NO; self.lblAarmText.hidden = NO;
        self.lblAarmText.text = @"1 hr";
    }else
        [self.btn1hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 15){
        [self.btn2hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm.hidden = NO; self.lblAarmText.hidden = NO;
        self.lblAarmText.text = @"2 hr";
    }else
        [self.btn2hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 16){
        [self.btn4hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm.hidden = NO; self.lblAarmText.hidden = NO;
        self.lblAarmText.text = @"4 hr";
    }else
        [self.btn4hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 17){
        [self.btn6hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm.hidden = NO; self.lblAarmText.hidden = NO;
        self.lblAarmText.text = @"6 hr";
    }else
        [self.btn6hour setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    //landscape
    if (sender.tag == 20){
        [self.btnNone01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm01.hidden = YES; self.lblAarmText01.hidden = YES;
    }else
        [self.btnNone01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 21){
        [self.btn5min01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm01.hidden = NO; self.lblAarmText01.hidden = NO;
        self.lblAarmText01.text = @"5 mins";
    }else
        [self.btn5min01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 22){
        [self.btn15min01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm01.hidden = NO; self.lblAarmText01.hidden = NO;
        self.lblAarmText01.text = @"15 mins";
    }else
        [self.btn15min01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 23){
        [self.btn30min01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm01.hidden = NO; self.lblAarmText01.hidden = NO;
        self.lblAarmText01.text = @"30 mins";
    }else
        [self.btn30min01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 24){
        [self.btn1hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm01.hidden = NO; self.lblAarmText01.hidden = NO;
        self.lblAarmText01.text = @"1 hr";
    }else
        [self.btn1hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 25){
        [self.btn2hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm01.hidden = NO; self.lblAarmText01.hidden = NO;
        self.lblAarmText01.text = @"2 hr";
    }else
        [self.btn2hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 26){
        [self.btn4hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm01.hidden = NO; self.lblAarmText01.hidden = NO;
        self.lblAarmText01.text = @"4 hr";
    }else
        [self.btn4hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    if (sender.tag == 27){
        [self.btn6hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_on.png"] forState:UIControlStateNormal];
        self.imgAlarm01.hidden = NO; self.lblAarmText01.hidden = NO;
        self.lblAarmText01.text = @"6 hr";
    }else
        [self.btn6hour01 setBackgroundImage:[UIImage imageNamed:@"btn_sleepTimer_off.png"] forState:UIControlStateNormal];
    
    [appDelegate setSleepTimer];
}

// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"isPlaying"])
    {
        if ([(AudioStreamer *)object isPlaying])
        {
            
        }
        else
        {
            [appDelegate.streamer removeObserver:self forKeyPath:@"isPlaying"];
            [appDelegate.streamer stop];
            appDelegate.streamer = nil;
        }
        
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change
                          context:context];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)pressBackToListButton:(id)sender {
    [appDelegate.streamer stop];
    appDelegate.streamer = nil;
    
    //    AppDelegate *appDelegate01 = [[UIApplication sharedApplication] delegate];
    //    appDelegate01.streamer = appDelegate.streamer;
    
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

- (IBAction)pressShortcutButton:(id)sender {
}

- (IBAction)pressPrevButton:(id)sender {
    int nIndex = 0;
    
    RadioModel *tempRadioModel;
    
    if (isOriginalFavorite == 0){
        for (int i=0; i<appDelegate.originalArry.count; i++) {
            tempRadioModel = [appDelegate.originalArry objectAtIndex:i];
            
            if (currentRadioModel.id == tempRadioModel.id && currentRadioModel.address == tempRadioModel.address && currentRadioModel.url == tempRadioModel.url && currentRadioModel.station_name == tempRadioModel.station_name && currentRadioModel.website_address == currentRadioModel.website_address)
                nIndex = i;
        }
        
        if (nIndex > 0) {
            currentRadioModel = [appDelegate.originalArry objectAtIndex:--nIndex];
        }
    }
    else{
        for (int i=0; i<appDelegate.favoriteArray.count; i++) {
            tempRadioModel = [appDelegate.favoriteArray objectAtIndex:i];
            
            if (currentRadioModel.id == tempRadioModel.id && currentRadioModel.address == tempRadioModel.address && currentRadioModel.url == tempRadioModel.url && currentRadioModel.station_name == tempRadioModel.station_name && currentRadioModel.website_address == currentRadioModel.website_address)
                nIndex = i;
        }
        
        if (nIndex > 0) {
            currentRadioModel = [appDelegate.favoriteArray objectAtIndex:--nIndex];
        }
    }
    
    [self stopRadio];
    [self playRadio];
    [self initDatas];
    [self setLayout];
}

- (IBAction)pressNextButton:(id)sender {
    int nIndex = 0;
    
    RadioModel *tempRadioModel;
    
    if (isOriginalFavorite == 0){
        for (int i=0; i<appDelegate.originalArry.count; i++) {
            tempRadioModel = [appDelegate.originalArry objectAtIndex:i];
            
            if (currentRadioModel.id == tempRadioModel.id && currentRadioModel.address == tempRadioModel.address && currentRadioModel.url == tempRadioModel.url && currentRadioModel.station_name == tempRadioModel.station_name && currentRadioModel.website_address == currentRadioModel.website_address)
                nIndex = i;
        }
        
        if (nIndex < appDelegate.originalArry.count - 1) {
            currentRadioModel = [appDelegate.originalArry objectAtIndex:++nIndex];
        }
    }
    else{
        for (int i=0; i<appDelegate.favoriteArray.count; i++) {
            tempRadioModel = [appDelegate.favoriteArray objectAtIndex:i];
            
            if (currentRadioModel.id == tempRadioModel.id && currentRadioModel.address == tempRadioModel.address && currentRadioModel.url == tempRadioModel.url && currentRadioModel.station_name == tempRadioModel.station_name && currentRadioModel.website_address == currentRadioModel.website_address)
                nIndex = i;
        }
        
        if (nIndex < appDelegate.favoriteArray.count - 1) {
            currentRadioModel = [appDelegate.favoriteArray objectAtIndex:++nIndex];
        }
    }
    
    [self stopRadio];
    [self playRadio];
    [self initDatas];
    [self setLayout];
}

- (IBAction)pressPlayButton:(id)sender {
    if (!appDelegate.streamer)
        [self playRadio];
    else
        [self stopRadio];
    
}

- (IBAction)pressInBackgroundButton:(id)sender {
    //    exit(0);
}

- (IBAction)pressSleepTimerButton:(id)sender {
    if (isSleepTimer == 0){
        isSleepTimer = 1;
        [self openSleepTimer];
    }else{
        isSleepTimer = 0;
        [self hideSleepTimer];
    }
}

- (IBAction)pressShareButton:(id)sender {
    NSURL *url = [[NSURL alloc] initWithString:@"https://www.facebook.com/nepalifmradioandtv"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)pressRateButton:(id)sender {
}

- (IBAction)pressAddToFavButton:(id)sender {
    if (isPortrait == 0){
        if (isFavorite == 0){
            isFavorite = 1;
            [UIView animateWithDuration:1.0 delay:0.5 options: UIViewAnimationOptionCurveEaseIn animations:^{
                
                self.alertUIView.hidden = NO;
                self.lblAlertTitle.text = @"Add to Fav List";
            }
            completion:^(BOOL finished){ }];
            
            self.imgFavorite.hidden = NO;
            self.imgFavorite01.hidden = NO;
            [favoriteArray addObject:currentRadioModel];
            [favoriteIDArray addObject:currentRadioModel.id];
            
            appDelegate.favoriteArray = favoriteArray;
            appDelegate.favoriteIDArray = favoriteIDArray;
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:appDelegate.favoriteIDArray] forKey:@"favoriteIDArray"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self performSelector:@selector(hideAlert) withObject:nil afterDelay:2.0];
        }else{
            [UIView animateWithDuration:1.0 delay:0.5 options: UIViewAnimationOptionCurveEaseIn animations:^{
                
                self.alertUIView.hidden = NO;
                self.lblAlertTitle.text = @"Already in Fav List";
            }
                             completion:^(BOOL finished){ }];
            
            [self performSelector:@selector(hideAlert) withObject:nil afterDelay:2.0];
        }
    }else{
        if (isFavorite == 0){
            isFavorite = 1;
            [UIView animateWithDuration:1.0 delay:0.5 options: UIViewAnimationOptionCurveEaseIn animations:^{
                
                self.alertUIView01.hidden = NO;
                self.lblAlertTitle01.text = @"Add to Fav List";
            }
            completion:^(BOOL finished){ }];
            
            self.imgFavorite.hidden = NO;
            self.imgFavorite01.hidden = NO;
            [favoriteArray addObject:currentRadioModel];
            [favoriteIDArray addObject:currentRadioModel.id];
            
            appDelegate.favoriteArray = favoriteArray;
            appDelegate.favoriteIDArray = favoriteIDArray;

            
            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:appDelegate.favoriteIDArray] forKey:@"favoriteIDArray"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self performSelector:@selector(hideAlert) withObject:nil afterDelay:2.0];
        }else{
            [UIView animateWithDuration:1.0 delay:0.5 options: UIViewAnimationOptionCurveEaseIn animations:^{
                
                self.alertUIView01.hidden = NO;
                self.lblAlertTitle01.text = @"Already in Fav List";
            }
            completion:^(BOOL finished){ }];
            
            [self performSelector:@selector(hideAlert) withObject:nil afterDelay:2.0];
        }

    }
}


- (void) hideAlert{
    [UIView animateWithDuration:1.0 delay:0.7 options: UIViewAnimationOptionCurveEaseOut animations:^{
        if (isPortrait == 0)
            self.alertUIView.hidden = YES;
        else
            self.alertUIView01.hidden = YES;
    }
    completion:^(BOOL finished){ }];
    
}

- (IBAction)pressSoundOnOff:(id)sender {
    if (isPortrait == 0){
        if (isSoundOnOff == 1){
            isSoundOnOff = 0;
            [self.btnSoundOnOff setBackgroundImage:[UIImage imageNamed:@"img_sound_off.png"] forState:UIControlStateNormal];
            
            nCurrentVolumeValue = (int)(self.volumeViewSlider.value * 100);
            self.volumeViewSlider.value = 0;
            
        }else{
            isSoundOnOff = 1;
            [self.btnSoundOnOff setBackgroundImage:[UIImage imageNamed:@"img_sound_on.png"] forState:UIControlStateNormal];
            
            self.volumeViewSlider.value =  nCurrentVolumeValue;
        }
    }else{
        if (isSoundOnOff == 1){
            isSoundOnOff = 0;
            [self.btnSoundOnOff01 setBackgroundImage:[UIImage imageNamed:@"img_sound_off.png"] forState:UIControlStateNormal];
            
            nCurrentVolumeValue = (int)(self.volumeViewSlider01.value * 100);
            self.volumeViewSlider01.value = 0;
            
        }else{
            isSoundOnOff = 1;
            [self.btnSoundOnOff01 setBackgroundImage:[UIImage imageNamed:@"img_sound_on.png"] forState:UIControlStateNormal];
            
            self.volumeViewSlider01.value =  nCurrentVolumeValue;
        }
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//remove earphone
-(void)handleRouteChange:(NSNotification*)notification{
    AVAudioSession *session = [ AVAudioSession sharedInstance ];
    NSString* seccReason = @"";
    NSInteger  reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    AVAudioSessionRouteDescription* prevRoute = [[notification userInfo] objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            seccReason = @"The route changed because no suitable route is now available for the specified category.";
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            seccReason = @"The route changed when the device woke up from sleep.";
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            seccReason = @"The output route was overridden by the app.";
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            seccReason = @"The category of the session object changed.";
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            seccReason = @"The previous audio output path is no longer available.";
            [streamer stop];
            NSLog(@"earphone out");
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            seccReason = @"A preferred new audio output path is now available.";
            break;
        case AVAudioSessionRouteChangeReasonUnknown:
        default:
            seccReason = @"The reason for the change is unknown.";
            break;
    }
    AVAudioSessionPortDescription *input = [[session.currentRoute.inputs count]?session.currentRoute.inputs:nil objectAtIndex:0];
    if (input.portType == AVAudioSessionPortHeadsetMic) {
        
    }
}

- (void) buttonChange{
    if (isPlay == 1){
        [self.btnPlay setBackgroundImage:[UIImage imageNamed:@"btn_play_down.png"] forState:UIControlStateNormal];
        [self.imgPlayBackground setImage:[UIImage imageNamed:@"img_playbackground_led_on.png"]];
        
        [self.btnPlay01 setBackgroundImage:[UIImage imageNamed:@"btn_play_down.png"] forState:UIControlStateNormal];
        [self.imgPlayBackground01 setImage:[UIImage imageNamed:@"img_playbackground_led_on.png"]];
    }else{
        [self.btnPlay setBackgroundImage:[UIImage imageNamed:@"btn_play_normal.png"] forState:UIControlStateNormal];
        [self.imgPlayBackground setImage:[UIImage imageNamed:@"img_playbackground_led_off.png"]];
        
        [self.btnPlay01 setBackgroundImage:[UIImage imageNamed:@"btn_play_normal.png"] forState:UIControlStateNormal];
        [self.imgPlayBackground01 setImage:[UIImage imageNamed:@"img_playbackground_led_off.png"]];
    }
}

//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//

#pragma mark Remote Control Events
/* The iPod controls will send these events when the app is in the background */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            [appDelegate.streamer stop];
            break;
        case UIEventSubtypeRemoteControlPlay:
            [appDelegate.streamer start];
            break;
        case UIEventSubtypeRemoteControlPause:
            [appDelegate.streamer stop];
            break;
        case UIEventSubtypeRemoteControlStop:
            [appDelegate.streamer stop];
            break;
        default:
            break;
    }
}

- (IBAction)pressMenuHomeButton:(id)sender {
    [self hideMenu];
    [self stopRadio];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)pressMenuFavoriteButton:(id)sender {
    [self hideMenu];
    [self stopRadio];
    
    FavoriteViewController *favoriteViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"favoriteView"];
    [self.navigationController pushViewController:favoriteViewController animated:TRUE];
}

- (IBAction)pressMenuDisclaimerButton:(id)sender {
    DisclaimerViewController *disclaimerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"disclaimerView"];
    
    [self.navigationController pushViewController:disclaimerViewController animated:TRUE];
}

- (IBAction)pressMenuSubmitButton:(id)sender {
    [self hideMenu];
    
    SubmitViewController *submitViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"submitView"];
    
    [self.navigationController pushViewController:submitViewController animated:TRUE];
}

- (IBAction)pressMenuRuninBackground:(id)sender {
}

- (IBAction)pressMenuCloseButton:(id)sender {
    CustomAlert *alert = [[CustomAlert alloc] initWithTitle:@"Notification" message:@"Are you going to close app?" delegate:self  cancelButtonTitle:@"OK" otherButtonTitle:@"Cancel"];
    
    [alert showInView:self.view];
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

#pragma mark -
#pragma mark - MBPRogressHUD Delegate

- (void) showHUD :(NSString*)text
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.delegate = nil;
    
    HUD.mode = MBProgressHUDModeIndeterminate;
    
    HUD.labelText = text;
    
    [HUD show:YES];
}

- (void) hideHUD
{
    [HUD hide:YES];
}
@end
