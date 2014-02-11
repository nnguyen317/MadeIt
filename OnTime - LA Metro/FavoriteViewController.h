//
//  FavoriteViewController.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/12/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Favorites.h"
#import "AppDelegate.h"
#import "Metro.h"
#import "StopTimes.h"
#import "StopArrivalTimeCell.h"
#import "MEDynamicTransition.h"
#import "SWTableViewCell.h"

@interface FavoriteNavigationController : UINavigationController

@end

@interface FavoriteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,ECSlidingViewControllerDelegate, SWTableViewCellDelegate>
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBarItem;
@property (nonatomic, strong) MEDynamicTransition *dynamicTransition;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)control:(id)sender;

@end
