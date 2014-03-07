//
//  Stop.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/15/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"

@interface Stop : Route

@property (nonatomic, strong) NSString *stopName;
@property (nonatomic, strong) NSString *stopId;
@property (nonatomic, strong) NSString *tripId;


@end
