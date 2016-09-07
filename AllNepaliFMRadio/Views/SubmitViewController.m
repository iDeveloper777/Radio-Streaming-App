//
//  SubmitViewController.m
//  All Nepali FM Radio
//
//  Created by Ireneo Decano on 23/3/15.
//  Copyright (c) 2015 Ireneo Decano. All rights reserved.
//

#import "SubmitViewController.h"
#import "FavoriteViewController.h"
#import "DisclaimerViewController.h"

#import "CustomAlert.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#define MY_BANNER_UNIT_ID @"ca-app-pub-7672726291086615/6702441485"

@interface SubmitViewController ()
{
    NSString * kGAIScreenName;
    
    UITextField *tempTextField;
}
@end

@implementation SubmitViewController
@synthesize bannerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tempTextField = nil;
    // Set screen name.
    self.screenName = @"Submit Screen";
    
    [self setLayout];
//    [self showAdMob];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Submit Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setLayout{
    self.menuUIView.hidden = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    singleTap.numberOfTapsRequired = 1;
    [self.menuUIView setUserInteractionEnabled:YES];
    [self.menuUIView addGestureRecognizer:singleTap];
    
//    [self.txtName addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventEditingDidBegin];
//    [self.txtAddress addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventEditingDidBegin];
//    [self.txtURL addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventEditingDidBegin];
//    [self.txtWebsite addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventEditingDidBegin];
}

- (void) showAdMob{
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        bannerView = [[GADBannerView alloc]
                      initWithFrame:CGRectMake((screenSize.size.width - GAD_SIZE_320x50.width) / 2, screenSize.size.height-GAD_SIZE_320x50.height, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
    else
        bannerView = [[GADBannerView alloc]
                      initWithFrame:CGRectMake((screenSize.size.width - GAD_SIZE_468x60
                                                .width) / 2, screenSize.size.height-GAD_SIZE_468x60.height, GAD_SIZE_468x60.width, GAD_SIZE_468x60.height)];
    bannerView.adUnitID = MY_BANNER_UNIT_ID;
    
    bannerView.rootViewController = self;
    [self.view addSubview:bannerView];
    
    [bannerView loadRequest:[GADRequest request]];
}

- (void) tapGesture: (UIGestureRecognizer *) gestureRecognizer{
    [self hideMenu];
}

- (void) hideMenu{
    [UIView animateWithDuration:1.0 delay:0.5 options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.menuUIView.hidden = YES;
    }
                     completion:^(BOOL finished){
                     }];
}

- (void) openMenu{
    [UIView animateWithDuration:1.0 delay:0.5 options: UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.menuUIView.hidden = NO;
    }
                     completion:^(BOOL finished){
                     }];
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (tempTextField != nil)
        [tempTextField resignFirstResponder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField{
    tempTextField = textField;
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressOptionButton:(id)sender {
    [self openMenu];
}

- (IBAction)pressSubmitButton:(id)sender {
}

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
    DisclaimerViewController *disclaimerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"disclaimerView"];
    [self.navigationController pushViewController:disclaimerViewController animated:TRUE];
}

- (IBAction)pressMenuSubmitButton:(id)sender {
    [self hideMenu];
}

- (IBAction)pressMenuRuninBackgroundButton:(id)sender {
}

- (IBAction)pressMenuCloseButton:(id)sender {
    CustomAlert *alert = [[CustomAlert alloc] initWithTitle:@"Notification" message:@"Are you going to close app?" delegate:self  cancelButtonTitle:@"OK" otherButtonTitle:@"Cancel"];
    
}

- (void) customAlertView:(CustomAlert *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0)
        exit(1);
    else
        [self hideMenu];
}
@end

