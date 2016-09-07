//
//  AppDelegate.h
//  All Nepali FM Radio
//
//  Created by Ireneo Decano on 17/3/15.
//  Copyright (c) 2015 Ireneo Decano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioModel.h"
#import "GAI.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class AudioStreamer;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, strong) id<GAITracker> tracker;

@property (strong, nonatomic) NSMutableArray *originalArry;
@property (nonatomic, strong) AudioStreamer *streamer;
@property (strong, nonatomic) NSMutableArray *favoriteArray;
@property (strong, nonatomic) NSMutableArray *favoriteIDArray;
@property (assign, nonatomic) int nSleepTimeIndex;
@property (assign, nonatomic) int nIndicatorRate;

- (void) setSleepTimer;
@end

