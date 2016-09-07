//
//  MainViewController.m
//  All Nepali FM Radio
//
//  Created by Ireneo Decano on 17/3/15.
//  Copyright (c) 2015 Ireneo Decano. All rights reserved.
//

#import "MainViewController.h"
//#import "ProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "RadioModel.h"
#import "AppDelegate.h"
#import "PlaybackViewController.h"
#import "CustomAlert.h"
#import "MBProgressHUD.h"

#import "FavoriteViewController.h"
#import "DisclaimerViewController.h"
#import "SubmitViewController.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#define jsonURL  @"aHR0cDovL2FsbG5lcGFsaWZtcmFkaW8uY29tLm5wL2FuZHJvaWQvanNvbl9yYWRpby5waHA/dHlwZT1qc29u"
#define MY_BANNER_UNIT_ID @"ca-app-pub-7672726291086615/6702441485"

@interface MainViewController ()
{
    NSMutableArray *radioArray;
    NSMutableArray *originalArray;
    
    NSIndexPath *beforeSelectedIndexPath;
    float indicatorCenterHeight;
    float indicatorCenterHeight01;
    
    int isSearch;
    int isOption;
    int currentListViewY;
    int currentListViewY01;
    int nIndicatorRate;
    
    int isPortrait;
    
    NSMutableData *webData;
    NSString * kGAIScreenName;
    
    UITextField *tempTextField;
    
    MBProgressHUD *HUD;
    
    int isShowAdmob_Portrait;
    int isShowAdmob_Landscape;
}

@end

@implementation MainViewController
@synthesize appDelegate;
@synthesize bannerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    nIndicatorRate = appDelegate.nIndicatorRate;
    
    tempTextField = nil;
    // Set screen name.
    self.screenName = @"Main Screen";
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait){
        isPortrait = 0;
        self.portraitUIView.hidden = NO;
        self.landscapeUIView.hidden = YES;
    }else if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        isPortrait = 1;
        self.portraitUIView.hidden = YES;
        self.landscapeUIView.hidden = NO;
    }
    
    [self loadJSONData];
    [self setLayout];
    
    isShowAdmob_Portrait = 0;
    isShowAdmob_Landscape = 0;
    [self showAdMob];
    
}

//- (void) viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    
//    id <GAITracker>tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:@"Home Screen"];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Main Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [GAI sharedInstance].dispatchInterval = 0;
}

- (void) setLayout{
    self.searchUIView.hidden = YES;
    self.searchUIView01.hidden = YES;
    
    self.menuUIView.hidden = YES;
    self.menuUIView01.hidden = YES;
    
    self.radioTableView.backgroundColor = [UIColor clearColor];
    self.radioTableView.separatorStyle = NO;
    self.radioTableView.showsVerticalScrollIndicator = NO;
    
    self.radioTableView01.backgroundColor = [UIColor clearColor];
    self.radioTableView01.separatorStyle = NO;
    self.radioTableView01.showsVerticalScrollIndicator = NO;
    
    beforeSelectedIndexPath = nil;
    
    self.imgScrollIndicator.center = CGPointMake(self.imgScrollBarBackground.center.x, self.imgScrollIndicator.center.y);
    self.imgScrollIndicator01.center = CGPointMake(self.imgScrollBarBackground01.center.x, self.imgScrollIndicator01.center.y);
    
    isSearch = 0;
    isOption = 0;
    currentListViewY = self.listUIView.frame.origin.y;
    currentListViewY01 = self.listUIView01.frame.origin.y;
    
    [self.txtSearchItem addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventEditingDidEnd];
    [self.txtSearchItem addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventEditingChanged];
    [self.txtSearchItem addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventTouchDown];
    
    [self.txtSearchItem01 addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventEditingDidEnd];
    [self.txtSearchItem01 addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventEditingChanged];
    [self.txtSearchItem01 addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventTouchDown];
    
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
    completion:^(BOOL finished){ }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadJSONData{
    [self showHUD:@"Please wait loading FM Radio List..."];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
//    NSData *plainData = [jsonURL dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
//    NSLog(@"%@", base64String);
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:jsonURL options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", decodedString);
    
    self.request =[[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:decodedString]];
    self.request.delegate = self;

    [self.request addRequestHeader:@"Content-Type" value:@"application/json"];
    [self.request addRequestHeader:@"Accept" value:@"application/json"];
    [self.request setRequestMethod:@"GET"];
    [self.request startAsynchronous];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    radioArray = [[NSMutableArray alloc] init];
    originalArray = [[NSMutableArray alloc] init];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    NSDictionary *tempData = [[NSDictionary alloc] init];
    tempData = [json objectForKey:@"Radio_Json"];
    
    NSDictionary * tData;
    for (tData in tempData) {
        RadioModel *radioModel = [[RadioModel alloc] initWithJSONData:tData];
        
        [radioArray addObject:radioModel];
    }
    
    RadioModel *radioModel;
    for (radioModel in radioArray)
    {
        [originalArray addObject:radioModel];
    }
    
    if (isPortrait == 0)
        [self.radioTableView reloadData];
    else
        [self.radioTableView01 reloadData];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (radioModel in radioArray)
    {
        [tempArray addObject:radioModel];
    }
    appDelegate.originalArry = tempArray;

    [self hideHUD];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    [self getUserDefaults];
}

- (void) getUserDefaults{
    appDelegate.favoriteIDArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteIDArray"];
    
    RadioModel *rModel;
    NSMutableArray *favoriteArray = [[NSMutableArray alloc] init];
    for (int i=0; i<appDelegate.favoriteIDArray.count; i++)
    {
        for (rModel in originalArray){
            if ([rModel.id isEqualToString:[appDelegate.favoriteIDArray objectAtIndex:i]])
                [favoriteArray addObject:rModel];
        }
    }
    appDelegate.favoriteArray = favoriteArray;
}

- (void) requestFailed:(ASIHTTPRequest *)request{
    CustomAlert *alert = [[CustomAlert alloc] initWithTitle:@"Error" message:@"Server connection error!" delegate:self cancelButtonTitle:@"OK" otherButtonTitle:@""];
    
    [alert showInView:self.view];
    
    [self hideHUD];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pressMenuHomeButton:(id)sender {
    [self hideMenu];
}

- (IBAction)pressMenuFavoriteButton:(id)sender {
    [self hideMenu];
    
    FavoriteViewController *favoriteViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"favoriteView"];
    
    [self.navigationController pushViewController:favoriteViewController animated:TRUE];
}

- (IBAction)pressMenuDisclaimerButton:(id)sender {
    [self hideMenu];
    
    DisclaimerViewController *disclaimerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"disclaimerView"];
    
    [self.navigationController pushViewController:disclaimerViewController animated:TRUE];
}

- (IBAction)pressMenuSubmitButton:(id)sender {
    [self hideMenu];
    
    SubmitViewController *submitViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"submitView"];
    
    [self.navigationController pushViewController:submitViewController animated:TRUE];
}

- (IBAction)pressMenuRuninBackgroundButton:(id)sender {
    exit(0);
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

- (IBAction)pressSearchButton:(id)sender {
    if (isSearch == 0){
        isSearch = 1;
        
        self.searchUIView.hidden = NO;
            
        int searchViewHeight = self.searchUIView.bounds.size.height;
        CGRect rect = self.listUIView.frame;
        rect.origin.y += searchViewHeight;
        rect.size.height -= searchViewHeight;
        [self.listUIView setFrame:rect];

        
        self.searchUIView01.hidden = NO;
            
        searchViewHeight = self.searchUIView01.bounds.size.height;
        rect = self.listUIView01.frame;
        rect.origin.y += searchViewHeight;
        rect.size.height -= searchViewHeight;
        [self.listUIView01 setFrame:rect];
    }
    else{
        isSearch = 0;
        
        self.searchUIView.hidden = YES;
            
        int searchViewHeight = self.searchUIView.bounds.size.height;
        CGRect rect = self.listUIView.frame;
        rect.origin.y -= searchViewHeight;
        rect.size.height += searchViewHeight;
        [self.listUIView setFrame:rect];
        
        
        self.searchUIView01.hidden = YES;
            
        searchViewHeight = self.searchUIView01.bounds.size.height;
        rect = self.listUIView01.frame;
        rect.origin.y -= searchViewHeight;
        rect.size.height += searchViewHeight;
        [self.listUIView01 setFrame:rect];
    }
    
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (tempTextField != nil)
        [tempTextField resignFirstResponder];
}

- (BOOL) beginEditingTextbox:(UITextField *)textField{
    if (isPortrait == 0){
        tempTextField = self.txtSearchItem;
        self.txtSearchItem01.text = self.txtSearchItem.text;
    }else{
        tempTextField = self.txtSearchItem01;
        self.txtSearchItem.text = self.txtSearchItem01.text;
    }
    radioArray = [[NSMutableArray alloc] init];
    
    RadioModel *radioModel;
    for (radioModel in originalArray){
        [radioArray addObject:radioModel];
    }
    
    if ([self.txtSearchItem.text isEqualToString:@""]){
        [self.radioTableView reloadData];
        [self.radioTableView01 reloadData];
        return TRUE;
    }
    
//    NSLog(self.txtSearchItem.text);
    int i = 0;
    
    while (i < radioArray.count) {
        radioModel = (RadioModel *)[radioArray objectAtIndex:i];
        
        NSString *lowerString = [radioModel.station_name lowercaseString];
        
        NSString *compareLowerString;
        compareLowerString = [self.txtSearchItem01.text lowercaseString];
        
//        NSLog([NSString stringWithFormat:@"%@", radioModel.station_name]);
        if ([lowerString rangeOfString:compareLowerString].location == NSNotFound) {
            [radioArray removeObjectAtIndex:i];
        }
        else
            i++;
    }
    
    [self.radioTableView reloadData];
    [self.radioTableView01 reloadData];
    
    return TRUE;
}

#pragma UITableView

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [radioArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    if (tableView.tag == 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.radioTableView.bounds.size.width, cell.bounds.size.height - 1)];
        
        imageView.image = [UIImage imageNamed:@"img_cellBackground_normal.png"];
        [cell.contentView addSubview:imageView];
        
        RadioModel *radioModel = [radioArray objectAtIndex:indexPath.row];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0 , cell.bounds.size.width, cell.bounds.size.height)];
//        titleLabel.textAlignment = UITextAlignmentLeft;
        titleLabel.text = radioModel.station_name;
        titleLabel.font =[UIFont fontWithName:@"Helvetica" size:16.0];
        titleLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:138.0/255.0 blue:0 alpha:1];
        [cell.contentView addSubview:titleLabel];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else{
        int nWidth = 0;
        if (self.view.bounds.size.height > self.view.bounds.size.width)
            nWidth = self.view.bounds.size.height;
        else
            nWidth = self.view.bounds.size.width;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, nWidth, cell.bounds.size.height - 1)];
        
        imageView.image = [UIImage imageNamed:@"img_cellBackground_normal.png"];
        [cell.contentView addSubview:imageView];
        
        RadioModel *radioModel = [radioArray objectAtIndex:indexPath.row];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0 , cell.bounds.size.width, cell.bounds.size.height)];
//        titleLabel.textAlignment = UITextAlignmentLeft;
        titleLabel.text = radioModel.station_name;
        titleLabel.font =[UIFont fontWithName:@"Helvetica" size:16.0];
        titleLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:138.0/255.0 blue:0 alpha:1];
        [cell.contentView addSubview:titleLabel];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //change background images of last seleced cell
    //Portrait TableView
    if (beforeSelectedIndexPath != nil){
        UITableViewCell *cell = [self.radioTableView cellForRowAtIndexPath:beforeSelectedIndexPath];
        
        for (UIView *subView in cell.contentView.subviews){
            if ([subView isKindOfClass:[UIImageView class]]){
                UIImageView *imageView = (UIImageView *)subView;
                imageView.image = [UIImage imageNamed:@"img_cellBackground_normal.png"];
            }
            
            if ([subView isKindOfClass:[UILabel class]]){
                UILabel *label = (UILabel *)subView;
                label.textColor = [UIColor colorWithRed:255.0/255.0 green:138.0/255.0 blue:0 alpha:1];
            }
        }
    }
    
    UITableViewCell *cell = [self.radioTableView cellForRowAtIndexPath:indexPath];
    for (UIView *subView in cell.contentView.subviews){
        if ([subView isKindOfClass:[UIImageView class]]){
            UIImageView *imageView = (UIImageView *)subView;
            imageView.image = [UIImage imageNamed:@"img_cellBackground_down.png"];
        }
        
        if ([subView isKindOfClass:[UILabel class]]){
            UILabel *label = (UILabel *)subView;
            label.textColor = [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1];
        }
    }
    
    //Landscape Table View
    //change background images of last seleced cell
    if (beforeSelectedIndexPath != nil){
        UITableViewCell *cell = [self.radioTableView01 cellForRowAtIndexPath:beforeSelectedIndexPath];
        
        for (UIView *subView in cell.contentView.subviews){
            if ([subView isKindOfClass:[UIImageView class]]){
                UIImageView *imageView = (UIImageView *)subView;
                imageView.image = [UIImage imageNamed:@"img_cellBackground_normal.png"];
            }
            
            if ([subView isKindOfClass:[UILabel class]]){
                UILabel *label = (UILabel *)subView;
                label.textColor = [UIColor colorWithRed:255.0/255.0 green:138.0/255.0 blue:0 alpha:1];
            }
        }
    }
    
    cell = [self.radioTableView01 cellForRowAtIndexPath:indexPath];
    for (UIView *subView in cell.contentView.subviews){
        if ([subView isKindOfClass:[UIImageView class]]){
            UIImageView *imageView = (UIImageView *)subView;
            imageView.image = [UIImage imageNamed:@"img_cellBackground_down.png"];
        }
        
        if ([subView isKindOfClass:[UILabel class]]){
            UILabel *label = (UILabel *)subView;
            label.textColor = [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1];
        }
    }

    
    beforeSelectedIndexPath = indexPath;
    
    PlaybackViewController *playVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playbackView"];
    playVC.currentRadioModel = (RadioModel *)[radioArray objectAtIndex:indexPath.row];
    playVC.isOriginalFavorite = 0;
    
    [self.navigationController pushViewController:playVC animated:TRUE];

}

#pragma mark -
#pragma mark Connection management

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength: 0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"ERROR with theConenction : %@",[error localizedDescription]);
    
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *theResponse=[[NSString alloc] initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
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

#pragma scrollView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//        NSLog(@"Will begin dragging");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isPortrait == 0){
        [self.radioTableView01 setContentOffset:self.radioTableView.contentOffset];
    }
    else{
        [self.radioTableView setContentOffset:self.radioTableView01.contentOffset];
    }
    indicatorCenterHeight = self.imgScrollBarBackground.frame.origin.y + self.imgScrollIndicator.bounds.size.height/2;
    indicatorCenterHeight01 = self.imgScrollBarBackground01.frame.origin.y + self.imgScrollIndicator01.bounds.size.height/2;
    
    if (isPortrait == 0){
        if (self.radioTableView.contentOffset.y > 0)
            self.imgScrollIndicator.center = CGPointMake(self.imgScrollBarBackground.center.x, indicatorCenterHeight + (self.imgScrollBarBackground.bounds.size.height - self.imgScrollIndicator.bounds.size.height/2) / ((float)self.radioTableView.contentSize.height / (float)self.radioTableView.contentOffset.y) * nIndicatorRate);
    }else{
        if (self.radioTableView.contentOffset.y > 0)
            self.imgScrollIndicator01.center = CGPointMake(self.imgScrollBarBackground01.center.x, indicatorCenterHeight01 + (self.imgScrollBarBackground01.bounds.size.height - self.imgScrollIndicator01.bounds.size.height/2) / ((float)self.radioTableView01.contentSize.height / (float)self.radioTableView01.contentOffset.y) * nIndicatorRate);
    }

}


//-------------
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSNumber *value = [NSNumber numberWithInt:self.interfaceOrientation];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [self shouldAutorotateToInterfaceOrientation:self.interfaceOrientation];
}

//----Portrait / Landscape-----
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//    int x1 = self.imgScrollBarBackground.center.x;
//    int x2 = self.imgScrollBarBackground01.center.x;
    
    indicatorCenterHeight = self.imgScrollBarBackground.frame.origin.y + self.imgScrollIndicator.bounds.size.height/2;
    indicatorCenterHeight01 = self.imgScrollBarBackground01.frame.origin.y + self.imgScrollIndicator01.bounds.size.height/2;
    
    if (isPortrait == 0){
        if (self.radioTableView.contentOffset.y > 0)
            self.imgScrollIndicator.center = CGPointMake(self.imgScrollBarBackground.center.x, indicatorCenterHeight + (self.imgScrollBarBackground.bounds.size.height - self.imgScrollIndicator.bounds.size.height/2) / ((float)self.radioTableView.contentSize.height / (float)self.radioTableView.contentOffset.y) * nIndicatorRate);
    }else{
        if (self.radioTableView.contentOffset.y > 0)
            self.imgScrollIndicator01.center = CGPointMake(self.imgScrollBarBackground01.center.x, indicatorCenterHeight01 + (self.imgScrollBarBackground01.bounds.size.height - self.imgScrollIndicator01.bounds.size.height/2) / ((float)self.radioTableView01.contentSize.height / (float)self.radioTableView01.contentOffset.y) * nIndicatorRate);
    }}

- (void)orientationChanged:(NSNotification *)note
{
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
        self.portraitUIView.hidden = YES;
        self.landscapeUIView.hidden = NO;
        indicatorCenterHeight01 = self.imgScrollIndicator01.center.y;
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
