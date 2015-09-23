//
//  RunTraceHelp.h
//  RunTrace
//
//  Created by 孙昕 on 15/9/18.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *msgRunTraceSuperView;
extern NSString *msgRunTraceSubView;
extern NSString *msgRunTraceRemoveView;
extern NSString *msgRunTraceRemoveSubView;
extern NSString *msgRunTraceAddSubView;
extern NSString *msgRunTraceContraints;
extern NSString *msgRunTraceInfoPosition;
@interface RunTraceObject:NSObject
+(instancetype)objectWithWeak:(id)o;
@property (weak,nonatomic) id object;
@end
@interface RunTraceHelp : UIView

@property (strong, nonatomic) IBOutlet UILabel *lbAutoLayout;
@property (weak,nonatomic) UIView* viewHit;
- (IBAction)onClose:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableSuper;
@property (strong, nonatomic) IBOutlet UITableView *tableSub;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) IBOutlet UIButton *btnTrace;
- (IBAction)onTrace:(id)sender;
- (IBAction)onDetail:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lbTip;
@property (strong, nonatomic) IBOutlet UIButton *btnAutoLayout;
- (IBAction)onAutoLayout:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnPosition;
- (IBAction)onPosition:(id)sender;
- (IBAction)onDonate:(id)sender;


@end
