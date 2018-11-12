//
//  ViewController.m
//  RedPacketRain
//
//  Created by huangliwen on 2018/11/12.
//  Copyright © 2018年 public. All rights reserved.
//

#import "ViewController.h"
#import "SSYRedpacketDJSView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onStart:(id)sender {
    SSYRedpacketDJSView *redView=[[SSYRedpacketDJSView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [redView showView];
}

@end
