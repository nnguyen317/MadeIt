//
//  StopSequenceViewController.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/20/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopTimes.h"

@interface StopSequenceViewController : UITableViewController

@property (nonatomic, strong) StopTimes *stopTimes;

@end
