//
//  SubmitViewController.h
//  All Nepali FM Radio
//
//  Created by Ireneo Decano on 23/3/15.
//  Copyright (c) 2015 Ireneo Decano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "GAITrackedViewController.h"

@interface SubmitViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) GADBannerView *bannerView;
@property (strong, nonatomic) NSString *screenName;

@property (weak, nonatomic) IBOutlet UIView *navigationUIView;
@property (weak, nonatomic) IBOutlet UIButton *btnBackToList;
@property (weak, nonatomic) IBOutlet UIButton *btnOption;

- (IBAction)pressBackToListButton:(id)sender;
- (IBAction)pressOptionButton:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtURL;
@property (weak, nonatomic) IBOutlet UITextField *txtWebsite;

- (IBAction)pressSubmitButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *menuUIView;
@property (weak, nonatomic) IBOutlet UIImageView *imgMenuBackground;

- (IBAction)pressMenuHomeButton:(id)sender;
- (IBAction)pressMenuFavoriteButton:(id)sender;
- (IBAction)pressMenuDisclaimerButton:(id)sender;
- (IBAction)pressMenuSubmitButton:(id)sender;
- (IBAction)pressMenuRuninBackgroundButton:(id)sender;
- (IBAction)pressMenuCloseButton:(id)sender;

@end
