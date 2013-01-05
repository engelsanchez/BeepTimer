//
//  ViewController.m
//  BeepTimer
//
//  Created by Engel Sanchez on 1/1/13.
//  Copyright (c) 2013 Engel Sanchez. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UILabel * label;
@property (strong, nonatomic) IBOutlet UIButton * button;
@property (strong, nonatomic) NSTimer * timer;
@property int counter;

@end


@implementation ViewController

@synthesize label;
@synthesize button;

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

- (void) onTimerTick:data {
    self.counter++;
    [self refreshLabel];
}

- (void) refreshLabel {
    int mins = self.counter / 60;
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
    [super viewDidLoad];
    [self.button addTarget:self action:@selector(buttonDown:event:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
