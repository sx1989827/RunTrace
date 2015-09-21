//
//  ViewController.h
//  RunTrace
//
//  Created by 孙昕 on 15/9/18.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *viewTest;
- (IBAction)onAdd:(id)sender;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *conTop;
- (IBAction)onNext:(id)sender;


@end

