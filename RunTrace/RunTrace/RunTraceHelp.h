//
//  RunTraceHelp.h
//  RunTrace
//
//  Created by 孙昕 on 15/9/18.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *msgRunTraceView;
extern NSString *msgRunTraceRemoveView;
extern NSString *msgRunTraceRemoveSubView;
extern NSString *msgRunTraceAddSubView;
extern NSString *msgRunTraceContraints;
extern NSString *msgRunTraceShow;
extern CGFloat version;
@interface RunTraceObject:NSObject
+(instancetype)objectWithWeak:(id)o;
@property (weak,nonatomic) id object;
@end
@interface RunTraceHelp : UIView

@property (weak,nonatomic) UIView* viewHit;
- (IBAction)onClose:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) IBOutlet UILabel *lbCurView;
- (IBAction)onDonate:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableLeft;
@property (strong, nonatomic) IBOutlet UITableView *tableRight;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
- (IBAction)onBack:(id)sender;
- (IBAction)onHit:(id)sender;
- (IBAction)onMinimize:(id)sender;


@end
