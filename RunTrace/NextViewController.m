//
//  NextViewController.m
//  RunTrace
//
//  Created by 孙昕 on 15/9/21.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "NextViewController.h"

@interface NextViewController ()

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)onClick:(id)sender
{
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addCount) userInfo:nil repeats:YES];
}

-(void)addCount
{
    NSInteger count=[[_btnCount titleForState:UIControlStateNormal] integerValue];
    [_btnCount setTitle:[NSString stringWithFormat:@"%ld",count+1] forState:UIControlStateNormal];
}
@end






