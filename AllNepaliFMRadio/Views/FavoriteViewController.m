//
//  FavoriteViewController.m
//  All Nepali FM Radio
//
//  Created by Ireneo Decano on 19/3/15.
//  Copyright (c) 2015 Ireneo Decano. All rights reserved.
//

#import "FavoriteViewController.h"
#import "AppDelegate.h"
#import "RadioModel.h"
#import "PlaybackViewController.h"
#import "DisclaimerViewController.h"
#import "SubmitViewController.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#define MY_BANNER_UNIT_ID @"ca-app-pub-7672726291086615/6702441485"

@interface FavoriteViewController ()
{
    AppDelegate *appDelegate;
    
    NSMutableArray *radioArray;
    NSMutableArray *favoriteArray;
    NSMutableArray *originalArray;
    NSMutableArray *favoriteIDArray;
    
    NSIndexPath *beforeSelectedIndexPath;
    float indicatorCenterHeight;
    float indicatorCenterHeight01;
    
    int isSearch;
    int currentListViewY;
    int currentListViewY01;
    int nIndicatorRate;
    int deleteRadioIndex;
    int alertFlag;
    
    int isPortrait;
    int isOption;
    
    NSString * kGAIScreenName;
    
    UITextField *tempTextField;
    
    int isShowAdmob_Portrait;
    int isShowAdmob_Landscape;

}
@end

@implementation FavoriteViewController
@synthesize appDelegate;
@synthesize bannerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [[UIApplication sharedApplication] delegate];
    nIndicatorRate = appDelegate.nIndicatorRate;
    
    // Set screen name.
    self.screenName = @"Favorite Screen";
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait){
        isPortrait = 0;
        self.portraitUIView.hidden = NO;
        self.landscapeUIView.hidden = YES;
    }else if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        isPortrait = 1;
        self.portraitUIView.hidden = YES;
        self.landscapeUIView.hidden = NO;
    }
    
    [self getRadioModels];
    [self setLayout];
    
    isShowAdmob_Portrait = 0;
    isShowAdmob_Landscape = 0;
    [self showAdMob];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Favorite Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void) getRadioModels{
    appDelegate = [[UIApplication sharedApplication] delegate];
    originalArray = appDelegate.originalArry;
    favoriteArray = appDelegate.favoriteArray;
    favoriteIDArray = appDelegate.favoriteIDArray;
    
    radioArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < favoriteArray.count; i++){
        [radioArray addObject:[favoriteArray objectAtIndex:i]];
    }
}

- (void) setLayout{
    self.searchUIView.hidden = YES;
    self.searchUIView01.hidden = YES;
    
    self.menuUIView.hidden = YES;
    self.menuUIView01.hidden = YES;
    
    [self.btnSearch setImage:[UIImage imageNamed:@"button_search_down.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
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
    currentListViewY = self.listUIView.frame.origin.y;
    currentListViewY01 = self.listUIView01.frame.origin.y;
    
    [self.txtSearchItem addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventEditingDidEnd];
    [self.txtSearchItem addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventEditingChanged];
    [self.txtSearchItem addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventTouchDown];
    
    [self.txtSearchItem01 addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventEditingDidEnd];
    [self.txtSearchItem01 addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventEditingChanged];
    [self.txtSearchItem01 addTarget:self action:@selector(beginEditingTextbox:) forControlEvents:UIControlEventTouchDown];
    
    [self.radioTableView reloadData];
    [self.radioTableView01 reloadData];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    singleTap.numberOfTapsRequired = 1;
    [self.menuUIView setUserInteractionEnabled:YES];
    [self.menuUIView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *singleTap01 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    singleTap01.numberOfTapsRequired = 1;
    [self.menuUIView01 setUserInteractionEnabled:YES];
    [self.menuUIView01 addGestureRecognizer:singleTap01];

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.5; //seconds
    lpgr.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.radioTableView addGestureRecognizer:lpgr];
    
    UILongPressGestureRecognizer *lpgr01 = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.5; //seconds
    lpgr.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.radioTableView addGestureRecognizer:lpgr01];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    [self.txtSearchItem resignFirstResponder];
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
    for (radioModel in favoriteArray)
    {
        [radioArray addObject:radioModel];
    }
    
    if ([self.txtSearchItem.text isEqualToString:@""])
    {
        [self.radioTableView reloadData];
        [self.radioTableView01 reloadData];
        return TRUE;
    }
    
//    NSLog(self.txtSearchItem.text);
    int i = 0;
    
    while (i < radioArray.count) {
        radioModel = (RadioModel *)[radioArray objectAtIndex:i];
        
        NSString *lowerString = [radioModel.station_name lowercaseString];
        NSString *compareLowerString = [self.txtSearchItem.text lowercaseString];
        
//        NSLog(radioModel.station_name);
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

- (void) customAlertView:(CustomAlert *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertFlag == 1){
        if (buttonIndex == 0)
            [self deleteRadioModel];
        else
            return;
    }else{
        if (buttonIndex == 0)
            exit(1);
        else
            [self hideMenu];
    }
}

- (void) deleteRadioModel{
    [appDelegate.favoriteArray removeObjectAtIndex:deleteRadioIndex];
    [appDelegate.favoriteIDArray removeObjectAtIndex:deleteRadioIndex];
    [radioArray removeObjectAtIndex:deleteRadioIndex];
    
    [self.radioTableView reloadData];
    [self.radioTableView01 reloadData];
}

#pragma UITableView
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (isPortrait == 0){
        CGPoint p = [gestureRecognizer locationInView:self.radioTableView];
        
        NSIndexPath *indexPath = [self.radioTableView indexPathForRowAtPoint:p];
        if (indexPath == nil) {
            NSLog(@"long press on table view but not on a row");
        } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            NSLog(@"long press on table view at row %d", (int)indexPath.row);
            
            deleteRadioIndex = (int)indexPath.row;
            alertFlag = 1;
            
            RadioModel *currentModel = [radioArray objectAtIndex:indexPath.row];
            NSString *strMessage = [NSString stringWithFormat:@"Do you really want to delete “%@” from your favorites?", currentModel.station_name];
            CustomAlert *alert = [[CustomAlert alloc] initWithTitle:@"Delete from Favorites" message:strMessage delegate:self  cancelButtonTitle:@"Yes" otherButtonTitle:@"No"];
            
            [alert showInView:self.view];
            
        } else {
            NSLog(@"gestureRecognizer.state = %d", (int)gestureRecognizer.state);
        }
    }else{
        CGPoint p = [gestureRecognizer locationInView:self.radioTableView01];
        
        NSIndexPath *indexPath = [self.radioTableView01 indexPathForRowAtPoint:p];
        if (indexPath == nil) {
            NSLog(@"long press on table view but not on a row");
        } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            NSLog(@"long press on table view at row %d", (int)indexPath.row);
            
            deleteRadioIndex = (int)indexPath.row;
            alertFlag = 1;
            
            RadioModel *currentModel = [radioArray objectAtIndex:indexPath.row];
            NSString *strMessage = [NSString stringWithFormat:@"Do you really want to delete “%@” from your favorites?", currentModel.station_name];
            CustomAlert *alert = [[CustomAlert alloc] initWithTitle:@"Delete from Favorites" message:strMessage delegate:self  cancelButtonTitle:@"Yes" otherButtonTitle:@"No"];
            
            [alert showInView:self.view];
            
        } else {
            NSLog(@"gestureRecognizer.state = %d", (int)gestureRecognizer.state);
        }

    }
}

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
    
    int height = cell.bounds.size.height;
    
    if (tableView.tag == 0){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.radioTableView.bounds.size.width, cell.bounds.size.height - 1)];
        
        imageView.image = [UIImage imageNamed:@"img_cellBackground_normal.png"];
        imageView.tag = 0;
        [cell.contentView addSubview:imageView];
        
        RadioModel *radioModel = [radioArray objectAtIndex:indexPath.row];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0 , cell.bounds.size.width - height - 10, cell.bounds.size.height)];
//        titleLabel.textAlignment = UITextAlignmentLeft;
        titleLabel.text = radioModel.station_name;
        titleLabel.font =[UIFont fontWithName:@"Helvetica" size:16.0];
        titleLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:138.0/255.0 blue:0 alpha:1];
        [cell.contentView addSubview:titleLabel];
        
        UIImageView *imageIconView = [[UIImageView alloc] initWithFrame:CGRectMake(self.radioTableView.bounds.size.width - height - 5 , 5, cell.bounds.size.height - 10, cell.bounds.size.height - 10)];
        
        imageIconView.image = [UIImage imageNamed:@"img_favorite_normal.png"];
        imageIconView.tag = 1;
        [cell.contentView addSubview:imageIconView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else{
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.radioTableView01.bounds.size.width, cell.bounds.size.height - 1)];
        
        imageView.image = [UIImage imageNamed:@"img_cellBackground_normal.png"];
        imageView.tag = 0;
        [cell.contentView addSubview:imageView];
        
        RadioModel *radioModel = [radioArray objectAtIndex:indexPath.row];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0 , cell.bounds.size.width - height - 10, cell.bounds.size.height)];
//        titleLabel.textAlignment = UITextAlignmentLeft;
        titleLabel.text = radioModel.station_name;
        titleLabel.font =[UIFont fontWithName:@"Helvetica" size:16.0];
        titleLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:138.0/255.0 blue:0 alpha:1];
        [cell.contentView addSubview:titleLabel];
        
        UIImageView *imageIconView = [[UIImageView alloc] initWithFrame:CGRectMake(self.radioTableView01.bounds.size.width - height - 5 , 5, cell.bounds.size.height - 10, cell.bounds.size.height - 10)];
        
        imageIconView.image = [UIImage imageNamed:@"img_favorite_normal.png"];
        imageIconView.tag = 1;
        [cell.contentView addSubview:imageIconView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //change background images of last seleced cell
    if (beforeSelectedIndexPath != nil){
        UITableViewCell *cell = [self.radioTableView cellForRowAtIndexPath:beforeSelectedIndexPath];
        
        for (UIView *subView in cell.contentView.subviews){
            if ([subView isKindOfClass:[UIImageView class]]){
                UIImageView *imageView = (UIImageView *)subView;
                if (imageView.tag == 0)
                    imageView.image = [UIImage imageNamed:@"img_cellBackground_normal.png"];
                else
                    imageView.image = [UIImage imageNamed:@"img_favorite_normal.png"];
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
            if (imageView.tag == 0)
                imageView.image = [UIImage imageNamed:@"img_cellBackground_down.png"];
            else
                imageView.image = [UIImage imageNamed:@"img_favorite_down.png"];
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
                if (imageView.tag == 0)
                    imageView.image = [UIImage imageNamed:@"img_cellBackground_normal.png"];
                else
                    imageView.image = [UIImage imageNamed:@"img_favorite_normal.png"];
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
            if (imageView.tag == 0)
                imageView.image = [UIImage imageNamed:@"img_cellBackground_down.png"];
            else
                imageView.image = [UIImage imageNamed:@"img_favorite_down.png"];
        }
        
        if ([subView isKindOfClass:[UILabel class]]){
            UILabel *label = (UILabel *)subView;
            label.textColor = [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1];
        }
    }

    beforeSelectedIndexPath = indexPath;
    
    PlaybackViewController *playVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playbackView"];
    playVC.currentRadioModel = (RadioModel *)[radioArray objectAtIndex:indexPath.row];
    playVC.isOriginalFavorite = 1;
    
    [self.navigationController pushViewController:playVC animated:TRUE];
    
}

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

///--------Portrait / Landscape End--------

- (IBAction)pressMenuHomeButton:(id)sender {
    [self hideMenu];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)pressMenuFavoriteButton:(id)sender {
    [self hideMenu];
};

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
}

- (IBAction)pressMenuCloseButton:(id)sender {
    alertFlag = 0;
    CustomAlert *alert = [[CustomAlert alloc] initWithTitle:@"Notification" message:@"Are you going to close app?" delegate:self  cancelButtonTitle:@"OK" otherButtonTitle:@"Cancel"];
    
    [alert showInView:self.view];
}

@end
