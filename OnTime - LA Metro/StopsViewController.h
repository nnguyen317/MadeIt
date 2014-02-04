//
//  StopsViewController.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/13/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Metro.h"
#import "StopTimeViewController.h"
#import "Stop.h"
#import "Route.h"
#import "StationsCell.h"

@interface StopsViewController : UITableViewController
@property (nonatomic, strong) Stop *stop;
@property (nonatomic, strong) Route *route;
@property (nonatomic, strong) NSMutableArray *stopList;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBarItem;

@end
