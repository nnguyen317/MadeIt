//
//  StopTimeViewController.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/21/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Metro.h"
#import "StopTimes.h"
#import "StopArrivalTimeCell.h"
#import "AppDelegate.h"

@interface StopTimeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) StopTimes *stopTimes;
@property (nonatomic, strong) NSMutableArray *stopArray;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBarItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)control:(id)sender;

@end
