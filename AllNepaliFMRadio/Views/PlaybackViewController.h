//
//  PlaybackViewController.h
//  All Nepali FM Radio
//
//  Created by Ireneo Decano on 18/3/15.
//  Copyright (c) 2015 Ireneo Decano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CustomAlert.h"
#import "RadioModel.h"
#import "AppDelegate.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import "GAITrackedViewController.h"

@class AudioStreamer;

@interface PlaybackViewController : UIViewController <AVAudioPlayerDelegate, CustomAlertDelegate>

@property (strong, nonatomic) GADBannerView *bannerView;
@property (strong, nonatomic) GADBannerView *bannerView01;
@property (strong, nonatomic) NSString *screenName;

@property (nonatomic, strong) RadioModel *currentRadioModel;
@property (nonatomic, strong) AudioStreamer *streamer;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (assign, nonatomic) int isOriginalFavorite;

//Portrait Contollers
@property (weak, nonatomic) IBOutlet UIView *portraitUIView;

@property (weak, nonatomic) IBOutlet UILabel *lblStationName;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UIImageView *imgFavorite;
@property (weak, nonatomic) IBOutlet UIImageView *imgAlarm;
@property (weak, nonatomic) IBOutlet UILabel *lblAarmText;
@property (weak, nonatomic) IBOutlet UILabel *lblVolume;
@property (weak, nonatomic) IBOutlet UIButton *btnSoundOnOff;

@property (weak, nonatomic) IBOutlet UIImageView *imgPlayBackground;

@property (weak, nonatomic) IBOutlet UIButton *btnPlay;

@property (weak, nonatomic) IBOutlet UIButton *btn_InBackground;
@property (weak, nonatomic) IBOutlet UIButton *btnAddToFav;
@property (weak, nonatomic) IBOutlet UIButton *btnShareButton;
@property (weak, nonatomic) IBOutlet UIButton *btnSleepTimerButton;
@property (weak, nonatomic) IBOutlet UIButton *btnRateButton;

@property (weak, nonatomic) IBOutlet UIView *volumeUIView;
@property (weak, nonatomic) IBOutlet MPVolumeView *volumeView;
@property (strong, nonatomic) UISlider *volumeViewSlider;

@property (weak, nonatomic) IBOutlet UIView *alertUIView;
@property (weak, nonatomic) IBOutlet UIImageView *imgAlertBackground;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTitle;

@property (weak, nonatomic) IBOutlet UIView *sleepTimerUIView;
@property (weak, nonatomic) IBOutlet UIImageView *imgSleepTimerBackground;

@property (weak, nonatomic) IBOutlet UIButton *btnNone;
@property (weak, nonatomic) IBOutlet UIButton *btn5min;
@property (weak, nonatomic) IBOutlet UIButton *btn15min;
@property (weak, nonatomic) IBOutlet UIButton *btn30min;
@property (weak, nonatomic) IBOutlet UIButton *btn1hour;
@property (weak, nonatomic) IBOutlet UIButton *btn2hour;
@property (weak, nonatomic) IBOutlet UIButton *btn4hour;
@property (weak, nonatomic) IBOutlet UIButton *btn6hour;

//menu
@property (weak, nonatomic) IBOutlet UIView *menuUIView;
@property (weak, nonatomic) IBOutlet UIImageView *imgMenuBackground;

//Portrait Contollers
@property (weak, nonatomic) IBOutlet UIView *landscapeUIView;

@property (weak, nonatomic) IBOutlet UILabel *lblStationName01;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress01;
@property (weak, nonatomic) IBOutlet UIImageView *imgFavorite01;
@property (weak, nonatomic) IBOutlet UIImageView *imgAlarm01;
@property (weak, nonatomic) IBOutlet UILabel *lblAarmText01;
@property (weak, nonatomic) IBOutlet UILabel *lblVolume01;
@property (weak, nonatomic) IBOutlet UIButton *btnSoundOnOff01;

@property (weak, nonatomic) IBOutlet UIImageView *imgPlayBackground01;

@property (weak, nonatomic) IBOutlet UIButton *btnPlay01;

@property (weak, nonatomic) IBOutlet UIButton *btn_InBackground01;
@property (weak, nonatomic) IBOutlet UIButton *btnAddToFav01;
@property (weak, nonatomic) IBOutlet UIButton *btnShareButton01;
@property (weak, nonatomic) IBOutlet UIButton *btnSleepTimerButton01;
@property (weak, nonatomic) IBOutlet UIButton *btnRateButton01;

@property (weak, nonatomic) IBOutlet UIView *volumeUIView01;
@property (weak, nonatomic) IBOutlet MPVolumeView *volumeView01;
@property (strong, nonatomic) UISlider *volumeViewSlider01;

@property (weak, nonatomic) IBOutlet UIView *alertUIView01;
@property (weak, nonatomic) IBOutlet UIImageView *imgAlertBackground01;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTitle01;

@property (weak, nonatomic) IBOutlet UIView *sleepTimerUIView01;
@property (weak, nonatomic) IBOutlet UIImageView *imgSleepTimerBackground01;

@property (weak, nonatomic) IBOutlet UIButton *btnNone01;
@property (weak, nonatomic) IBOutlet UIButton *btn5min01;
@property (weak, nonatomic) IBOutlet UIButton *btn15min01;
@property (weak, nonatomic) IBOutlet UIButton *btn30min01;
@property (weak, nonatomic) IBOutlet UIButton *btn1hour01;
@property (weak, nonatomic) IBOutlet UIButton *btn2hour01;
@property (weak, nonatomic) IBOutlet UIButton *btn4hour01;
@property (weak, nonatomic) IBOutlet UIButton *btn6hour01;

//menu
@property (weak, nonatomic) IBOutlet UIView *menuUIView01;
@property (weak, nonatomic) IBOutlet UIImageView *imgMenuBackground01;


- (IBAction)pressSoundOnOff:(id)sender;

- (IBAction)pressBackToListButton:(id)sender;
- (IBAction)pressOptionButton:(id)sender;
- (IBAction)pressShortcutButton:(id)sender;
- (IBAction)pressPrevButton:(id)sender;
- (IBAction)pressNextButton:(id)sender;
- (IBAction)pressPlayButton:(id)sender;

- (IBAction)pressInBackgroundButton:(id)sender;
- (IBAction)pressSleepTimerButton:(id)sender;
- (IBAction)pressShareButton:(id)sender;
- (IBAction)pressRateButton:(id)sender;
- (IBAction)pressAddToFavButton:(id)sender;

- (IBAction)pressMenuHomeButton:(id)sender;
- (IBAction)pressMenuFavoriteButton:(id)sender;
- (IBAction)pressMenuDisclaimerButton:(id)sender;
- (IBAction)pressMenuSubmitButton:(id)sender;
- (IBAction)pressMenuRuninBackground:(id)sender;
- (IBAction)pressMenuCloseButton:(id)sender;

@end
