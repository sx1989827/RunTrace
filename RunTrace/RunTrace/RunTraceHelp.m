//
//  RunTraceHelp.m
//  RunTrace
//
//  Created by 孙昕 on 15/9/18.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "RunTraceHelp.h"
#define VERSION 1.1
typedef enum
{
   GENERAL,SUPERVIEWS,SUBVIEWS,CONSTRAINS,TRACE,ABOUT
} TableType;
NSString *msgRunTraceView=@"msgRunTraceView";
NSString *msgRunTraceRemoveView=@"msgRunTraceRemoveView";
NSString *msgRunTraceRemoveSubView=@"msgRunTraceRemoveSubView";
NSString *msgRunTraceAddSubView=@"msgRunTraceAddSubView";
NSString *msgRunTraceContraints=@"msgRunTraceContraints";
NSString *msgRunTraceShow=@"msgRunTraceShow";
CGFloat version=0;
@implementation RunTraceObject
+(instancetype)objectWithWeak:(id)o
{
    RunTraceObject *obj=[[RunTraceObject alloc] init];
    obj.object=o;
    return obj;
}


@end
@interface RunTraceHelp()<UITableViewDelegate,UITableViewDataSource>
{
    TableType type;
    NSMutableArray *arrSuper;
    NSMutableArray *arrSub;
    BOOL bTouch;
    CGFloat left,top;
    CGRect originFrame;
    NSMutableArray* arrTrace;
    CGFloat viewTrackBorderWidth;
    UIColor* ViewTrackBorderColor;
    NSMutableArray *arrConstrains;
    NSMutableArray *arrStackView;
    NSMutableArray *arrGeneral;
    NSMutableArray *arrAbout;
    NSArray *arrLeft;
    BOOL bTrace;
}
@end
@implementation RunTraceHelp

-(void)willMoveToWindow:(UIWindow *)newWindow
{
    if(newWindow!=nil)
    {
        bTouch=NO;
        bTrace=NO;
        self.clipsToBounds=YES;
        self.translatesAutoresizingMaskIntoConstraints=YES;
        self.layer.borderWidth=2;
        self.layer.borderColor=[UIColor blackColor].CGColor;
        _tableLeft.delegate=self;
        _tableLeft.dataSource=self;
        _tableRight.delegate=self;
        _tableRight.dataSource=self;
        _btnBack.hidden=YES;
        arrLeft=@[@"General",@"SuperViews",@"SubViews",@"Constrains",@"Trace",@"About"];
        arrStackView=[[NSMutableArray alloc] initWithCapacity:30];
        arrGeneral=[[NSMutableArray alloc] initWithCapacity:30];
        arrAbout=[[NSMutableArray alloc] initWithCapacity:30];
        [arrAbout addObject:@"更新检查中。。。"];
        [arrAbout addObject:@"QQ群：1群：460483960（目前已满） 2群：239309957 这是我们的ios项目的开发者qq群，这是一个纯粹的ios开发者社区，里面汇聚了众多有经验的ios开发者，没有hr和打扰和广告的骚扰，为您创造一个纯净的技术交流环境，如果您对我的项目以及对ios开发有任何疑问，都可以加群交流，欢迎您的加入~  \r微信公众号：fuckingxcode 欢迎大家关注，我们群的活动投票和文章等都会在公众号里，群期刊目前也移到公众号里。"];
        [self initView:_viewHit Back:NO];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoveView:) name:msgRunTraceRemoveView object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoveSubView:) name:msgRunTraceRemoveSubView object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAddSubView:) name:msgRunTraceAddSubView object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if(bTrace && _viewHit)
        {
            [self stopTrace];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:msgRunTraceShow object:nil];
    }
}

-(void)handleRemoveSubView:(NSNotification*)nofi
{
    UIView *view=nofi.object;
    if(view==_viewHit)
    {
        view=nofi.userInfo[@"subview"];
        [arrTrace addObject:@{
                              @"Key":@"Remove SubView",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"%@(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",NSStringFromClass([view class]),view.frame.origin.x,view.frame.origin.y,view.frame.size.width,view.frame.size.height],
                              @"NewValue":@"nil"
                              }];
        if(type==TRACE)
        {
            [_tableRight reloadData];
            _tableRight.tableFooterView=[[UIView alloc] init];
        }
    }
}

-(void)handleAddSubView:(NSNotification*)nofi
{
    UIView *view=nofi.object;
    if(view==_viewHit)
    {
        view=nofi.userInfo[@"subview"];
        [arrTrace addObject:@{
                              @"Key":@"Add SubView",
                              @"Time":[self currentDate],
                              @"OldValue":@"nil",
                              @"NewValue":[NSString stringWithFormat:@"%@(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",NSStringFromClass([view class]),view.frame.origin.x,view.frame.origin.y,view.frame.size.width,view.frame.size.height]
                              }];
        if(type==TRACE)
        {
            [_tableRight reloadData];
            _tableRight.tableFooterView=[[UIView alloc] init];
        }
    }
}

-(void)handleRemoveView:(NSNotification*)nofi
{
    UIView *view=nofi.object;
    if(view==_viewHit)
    {
        [self stopTrace];
        _viewHit.layer.borderColor=ViewTrackBorderColor.CGColor;
        _viewHit.layer.borderWidth=viewTrackBorderWidth;
        [arrTrace addObject:@{
                              @"Key":@"RemoveFromSuperview",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"%@(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",NSStringFromClass([view class]),view.frame.origin.x,view.frame.origin.y,view.frame.size.width,view.frame.size.height],
                              @"NewValue":@"nil"
                              }];
        if(type==TRACE)
        {
            [_tableRight reloadData];
            _tableRight.tableFooterView=[[UIView alloc] init];
            UIButton *btn=(UIButton*)_tableRight.tableHeaderView;
            [btn setTitle:@"Start" forState:UIControlStateNormal];
        }
        [arrSuper removeAllObjects];
        [arrSub removeAllObjects];
        [arrConstrains removeAllObjects];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"RunTrace" message:[NSString stringWithFormat:@"%@ RemoveFromSuperview",NSStringFromClass([view class])] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        _lbCurView.text=[_lbCurView.text stringByAppendingString:@" has removed"];
    }
}

- (IBAction)onClose:(id)sender
{
    if([[_btnClose titleForState:UIControlStateNormal] isEqualToString:@"Close"])
    {
        [self removeFromSuperview];
    }
    else if([[_btnClose titleForState:UIControlStateNormal] isEqualToString:@"Stop"])
    {
        [self stopTrace];
        if(bTrace &&  _viewHit)
        {
            _viewHit.layer.borderColor=ViewTrackBorderColor.CGColor;
            _viewHit.layer.borderWidth=viewTrackBorderWidth;
            bTrace=NO;
        }
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==_tableLeft)
    {
        return ABOUT+1;
    }
    else if(tableView==_tableRight)
    {
        if(type==GENERAL)
        {
            return arrGeneral.count;
        }
        else if(type==SUPERVIEWS)
        {
            return arrSuper.count;
        }
        else if(type==SUBVIEWS)
        {
            return arrSub.count;
        }
        else if(type==CONSTRAINS)
        {
            return  arrConstrains.count;
        }
        else if(type==TRACE)
        {
            return  arrTrace.count;
        }
        else if(type==ABOUT)
        {
            return arrAbout.count;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(tableView==_tableLeft)
    {
        NSString *cellID=@"RunTraceHelpLeftCell";
        cell=[tableView dequeueReusableCellWithIdentifier:cellID];
        if(cell==nil)
        {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        cell.textLabel.font=[UIFont systemFontOfSize:14];
        cell.textLabel.text=arrLeft[indexPath.row];
        return cell;
    }
    else
    {
        if(type==GENERAL)
        {
            cell=[self handleGeneralCell:indexPath];
        }
        else if(type==SUPERVIEWS)
        {
            cell=[self handleSuperViewsCell:indexPath];
        }
        else if(type==SUBVIEWS)
        {
            cell=[self handleSubViewsCell:indexPath];
        }
        else if(type==CONSTRAINS)
        {
            cell=[self handleConstrainsCell:indexPath];
        }
        else if(type==TRACE)
        {
            cell=[self handleTraceCell:indexPath];
        }
        else if(type==ABOUT)
        {
            cell=[self handleAboutCell:indexPath];
        }
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_tableLeft)
    {
        type=(TableType)indexPath.row;
        [_tableRight reloadData];
        if(type==TRACE)
        {
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
            [btn setTitle:bTrace?@"Stop":@"Start" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            btn.backgroundColor=[UIColor colorWithRed:0.000 green:1.000 blue:0.740 alpha:1.000];
            [btn addTarget:self action:@selector(onTrace:) forControlEvents:UIControlEventTouchUpInside];
            _tableRight.tableHeaderView=btn;
        }
        else
        {
            _tableRight.tableHeaderView=nil;
        }
    }
    else
    {
        if(type==SUPERVIEWS)
        {
            UIView *view=((RunTraceObject*)arrSuper[indexPath.row]).object;
            if(view)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:msgRunTraceView object:view];
                [self initView:view Back:NO];
            }
            else
            {
                return;
            }
        }
        else if(type==SUBVIEWS)
        {
            UIView *view=((RunTraceObject*)arrSub[indexPath.row]).object;;
            if(view)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:msgRunTraceView object:view];
                [self initView:view Back:NO];
            }
            else
            {
                
                return;
            }
        }
        else if(type==CONSTRAINS)
        {
            NSString *strType=arrConstrains[indexPath.row][@"Type"];
            if([strType isEqualToString:@"IntrinsicContent Width"] || [strType isEqualToString:@"IntrinsicContent Height"] || [strType isEqualToString:@"BaseLine"])
            {
                return;
            }
            if(_viewHit==nil)
            {
                return;
            }
            NSMutableDictionary* dic=[NSMutableDictionary dictionaryWithDictionary:arrConstrains[indexPath.row]];
            [dic setObject:[RunTraceObject objectWithWeak:_viewHit] forKey:@"View"];
            [[NSNotificationCenter defaultCenter] postNotificationName:msgRunTraceContraints object:dic];
        }
        else
        {
            return;
        }
        [self minimize];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_tableLeft)
    {
        return 44;
    }
    else
    {
        if(type==GENERAL)
        {
            return [self heightForGeneralCell:indexPath Width:tableView.bounds.size.width-2*tableView.separatorInset.left];
        }
        else if(type==SUPERVIEWS)
        {
            return [self heightForSuperCell:indexPath Width:tableView.bounds.size.width-2*tableView.separatorInset.left];
        }
        else if(type==SUBVIEWS)
        {
            return [self heightForSubCell:indexPath Width:tableView.bounds.size.width-2*tableView.separatorInset.left];
        }
        else if(type==CONSTRAINS)
        {
            return [self heightForConstrainsCell:indexPath Width:tableView.bounds.size.width-2*tableView.separatorInset.left];
        }
        else if(type==TRACE)
        {
            return [self heightForTraceCell:indexPath Width:tableView.bounds.size.width-2*tableView.separatorInset.left];
        }
        else if(type==ABOUT)
        {
            return [self heightForAboutCell:indexPath Width:tableView.bounds.size.width-2*tableView.separatorInset.left];
        }
        else
        {
            return 0;
        }
    }
}

-(void)traceSuperAndSubView
{
    if(_viewHit==nil)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"RunTrace" message:@"View has removed and can't trace!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    viewTrackBorderWidth=_viewHit.layer.borderWidth;
    ViewTrackBorderColor=[UIColor colorWithCGColor:_viewHit.layer.borderColor] ;
    _viewHit.layer.borderWidth=3;
    _viewHit.layer.borderColor=[UIColor blackColor].CGColor;
    [self minimize];
}

-(void)expand:(UIButton*)btn
{
    [btn removeFromSuperview];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame=originFrame;
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    bTouch=YES;
    UITouch *touch=[touches anyObject];
    CGPoint p=[touch locationInView:self];
    left=p.x;
    top=p.y;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!bTouch)
    {
        return;
    }
    UITouch *touch=[touches anyObject];
    CGPoint p=[touch locationInView:self.window];
    self.frame=CGRectMake(p.x-left, p.y-top, self.frame.size.width, self.frame.size.height);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    bTouch=NO;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    bTouch=NO;
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if([keyPath isEqualToString:@"frame"])
    {
        CGRect oldFrame=[change[NSKeyValueChangeOldKey] CGRectValue];
        CGRect newFrame=[change[NSKeyValueChangeNewKey] CGRectValue];
        if(CGRectEqualToRect(oldFrame, newFrame))
        {
            return;
        }
        [arrTrace addObject:@{
                             @"Key":@"Frame Change",
                             @"Time":[self currentDate],
                             @"OldValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",oldFrame.origin.x,oldFrame.origin.y,oldFrame.size.width,oldFrame.size.height],
                             @"NewValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",newFrame.origin.x,newFrame.origin.y,newFrame.size.width,newFrame.size.height]
                              }];
    }
    else if([keyPath isEqualToString:@"center"])
    {
        CGPoint oldCenter=[change[NSKeyValueChangeOldKey] CGPointValue];
        CGPoint newCenter=[change[NSKeyValueChangeNewKey] CGPointValue];
        if(CGPointEqualToPoint(oldCenter, newCenter))
        {
            return;
        }
        [arrTrace addObject:@{
                              @"Key":@"Center Change",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"(x:%0.1lf y:%0.1lf)",oldCenter.x,oldCenter.y],
                              @"NewValue":[NSString stringWithFormat:@"(x:%0.1lf y:%0.1lf)",newCenter.x,newCenter.y]
                              }];
    }
    else if([keyPath isEqualToString:@"superview.frame"])
    {
        CGRect oldFrame=[change[NSKeyValueChangeOldKey] CGRectValue];
        CGRect newFrame=[change[NSKeyValueChangeNewKey] CGRectValue];
        if(CGRectEqualToRect(oldFrame, newFrame))
        {
            return;
        }
        [arrTrace addObject:@{
                              @"Key":@"Superview Frame Change",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",oldFrame.origin.x,oldFrame.origin.y,oldFrame.size.width,oldFrame.size.height],
                              @"NewValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",newFrame.origin.x,newFrame.origin.y,newFrame.size.width,newFrame.size.height],
                              @"Superview":NSStringFromClass([((UIView*)object).superview class])
                              }];
    }
    else if([keyPath isEqualToString:@"tag"])
    {
        NSInteger oldVal=[change[NSKeyValueChangeOldKey] integerValue];
        NSInteger newVal=[change[NSKeyValueChangeNewKey] integerValue];
        [arrTrace addObject:@{
                              @"Key":@"Tag Change",
                              @"Time":[self currentDate],
                              @"OldValue":@(oldVal),
                              @"NewValue":@(newVal)
                              }];
    }
    else if([keyPath isEqualToString:@"userInteractionEnabled"])
    {
        BOOL oldVal=[change[NSKeyValueChangeOldKey] boolValue];
        BOOL newVal=[change[NSKeyValueChangeNewKey] boolValue];
        [arrTrace addObject:@{
                              @"Key":@"userInteractionEnabled Change",
                              @"Time":[self currentDate],
                              @"OldValue":oldVal?@"YES":@"NO",
                              @"NewValue":newVal?@"YES":@"NO"
                              }];
    }
    else if([keyPath isEqualToString:@"hidden"])
    {
        BOOL oldVal=[change[NSKeyValueChangeOldKey] boolValue];
        BOOL newVal=[change[NSKeyValueChangeNewKey] boolValue];
        [arrTrace addObject:@{
                              @"Key":@"hidden Change",
                              @"Time":[self currentDate],
                              @"OldValue":oldVal?@"YES":@"NO",
                              @"NewValue":newVal?@"YES":@"NO"
                              }];
    }
    else if([keyPath isEqualToString:@"bounds"])
    {
        CGRect oldFrame=[change[NSKeyValueChangeOldKey] CGRectValue];
        CGRect newFrame=[change[NSKeyValueChangeNewKey] CGRectValue];
        if(CGRectEqualToRect(oldFrame, newFrame))
        {
            return;
        }
        [arrTrace addObject:@{
                              @"Key":@"Bounds Change",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",oldFrame.origin.x,oldFrame.origin.y,oldFrame.size.width,oldFrame.size.height],
                              @"NewValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",newFrame.origin.x,newFrame.origin.y,newFrame.size.width,newFrame.size.height]
                              }];
    }
    else if([keyPath isEqualToString:@"contentSize"])
    {
        CGSize oldSize=[change[NSKeyValueChangeOldKey] CGSizeValue];
        CGSize newSize=[change[NSKeyValueChangeNewKey] CGSizeValue];
        if(CGSizeEqualToSize(oldSize, newSize))
        {
            return;
        }
        [arrTrace addObject:@{
                              @"Key":@"ContentSize Change",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"(w:%0.1lf h:%0.1lf)",oldSize.width,oldSize.height],
                              @"NewValue":[NSString stringWithFormat:@"(w:%0.1lf h:%0.1lf)",newSize.width,newSize.height]
                              }];
    }
    else if([keyPath isEqualToString:@"contentOffset"])
    {
        CGPoint oldOffset=[change[NSKeyValueChangeOldKey] CGPointValue];
        CGPoint newOffset=[change[NSKeyValueChangeNewKey] CGPointValue];
        if(CGPointEqualToPoint(oldOffset, newOffset))
        {
            return;
        }
        [arrTrace addObject:@{
                              @"Key":@"ContentOffset Change",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf)",oldOffset.x,oldOffset.y],
                              @"NewValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf)",newOffset.x,newOffset.y]
                              }];
    }
    else if([keyPath isEqualToString:@"contentInset"])
    {
        UIEdgeInsets oldEdge=[change[NSKeyValueChangeOldKey] UIEdgeInsetsValue];
        UIEdgeInsets newEdge=[change[NSKeyValueChangeNewKey] UIEdgeInsetsValue];
        if(UIEdgeInsetsEqualToEdgeInsets(oldEdge, newEdge))
        {
            return;
        }
        [arrTrace addObject:@{
                              @"Key":@"ContentInset Change",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf r:%0.1lf b:%0.1lf)",oldEdge.left,oldEdge.top,oldEdge.right,oldEdge.bottom],
                              @"NewValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf r:%0.1lf b:%0.1lf)",newEdge.left,oldEdge.top,newEdge.right,oldEdge.bottom]
                              }];
    }
    [_tableRight reloadData];
    _tableRight.tableFooterView=[[UIView alloc] init];
}

- (NSString *)currentDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss:SSS"];
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    return destDateString;
}

-(void)startTrace
{
    UIButton *btn=(UIButton*)_tableRight.tableHeaderView;
    if(_viewHit==nil)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"RunTrace" message:@"View has removed and can't trace!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    bTrace=YES;
    [btn setTitle:@"Stop" forState:UIControlStateNormal];
    [arrTrace removeAllObjects];
    [_tableRight reloadData];
    _tableRight.tableFooterView=[[UIView alloc] init];
    [_viewHit addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [_viewHit addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [_viewHit addObserver:self forKeyPath:@"superview.frame" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [_viewHit addObserver:self forKeyPath:@"tag" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [_viewHit addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [_viewHit addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [_viewHit addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    if([_viewHit isKindOfClass:[UIScrollView class]])
    {
        [_viewHit addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
        [_viewHit addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
        [_viewHit addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    }
    [self traceSuperAndSubView];
}

-(void)stopTrace
{
    if(!bTrace)
    {
        return;
    }
    bTrace=NO;
    UIButton *btn=(UIButton*)_tableRight.tableHeaderView;
    [btn setTitle:@"Start" forState:UIControlStateNormal];
    [_viewHit removeObserver:self forKeyPath:@"frame"];
    [_viewHit removeObserver:self forKeyPath:@"center"];
    [_viewHit removeObserver:self forKeyPath:@"superview.frame"];
    [_viewHit removeObserver:self forKeyPath:@"tag"];
    [_viewHit removeObserver:self forKeyPath:@"userInteractionEnabled"];
    [_viewHit removeObserver:self forKeyPath:@"hidden"];
    [_viewHit removeObserver:self forKeyPath:@"bounds"];
    if([_viewHit isKindOfClass:[UIScrollView class]])
    {
        [_viewHit removeObserver:self forKeyPath:@"contentSize"];
        [_viewHit removeObserver:self forKeyPath:@"contentOffset"];
        [_viewHit removeObserver:self forKeyPath:@"contentInset"];
    }
    _viewHit.layer.borderColor=ViewTrackBorderColor.CGColor;
    _viewHit.layer.borderWidth=viewTrackBorderWidth;
}


-(void)analysisAutoLayout
{
    if(_viewHit.translatesAutoresizingMaskIntoConstraints==YES)
    {
        
        return;
    }
    UIView *viewContraint=_viewHit;
    while(viewContraint!=nil && ![viewContraint isKindOfClass:NSClassFromString(@"UIViewControllerWrapperView")])
    {
        for(NSLayoutConstraint *con in viewContraint.constraints)
        {
            CGFloat constant=con.constant;
            UIView *viewFirst=con.firstItem;
            UIView *viewSecond=con.secondItem;
            if(con.secondItem!=nil )
            {
                if(con.firstItem==_viewHit && con.firstAttribute==con.secondAttribute)
                {
                    if([viewFirst isDescendantOfView:viewSecond])
                    {
                        constant=con.constant;
                    }
                    else if([viewSecond isDescendantOfView:viewFirst])
                    {
                        constant=-con.constant;
                    }
                    else
                    {
                        constant=con.constant;
                    }
                }
                else if(con.firstItem==_viewHit && con.firstAttribute!=con.secondAttribute)
                {
                    constant=con.constant;
                }
                else if(con.secondItem==_viewHit && con.firstAttribute==con.secondAttribute)
                {
                    if([viewFirst isDescendantOfView:viewSecond])
                    {
                        constant=-con.constant;
                    }
                    else if([viewSecond isDescendantOfView:viewFirst])
                    {
                        constant=con.constant;
                    }
                    else
                    {
                        constant=con.constant;
                    }
                }
                else if(con.secondItem==_viewHit && con.firstAttribute!=con.secondAttribute)
                {
                    constant=con.constant;
                }
            }
            
            if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeLeading || con.firstAttribute==NSLayoutAttributeLeft || con.firstAttribute==NSLayoutAttributeLeadingMargin || con.firstAttribute==NSLayoutAttributeLeftMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Left",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.secondItem],
                                           @"Constant":@(con.constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeLeading || con.secondAttribute==NSLayoutAttributeLeft || con.secondAttribute==NSLayoutAttributeLeadingMargin || con.secondAttribute==NSLayoutAttributeLeftMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Left",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeTop || con.firstAttribute==NSLayoutAttributeTopMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Top",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.secondItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeTop || con.secondAttribute==NSLayoutAttributeTopMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Top",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeTrailing || con.firstAttribute==NSLayoutAttributeTrailingMargin || con.firstAttribute==NSLayoutAttributeRight || con.firstAttribute==NSLayoutAttributeRightMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Right",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.secondItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeTrailing || con.secondAttribute==NSLayoutAttributeTrailingMargin || con.secondAttribute==NSLayoutAttributeRight || con.secondAttribute==NSLayoutAttributeRightMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Right",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeBottom || con.firstAttribute==NSLayoutAttributeBottomMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Bottom",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.secondItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeBottom || con.secondAttribute==NSLayoutAttributeBottomMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Bottom",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if((con.firstItem==_viewHit && con.firstAttribute==NSLayoutAttributeWidth) || (con.secondItem==_viewHit && con.secondAttribute==NSLayoutAttributeWidth))
            {
                if([con isKindOfClass:NSClassFromString(@"NSContentSizeLayoutConstraint")])
                {
                    [arrConstrains addObject:@{
                                               @"Type":@"IntrinsicContent Width",
                                               @"Value":con.description,
                                               @"Constant":@(constant)
                                               }];
                }
                else
                {
                    [arrConstrains addObject:@{
                                               @"Type":@"Width",
                                               @"Value":con.description,
                                               @"ToView":[RunTraceObject objectWithWeak:con.firstItem==_viewHit?con.secondItem:con.firstItem],
                                               @"Constant":@(constant),
                                               @"Multiplier":@(con.multiplier),
                                               @"Priority":@(con.priority)
                                               }];
                }
            }
            else if((con.firstItem==_viewHit && con.firstAttribute==NSLayoutAttributeHeight) || (con.secondItem==_viewHit && con.secondAttribute==NSLayoutAttributeHeight))
            {
                if([con isKindOfClass:NSClassFromString(@"NSContentSizeLayoutConstraint")])
                {
                    [arrConstrains addObject:@{
                                               @"Type":@"IntrinsicContent Height",
                                               @"Value":con.description,
                                               @"Constant":@(constant)
                                               }];
                }
                else
                {
                    [arrConstrains addObject:@{
                                               @"Type":@"Height",
                                               @"Value":con.description,
                                               @"ToView":[RunTraceObject objectWithWeak:con.firstItem==_viewHit?con.secondItem:con.firstItem],
                                               @"Constant":@(constant),
                                               @"Multiplier":@(con.multiplier),
                                               @"Priority":@(con.priority)
                                               }];
                }
            }
            else if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeCenterX))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"CenterX",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.secondItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeCenterX))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"CenterX",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeCenterY))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"CenterY",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.secondItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeCenterY))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"CenterY",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeBaseline))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"BaseLine",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.secondItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeBaseline))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"BaseLine",
                                           @"Value":con.description,
                                           @"ToView":[RunTraceObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
        }
        viewContraint=viewContraint.superview;
    }
}

- (IBAction)onDonate:(id)sender
{
    NSMutableString *s = [[NSMutableString alloc] initWithString:@"moc.qq@475414593:号账助捐宝付支"];
    NSMutableString *strResult=[NSMutableString string];
    for (NSUInteger i=s.length; i>0; i--) {
        [strResult appendString:[s substringWithRange:NSMakeRange(i-1, 1)]];
    }
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:strResult message:@"非常感谢你使用本工具，如果你觉得本工具不错，请支持下我们，赞助成功后我们将邀请您加入我们的内部讨论组，在这里，您可以参与到RunTrace的版本迭代中，并且可以第一时间获取更多更好更实用的工具和经验分享，也将认识更多的大牛，更快的提升自己。如果您有任何建议，也请及时和我们联系，您的支持，将会是我们把它做的更好的最大动力！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)initView:(UIView*)view Back:(BOOL)bBack
{
    [self stopTrace];
    _viewHit=view;
    _lbCurView.text=[NSString stringWithFormat:@"%@(%p)",NSStringFromClass([_viewHit class]),(void*)_viewHit];
    if(!bBack)
    {
        [arrStackView addObject:[RunTraceObject objectWithWeak:view]];
        if(arrStackView.count>=2)
        {
            _btnBack.hidden=NO;
        }
    }
    arrSuper=[[NSMutableArray alloc] initWithCapacity:30];
    UIView *viewSuper=_viewHit;
    while ((viewSuper=viewSuper.superview)) {
        [arrSuper addObject:[RunTraceObject objectWithWeak:viewSuper] ];
    }
    arrSub=[[NSMutableArray alloc] initWithCapacity:30];
    for(UIView *subview in _viewHit.subviews)
    {
        [arrSub addObject:[RunTraceObject objectWithWeak:subview]];
    }
    arrTrace=[[NSMutableArray alloc] initWithCapacity:30];
    arrConstrains=[[NSMutableArray alloc] initWithCapacity:30];
    arrGeneral=[[NSMutableArray alloc] initWithCapacity:30];
    [arrGeneral addObject:[NSString stringWithFormat:@"Class Name:%@",NSStringFromClass([_viewHit class])]];
    [arrGeneral addObject:[NSString stringWithFormat:@"AutoLayout:%@",_viewHit.translatesAutoresizingMaskIntoConstraints?@"NO":@"Yes"]];
    [arrGeneral addObject:[NSString stringWithFormat:@"Left:%0.2lf",_viewHit.frame.origin.x]];
    [arrGeneral addObject:[NSString stringWithFormat:@"Top:%0.2lf",_viewHit.frame.origin.y]];
    [arrGeneral addObject:[NSString stringWithFormat:@"Width:%0.2lf",_viewHit.frame.size.width]];
    [arrGeneral addObject:[NSString stringWithFormat:@"Height:%0.2lf",_viewHit.frame.size.height]];
    [self analysisAutoLayout];
    [_tableRight reloadData];
    _tableRight.tableFooterView=[[UIView alloc] init];
}

- (IBAction)onBack:(id)sender
{
    [arrStackView removeLastObject];
    UIView *view=((RunTraceObject*)[arrStackView lastObject]).object;
    if(arrStackView.count==1)
    {
        _btnBack.hidden=YES;
    }
    [self initView:view Back:YES];
}

- (IBAction)onHit:(id)sender
{
    if(_viewHit==nil)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"RunTrace" message:@"View has removed and can't hit!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:msgRunTraceView object:_viewHit];
    [self minimize];
}

- (IBAction)onMinimize:(id)sender
{
    [self minimize];
}


-(UITableViewCell*)handleGeneralCell:(NSIndexPath*)indexPath
{
    NSString *cellID=@"RunTraceHelpGeneralCell";
    UITableViewCell* cell=[_tableRight dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.numberOfLines=0;
    cell.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
    cell.textLabel.frame=CGRectMake(0, 0, cell.textLabel.frame.size.width, 40);
    cell.textLabel.text=arrGeneral[indexPath.row];
    [cell.textLabel sizeToFit];
    return cell;
}

-(UITableViewCell*)handleSuperViewsCell:(NSIndexPath*)indexPath
{
    NSString *cellID=@"RunTraceHelpSuperCell";
    UITableViewCell* cell=[_tableRight dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    UIView* view=((RunTraceObject*)arrSuper[indexPath.row]).object;
    if(view==nil)
    {
        cell.textLabel.text=@"view has released";
        cell.detailTextLabel.text=@"";
    }
    else
    {
        cell.textLabel.numberOfLines=0;
        cell.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
        cell.textLabel.frame=CGRectMake(0, 0, cell.textLabel.frame.size.width, 40);
        cell.textLabel.text=NSStringFromClass([view class]);
        [cell.textLabel sizeToFit];
        cell.detailTextLabel.numberOfLines=0;
        cell.detailTextLabel.lineBreakMode=NSLineBreakByCharWrapping;
        cell.detailTextLabel.frame=CGRectMake(0, 0, cell.detailTextLabel.frame.size.width, 40);
        cell.detailTextLabel.text=[NSString stringWithFormat:@"l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf",view.frame.origin.x,view.frame.origin.y,view.frame.size.width,view.frame.size.height];
        if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
        {
            cell.detailTextLabel.text=[cell.detailTextLabel.text stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",[[view valueForKey:@"text"] length],[view valueForKey:@"text"]]];
        }
        else if([view isKindOfClass:[UIButton class]])
        {
            UIButton *btn=(UIButton*)view;
            NSString *str=[btn titleForState:UIControlStateNormal];
            cell.detailTextLabel.text=[cell.detailTextLabel.text stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",str.length,str!=nil?str:@"" ]];
        }
        [cell.detailTextLabel sizeToFit];
    }
    
    return cell;
}

-(UITableViewCell*)handleSubViewsCell:(NSIndexPath*)indexPath
{
    NSString *cellID=@"RunTraceHelpSubCell";
    UITableViewCell* cell=[_tableRight dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    UIView* view=((RunTraceObject*)arrSub[indexPath.row]).object;
    if(view==nil)
    {
        cell.textLabel.text=@"view has released";
        cell.detailTextLabel.text=@"";
    }
    else
    {
        cell.textLabel.numberOfLines=0;
        cell.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
        cell.textLabel.frame=CGRectMake(0, 0, cell.textLabel.frame.size.width, 40);
        cell.textLabel.text=NSStringFromClass([view class]);
        [cell.textLabel sizeToFit];
        cell.detailTextLabel.numberOfLines=0;
        cell.detailTextLabel.lineBreakMode=NSLineBreakByCharWrapping;
        cell.detailTextLabel.frame=CGRectMake(0, 0, cell.detailTextLabel.frame.size.width, 40);
        cell.detailTextLabel.text=[NSString stringWithFormat:@"l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf",view.frame.origin.x,view.frame.origin.y,view.frame.size.width,view.frame.size.height];
        if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
        {
            cell.detailTextLabel.text=[cell.detailTextLabel.text stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",[[view valueForKey:@"text"] length],[view valueForKey:@"text"]]];
        }
        else if([view isKindOfClass:[UIButton class]])
        {
            UIButton *btn=(UIButton*)view;
            NSString *str=[btn titleForState:UIControlStateNormal];
            cell.detailTextLabel.text=[cell.detailTextLabel.text stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",str.length,str!=nil?str:@"" ]];
        }
        [cell.detailTextLabel sizeToFit];
    }
    return cell;
}

-(UITableViewCell*)handleConstrainsCell:(NSIndexPath*)indexPath
{
    NSString *cellID=@"RunTraceHelpConstrainsCell";
    UITableViewCell* cell=[_tableRight dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    NSDictionary *dic=arrConstrains[indexPath.row];
    cell.textLabel.numberOfLines=0;
    cell.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
    cell.textLabel.frame=CGRectMake(0, 0, cell.textLabel.frame.size.width, 40);
    cell.textLabel.text=[NSString stringWithFormat:@"%@(Priority:%ld)" ,dic[@"Type"],(long)[dic[@"Priority"] integerValue]];
    [cell.textLabel sizeToFit];
    cell.detailTextLabel.numberOfLines=0;
    cell.detailTextLabel.lineBreakMode=NSLineBreakByCharWrapping;
    cell.detailTextLabel.frame=CGRectMake(0, 40, cell.detailTextLabel.frame.size.width, 30);
    NSArray *arrTemp=[dic[@"Value"] componentsSeparatedByString:@" "];
    NSMutableArray *arr=[[NSMutableArray alloc] initWithCapacity:30];
    for(int i=1;i<arrTemp.count;i++)
    {
        [arr addObject:arrTemp[i]];
    }
    cell.detailTextLabel.text=[[arr componentsJoinedByString:@" "] stringByReplacingOccurrencesOfString:@">" withString:@""];
    [cell.detailTextLabel sizeToFit];
    return cell;
}

-(UITableViewCell*)handleTraceCell:(NSIndexPath*)indexPath
{
    NSString *cellID=@"RunTraceHelpTraceCell";
    UITableViewCell* cell=[_tableRight dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    NSDictionary *dic=arrTrace[indexPath.row];
    cell.textLabel.numberOfLines=0;
    cell.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
    cell.textLabel.frame=CGRectMake(0, 0, cell.textLabel.frame.size.width, 40);
    cell.textLabel.text=[NSString stringWithFormat:@"%@(%@)",dic[@"Key"],dic[@"Time"]];
    [cell.textLabel sizeToFit];
    cell.detailTextLabel.numberOfLines=0;
    cell.detailTextLabel.lineBreakMode=NSLineBreakByCharWrapping;
    cell.detailTextLabel.frame=CGRectMake(0, 40, cell.detailTextLabel.frame.size.width, 30);
    cell.detailTextLabel.text=[NSString stringWithFormat:@"from %@ to %@",dic[@"OldValue"],dic[@"NewValue"]];
    if([dic[@"Key"] isEqualToString:@"superview.frame"])
    {
        cell.detailTextLabel.text=[[NSString stringWithFormat:@"%@ ",dic[@"Superview"]] stringByAppendingString:cell.detailTextLabel.text];
    }
    [cell.detailTextLabel sizeToFit];
    return cell;
}

-(UITableViewCell*)handleAboutCell:(NSIndexPath*)indexPath
{
    NSString *cellID=@"RunTraceHelpAboutCell";
    UITableViewCell* cell=[_tableRight dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.numberOfLines=0;
    cell.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
    cell.textLabel.frame=CGRectMake(0, 0, cell.textLabel.frame.size.width, 40);
    cell.textLabel.text=arrAbout[indexPath.row];
    [cell.textLabel sizeToFit];
    return cell;
}

-(CGFloat)heightForGeneralCell:(NSIndexPath*)indexPath Width:(CGFloat)width
{
    if(indexPath.row==0)
    {
        NSString *str=arrGeneral[0];
        CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
        return rect.size.height+5;
    }
    else
    {
        return 44;
    }
}

-(CGFloat)heightForSuperCell:(NSIndexPath*)indexPath Width:(CGFloat)width
{
    UIView* view=((RunTraceObject*)arrSuper[indexPath.row]).object;
    NSString *str,*strDetail;
    if(view==nil)
    {
        str=@"view has released";
        strDetail=@"";
    }
    else
    {
        str=NSStringFromClass([view class]);
        strDetail=[NSString stringWithFormat:@"l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf",view.frame.origin.x,view.frame.origin.y,view.frame.size.width,view.frame.size.height];
        if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
        {
            strDetail=[strDetail stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",[[view valueForKey:@"text"] length],[view valueForKey:@"text"]]];
        }
        else if([view isKindOfClass:[UIButton class]])
        {
            UIButton *btn=(UIButton*)view;
            NSString *str=[btn titleForState:UIControlStateNormal];
            strDetail=[strDetail stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",str.length,str!=nil?str:@"" ]];
        }
    }
    CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    CGRect rectDetail=[strDetail boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    return rect.size.height+rectDetail.size.height+10;
}

-(CGFloat)heightForSubCell:(NSIndexPath*)indexPath Width:(CGFloat)width
{
    UIView* view=((RunTraceObject*)arrSub[indexPath.row]).object;
    NSString *str,*strDetail;
    if(view==nil)
    {
        str=@"view has released";
        strDetail=@"";
    }
    else
    {
        str=NSStringFromClass([view class]);
        strDetail=[NSString stringWithFormat:@"l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf",view.frame.origin.x,view.frame.origin.y,view.frame.size.width,view.frame.size.height];
        if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
        {
            strDetail=[strDetail stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",[[view valueForKey:@"text"] length],[view valueForKey:@"text"]]];
        }
        else if([view isKindOfClass:[UIButton class]])
        {
            UIButton *btn=(UIButton*)view;
            NSString *str=[btn titleForState:UIControlStateNormal];
            strDetail=[strDetail stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",str.length,str!=nil?str:@"" ]];
        }
    }
    CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    CGRect rectDetail=[strDetail boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    return rect.size.height+rectDetail.size.height+10;
}

-(CGFloat)heightForConstrainsCell:(NSIndexPath*)indexPath Width:(CGFloat)width
{
    NSString *str,*strDetail;
    NSDictionary *dic=arrConstrains[indexPath.row];
    str=[NSString stringWithFormat:@"%@(Priority:%ld)" ,dic[@"Type"],(long)[dic[@"Priority"] integerValue]];
    NSArray *arrTemp=[dic[@"Value"] componentsSeparatedByString:@" "];
    NSMutableArray *arr=[[NSMutableArray alloc] initWithCapacity:30];
    for(int i=1;i<arrTemp.count;i++)
    {
        [arr addObject:arrTemp[i]];
    }
    strDetail=[[arr componentsJoinedByString:@" "] stringByReplacingOccurrencesOfString:@">" withString:@""];
    CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    CGRect rectDetail=[strDetail boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    return rect.size.height+rectDetail.size.height+10;
}

-(CGFloat)heightForTraceCell:(NSIndexPath*)indexPath Width:(CGFloat)width
{
    NSString *str,*strDetail;
    NSDictionary *dic=arrTrace[indexPath.row];
    str=[NSString stringWithFormat:@"%@(%@)",dic[@"Key"],dic[@"Time"]];
    strDetail=[NSString stringWithFormat:@"from %@ to %@",dic[@"OldValue"],dic[@"NewValue"]];
    if([dic[@"Key"] isEqualToString:@"superview.frame"])
    {
        strDetail=[[NSString stringWithFormat:@"%@ ",dic[@"Superview"]] stringByAppendingString:strDetail];
    }
    CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    CGRect rectDetail=[strDetail boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    return rect.size.height+rectDetail.size.height+10;
}

-(CGFloat)heightForAboutCell:(NSIndexPath*)indexPath Width:(CGFloat)width
{
    if(indexPath.row==0)
    {
        if(version!=0)
        {
            if(version>VERSION)
            {
                arrAbout[0]=[NSString stringWithFormat:@"已检测到最新版本:%0.2lf 请前往https://github.com/sx1989827/RunTrace或者使用cocoapods下载最新版本",version];
            }
            else
            {
                arrAbout[0]=@"当前版本为最新版本,详情请前往https://github.com/sx1989827/RunTrace查看说明";
            }
        }
    }
    NSString *str=arrAbout[indexPath.row];
    CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    return rect.size.height+5;
}

-(void)onTrace:(UIButton*)btn
{
    if([[btn titleForState:UIControlStateNormal] isEqualToString:@"Start"])
    {
        [self startTrace];
    }
    else
    {
        [self stopTrace];
    }
}

-(void)minimize
{
    originFrame=self.frame;
    CGRect frame=CGRectMake([UIScreen mainScreen].bounds.size.width-20, [UIScreen mainScreen].bounds.size.height/2-20, 20, 40);
    [UIView animateWithDuration:0.2 animations:^{
        self.frame=frame;
    } completion:^(BOOL finished) {
        UIButton *btn=[[UIButton alloc] initWithFrame:self.bounds];
        [btn setTitle:@"<" forState:UIControlStateNormal];
        btn.backgroundColor=[UIColor blackColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(expand:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }];
}
@end










