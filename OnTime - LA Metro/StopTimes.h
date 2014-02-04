//
//  StopTimes.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/21/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import "Stop.h"

@interface StopTimes : Stop

@property (nonatomic, strong) NSString *arrivalTime;
@property (nonatomic, strong) NSString *stopName;
@property (nonatomic, strong) NSString *directionId;
@property (nonatomic, strong) NSString *tripHeadsign;
@property (nonatomic, strong) NSString *tripId;
@property (nonatomic, strong) NSString *stopSequence;

@end
