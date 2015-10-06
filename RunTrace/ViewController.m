//
//  ViewController.m
//  RunTrace
//
//  Created by 孙昕 on 15/9/18.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "ViewController.h"
#import "NextViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAdd:(id)sender
{
    UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lb.text=@"123";
    [_viewTest addSubview:lb];
    _conTop.constant-=100;
    [UIView animateWithDuration:1 animations:^{
        [self.view layoutIfNeeded];
    }];

}
- (IBAction)onNext:(id)sender
{
    NextViewController *vc=[[NextViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end







