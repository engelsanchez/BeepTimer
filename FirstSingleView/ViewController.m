//
//  ViewController.m
//  FirstSingleView
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
    } else {
        [self startTimer];
    }
}

- (void) onTimerTick:data {
    self.counter++;
    label.text = [NSString stringWithFormat:@"%i", self.counter];
}

- (void) stopTimer {
    self.counter = 0;
    [self.timer invalidate];
    self.timer = nil;
}

- (void) startTimer {
    self.counter = 0;
    label.text = @"0";
    [self.timer invalidate];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self selector:@selector(onTimerTick:)
                                                    userInfo:nil repeats:YES];
    self.timer = timer;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Override point for customization after application launch.
    //[self startTimer];
    [self.button addTarget:self action:@selector(buttonDown:event:) forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
