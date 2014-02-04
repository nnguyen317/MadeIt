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

@interface FavoriteViewController : UITableViewController
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@end
