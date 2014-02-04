//
//  RoutesViewController.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/15/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"
#import "StopsViewController.h"
#import "Metro.h"
#import "Agency.h"
#import "Stop.h"

@interface RoutesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) Agency *agency;
@property (nonatomic, strong) Route *route;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBarItem;

@end
