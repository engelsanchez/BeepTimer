//
//  ViewController.m
//  BeepTimer
//
//  Created by Engel Sanchez on 1/1/13.
//  Copyright (c) 2013 Engel Sanchez. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    NSArray * playSequence;
    int playIndex;
}

@property (strong, nonatomic) IBOutlet UILabel * label;
@property (strong, nonatomic) IBOutlet UIButton * button;
@property (strong, nonatomic) NSTimer * timer;
@property (strong, nonatomic) AVAudioPlayer * player1;
@property (strong, nonatomic) AVAudioPlayer * player2;
@property int counter;
@property int period;
@property UIBackgroundTaskIdentifier bgTask;

@end


@implementation ViewController

@synthesize label;
@synthesize button;
@synthesize player1;
@synthesize player2;
@synthesize bgTask;

- (void) buttonDown: (id) sender event: (UIEvent*) e {
    if (self.timer) {
        [self stopTimer];
        [button setTitle:@"START" forState:UIControlStateNormal];
        [button setTitle:@"START" forState:UIControlStateHighlighted];
    } else {
        [self startTimer];
        [button setTitle:@"STOP" forState:UIControlStateNormal];
        [button setTitle:@"STOP" forState:UIControlStateHighlighted];
    }
}

- (AVAudioPlayer *) preparePlayer: (NSString*) name {
    NSURL * url = [[NSBundle mainBundle] URLForResource:name withExtension:@"mp3"];
    NSError * err = nil;
    AVAudioPlayer * newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    [newPlayer setDelegate: self];
    [newPlayer prepareToPlay];
    return newPlayer;
}

- (void) playSound {
    [self.player1 setCurrentTime:0];
    [self.player1 play];
}

- (void) preparePlaySequence {
    const int maxBig = 6;
    int mins = self.counter / _period;
    int numSmall = mins % 5;
    int numBig = (mins / 5) % maxBig;
    NSLog(@"Will prepare play sequence with %d bigs and %d smalls", numBig, numSmall);
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity: numBig + numSmall];
    for (int i=0;i<numBig; i++)
        [arr addObject: player1];
    for (int i=0;i<numSmall; i++)
        [arr addObject: player2];
    playSequence = arr;
    playIndex = 0;
    NSLog(@"Prepared play sequence with %d bigs and %d smalls", numBig, numSmall);
    [[AVAudioSession sharedInstance] setActive: YES error: NULL];
}

- (BOOL) playNext {
    int count = [playSequence count];
    if (playSequence && playIndex < count) {
        AVAudioPlayer * player = [playSequence objectAtIndex: playIndex++];
        [player setCurrentTime:0];
        [player play];
        return YES;
    } else
        return NO;
}

- (void) onTimerTick: data {
    self.counter++;
    [self refreshLabel];
    if ((self.counter % _period) == 0) {
        NSLog(@"Will prepare play sequence");
        [self preparePlaySequence];
        [self playNext];
    }
    //UIApplication * app = [UIApplication sharedApplication];
    //NSLog(@"Time left is %f", app.backgroundTimeRemaining);
}

- (void) refreshLabel {
    int mins = (self.counter / 60) % 60; // wrap around at 60 mins
    int secs = self.counter % 60;
    label.text = [NSString stringWithFormat:@"%02d:%02d", mins, secs];
}

- (void) stopTimer {
    self.counter = 0;
    [self.timer invalidate];
    self.timer = nil;
}

- (void) startTimer {
    self.counter = 0;
    [self refreshLabel];
    [self.timer invalidate];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self selector:@selector(onTimerTick:)
                                                    userInfo:nil repeats:YES];
    self.timer = timer;
}

- (void)viewDidLoad
{
    _period = 60;
    [super viewDidLoad];
    playSequence = nil;
    playIndex = 0;
    [self.button addTarget:self action:@selector(buttonDown:event:) forControlEvents:UIControlEventTouchUpInside];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: NULL];
    UIApplication  *app = [UIApplication sharedApplication];
    [app beginReceivingRemoteControlEvents];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    self.player1 = [self preparePlayer: @"Big"];
    self.player2 = [self preparePlayer: @"Little"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// When Audio session is interrupted.
- (void) beginInterruption {
    
}

- (void) endInterruptionWithFlags: (NSUInteger) flags {
    
}

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer*) player successfully: (BOOL) flag {
    if (![self playNext]) {
        UIApplication  *app = [UIApplication sharedApplication];
        [app endBackgroundTask:bgTask];
        bgTask = [app beginBackgroundTaskWithExpirationHandler: ^{
            [app endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
    }
    
}

@end
