//
//  StopArrivalTimeCell.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/22/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopTimes.h"
#import "Stop.h"
#import "StopTimeViewController.h"

@interface StopArrivalTimeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *arrivalTimerLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrivalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionBoundLabel;
@property (nonatomic, strong) NSString *directionId;
@property int currMinutes;
@property int currSeconds;
@property int currHours;
@property int totalSeconds;
@property (nonatomic, strong) NSString *arrivalSeconds;
@property BOOL deleteFlag;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (void)startTimer;
- (void)endTimer;

@end
