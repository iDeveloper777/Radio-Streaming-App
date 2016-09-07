//
//  DisclaimerViewController.h
//  All Nepali FM Radio
//
//  Created by Ireneo Decano on 20/3/15.
//  Copyright (c) 2015 Ireneo Decano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "GAITrackedViewController.h"

@interface DisclaimerViewController : UIViewController

@property (strong, nonatomic) GADBannerView *bannerView;
@property (strong, nonatomic) NSString *screenName;

@property (weak, nonatomic) IBOutlet UIView *portraitUIView;

@property (weak, nonatomic) IBOutlet UIView *navigationUIView;
@property (weak, nonatomic) IBOutlet UIButton *btnBackToList;
@property (weak, nonatomic) IBOutlet UIButton *btnOption;

@property (weak, nonatomic) IBOutlet UIView *menuUIView;
@property (weak, nonatomic) IBOutlet UIImageView *imgMenuBackground;

@property (weak, nonatomic) IBOutlet UIView *landscapeUIView;

@property (weak, nonatomic) IBOutlet UIView *navigationUIView01;
@property (weak, nonatomic) IBOutlet UIButton *btnBackToList01;
@property (weak, nonatomic) IBOutlet UIButton *btnOption01;

@property (weak, nonatomic) IBOutlet UIView *menuUIView01;
@property (weak, nonatomic) IBOutlet UIImageView *imgMenuBackground01;


- (IBAction)pressOKButton:(id)sender;

- (IBAction)pressBackToListButton:(id)sender;
- (IBAction)pressOptionButton:(id)sender;

- (IBAction)pressMenuHomeButton:(id)sender;
- (IBAction)pressMenuFavoriteButton:(id)sender;
- (IBAction)pressMenuDisclaimerButton:(id)sender;
- (IBAction)pressMenuSubmitButton:(id)sender;
- (IBAction)pressMenuRuninBackgroundButton:(id)sender;
- (IBAction)pressMenuCloseButton:(id)sender;


@end
