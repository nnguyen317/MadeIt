//
//  AddFavoritesViewController.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/7/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Agency.h"
#import "Route.h"
#import "Stop.h"
#import "Metro.h"
#import "StopTimes.h"
#import "AppDelegate.h"
#import "Favorites.h"

@interface AddFavoritesViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (weak, nonatomic) IBOutlet UILabel *agencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *customPicker;
@property (strong, nonatomic) NSMutableArray *agencyList;
@property (strong, nonatomic) NSMutableArray *routeList;
@property (strong, nonatomic) NSMutableArray *stopList;
@property (strong, nonatomic) NSMutableArray *stopTimes;
@property (weak, nonatomic) IBOutlet UIButton *agencyButton;
@property (weak, nonatomic) IBOutlet UIButton *lineButton;
@property (weak, nonatomic) IBOutlet UIButton *stationButton;
@property (weak, nonatomic) IBOutlet UIButton *directionButton;
@property (strong, nonatomic) Agency *agency;
@property (strong, nonatomic) Route *routes;
@property (strong, nonatomic) Stop *stops;

- (IBAction)cancelAddFavorites:(id)sender;
- (IBAction)saveFavorites:(id)sender;
- (IBAction)buttonSelect:(id)sender;

@end
