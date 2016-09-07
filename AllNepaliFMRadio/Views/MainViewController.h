//
//  MainViewController.h
//  All Nepali FM Radio
//
//  Created by Ireneo Decano on 17/3/15.
//  Copyright (c) 2015 Ireneo Decano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "ASIDataCompressor.h"
#import "AppDelegate.h"
#import "JSON.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import "GAITrackedViewController.h"

@interface MainViewController : GAITrackedViewController <ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) GADBannerView *bannerView;
@property (strong, nonatomic) NSString *screenName;

@property (strong, nonatomic) ASIFormDataRequest    *request;

@property (weak, nonatomic) IBOutlet UIView *portraitUIView;

@property (weak, nonatomic) IBOutlet UIView *navigationUIView;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnOption;

@property (weak, nonatomic) IBOutlet UIView *listUIView;
@property (weak, nonatomic) IBOutlet UIImageView *imgListBackground;
@property (weak, nonatomic) IBOutlet UIImageView *imgTableBackground;
@property (weak, nonatomic) IBOutlet UIImageView *imgScrollBarBackground;
@property (weak, nonatomic) IBOutlet UIImageView *imgScrollIndicator;
@property (weak, nonatomic) IBOutlet UITableView *radioTableView;

@property (weak, nonatomic) IBOutlet UIView *searchUIView;
@property (weak, nonatomic) IBOutlet UIImageView *imgSearchBackground;
@property (weak, nonatomic) IBOutlet UITextField *txtSearchItem;

@property (weak, nonatomic) IBOutlet UIView *menuUIView;
@property (weak, nonatomic) IBOutlet UIImageView *imgMenuBackground;


@property (weak, nonatomic) IBOutlet UIView *landscapeUIView;

@property (weak, nonatomic) IBOutlet UIView *navigationUIView01;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch01;
@property (weak, nonatomic) IBOutlet UIButton *btnOption01;

@property (weak, nonatomic) IBOutlet UIView *listUIView01;
@property (weak, nonatomic) IBOutlet UIImageView *imgListBackground01;
@property (weak, nonatomic) IBOutlet UIImageView *imgTableBackground01;
@property (weak, nonatomic) IBOutlet UIImageView *imgScrollBarBackground01;
@property (weak, nonatomic) IBOutlet UIImageView *imgScrollIndicator01;
@property (weak, nonatomic) IBOutlet UITableView *radioTableView01;

@property (weak, nonatomic) IBOutlet UIView *searchUIView01;
@property (weak, nonatomic) IBOutlet UIImageView *imgSearchBackground01;
@property (weak, nonatomic) IBOutlet UITextField *txtSearchItem01;

@property (weak, nonatomic) IBOutlet UIView *menuUIView01;
@property (weak, nonatomic) IBOutlet UIImageView *imgMenuBackground01;

- (IBAction)pressMenuHomeButton:(id)sender;
- (IBAction)pressMenuFavoriteButton:(id)sender;
- (IBAction)pressMenuDisclaimerButton:(id)sender;
- (IBAction)pressMenuSubmitButton:(id)sender;
- (IBAction)pressMenuRuninBackgroundButton:(id)sender;
- (IBAction)pressMenuCloseButton:(id)sender;


- (IBAction)pressSearchButton:(id)sender;
- (IBAction)pressOptionButton:(id)sender;

@end
