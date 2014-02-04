//
//  AllStopTimeViewController.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 2/1/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopTimes.h"

@interface AllStopTimeViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *bounds;
@property (nonatomic, strong) StopTimes *stopTimes;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@end
