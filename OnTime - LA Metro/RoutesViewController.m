//
//  RoutesViewController.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/15/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RoutesViewController.h"
#import "MenuViewController.h"
#import "StationsCell.h"
#import "AppDelegate.h"
#import "UIViewController+ECSlidingViewController.h"
#import "MEDynamicTransition.h"
#import "StationsCell.h"

@interface RoutesViewController ()
@property (nonatomic, strong) NSMutableArray *routeList;
@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;

@end

@implementation RoutesViewController
@synthesize routeList = _routeList;
@synthesize revealButtonItem = _revealButtonItem;
@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.route = [[Route alloc] init];
    Metro *routes = [[Metro alloc] init];
    
    self.route.agencyId = appDelegate.choice;
    self.routeList = [routes getRoutes:appDelegate.choice forDatabase:appDelegate.choice];
    self.navBarItem.title = appDelegate.choice;

}



- (void)viewWillAppear:(BOOL)animated
{
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;

    //if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
      //  self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
    //}
    // Add the pan gesture to allow sliding
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    if ([(NSObject *)self.slidingViewController.delegate isKindOfClass:[MEDynamicTransition class]]) {
        MEDynamicTransition *dynamicTransition = (MEDynamicTransition *)self.slidingViewController.delegate;
        if (!self.dynamicTransitionPanGesture) {
            self.dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:dynamicTransition action:@selector(handlePanGesture:)];
        }
        
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
        [self.view addGestureRecognizer:self.dynamicTransitionPanGesture];
    } else {
        [self.navigationController.view removeGestureRecognizer:self.dynamicTransitionPanGesture];
        [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    }
    _revealButtonItem.target = self;
    _revealButtonItem.action = @selector(revealMenu:);
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.routeList count];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RouteCell";
    StationsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[StationsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    Route *route = [[Route alloc] init];
    
    route = self.routeList[indexPath.row];
    
    cell.stationLabel.text = route.routeName;
    NSString *image = [NSString stringWithFormat:@"%@_img",route.routeImg];
    cell.imageView.image = [UIImage imageNamed:image];
    
    return cell;
}



-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showStops"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Stop *stop = [self.routeList objectAtIndex:indexPath.row];
        StopsViewController *stopController = [segue destinationViewController];
        stopController.stop = stop;
        stopController.stop.agencyId = self.route.agencyId;
        stopController.stop.routeImg = stop.routeImg;
        stopController.navBarItem.title = stop.routeName;
    }
}

@end
