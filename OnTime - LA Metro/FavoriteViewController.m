//
//  FavoriteViewController.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/12/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "FavoriteViewController.h"
#import "MenuViewController.h"
#import "StopSequenceViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "MEDynamicTransition.h"
#import "METransitions.h"
#import "FavoritesCell.h"
#import "AllStopTimeViewController.h"
#import "SWTableViewCell.h"

@interface FavoriteViewController ()
{
    NSTimer *timer;
    NSMutableArray *timerContainer;
    NSMutableArray *tableData;
    int grandTotalSeconds;
    int timerSeconds;
}

@property (nonatomic, strong) NSArray *stationList;
@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;
@property (nonatomic, strong) METransitions *transitions;
@property (nonatomic, strong) NSArray *segmentItems;
@property (nonatomic, strong) NSString *selectedSegment;
@property (nonatomic) NSInteger doorOpen;
@end

@implementation FavoriteViewController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize revealButtonItem = _revealButtonItem;
@synthesize segmentItems = _segmentItems;
@synthesize selectedSegment = _selectedSegment;
@synthesize doorOpen = _doorOpen;

- (UIPanGestureRecognizer *)dynamicTransitionPanGesture {
    if (_dynamicTransitionPanGesture) return _dynamicTransitionPanGesture;
    
    _dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.transitions.dynamicTransition action:@selector(handlePanGesture:)];
    
    return _dynamicTransitionPanGesture;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.segmentItems = @[@"Current",@"All"];
    self.selectedSegment = self.segmentItems[0];
}


- (void)viewWillAppear:(BOOL)animated
{
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    
    _revealButtonItem.target = self;
    _revealButtonItem.action = @selector(revealMenu:);
    
    // Add the pan gesture to allow sliding
    if ([(NSObject *)self.slidingViewController.delegate isKindOfClass:[MEDynamicTransition class]]) {
        MEDynamicTransition *dynamicTransition = (MEDynamicTransition *)self.slidingViewController.delegate;
        if (!self.dynamicTransitionPanGesture) {
            self.dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:dynamicTransition action:@selector(handlePanGesture:)];
        }
        
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
        [self.view addGestureRecognizer:self.dynamicTransitionPanGesture];
    } else {
        [self.view removeGestureRecognizer:self.dynamicTransitionPanGesture];
        [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    }
    
    [self getTableData];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [timer invalidate];
    
    NSArray *cells = [self.tableView visibleCells];
    
    if (![self.selectedSegment isEqualToString:@"All"]) {
        if ([[cells firstObject] isKindOfClass:[StopArrivalTimeCell class]]){
            for(StopArrivalTimeCell *cell in cells){
                [cell endTimer];
            }
        }
        
    }
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return tableData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StopTimeCell";
    id cell = nil;
    
    if ([self.selectedSegment isEqualToString:@"Current"]) {
        CellIdentifier = @"StopTimeCell";
        StopArrivalTimeCell *newCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        timerSeconds = 0;
        
        if (newCell == nil) {
            newCell = [[StopArrivalTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        [cell endTimer];
        StopTimes *stopTimes = tableData[indexPath.section];
        Metro *metro = [[Metro alloc] init];
        
        if (stopTimes) {
            int arrivalTotalSeconds = 0;
            NSString *arrivalTime = stopTimes.arrivalTime;
            arrivalTotalSeconds = [metro getTotalSecondsFromDate:arrivalTime];
            
            if(arrivalTotalSeconds >= 86400) {
                arrivalTotalSeconds -= 86400;
            }
            
            newCell.totalSeconds = arrivalTotalSeconds;
            int currHours   = arrivalTotalSeconds / 3600;
            int currMinute = (arrivalTotalSeconds / 60) % 60;
            int currSeconds = arrivalTotalSeconds % 60;
            
            
            if(arrivalTotalSeconds > grandTotalSeconds ){
                NSString *timerText = [NSString stringWithFormat:@"%02d%@%02d%@%02d",currHours,@":",currMinute,@":",currSeconds];
                newCell.arrivalTimerLabel.textColor = [UIColor blackColor];
                newCell.arrivalTimeLabel.textColor = [UIColor blackColor];
                newCell.directionBoundLabel.textColor = [UIColor blackColor];
                newCell.arrivalTimerLabel.text = timerText;
                newCell.arrivalTimeLabel.text = [NSString stringWithFormat:@"Arrival time: %@",[metro convertToTime:[stopTimes.arrivalTime integerValue]]];
                newCell.directionBoundLabel.text = [NSString stringWithFormat:@"%@ Bound",stopTimes.tripHeadsign];
                newCell.directionId = stopTimes.directionId;
                newCell.currHours = currHours;
                newCell.currMinutes = currMinute;
                newCell.currSeconds = currSeconds;
                
                NSDictionary *favoritesSection = @{@"totalSeconds":[NSNumber numberWithInt:arrivalTotalSeconds],
                                                   @"startTimer":[NSNumber numberWithInt:0],
                                                   };
                [timerContainer addObject:favoritesSection];
                [newCell startTimer];
            }
            
            
        }
        
        cell = newCell;
        
    } else if ([self.selectedSegment isEqualToString:@"All"]) {
        CellIdentifier = @"allTimes";
        FavoritesCell *newCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (newCell == nil) {
            newCell = [[FavoritesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        FavoritesCell __weak *weakCell = newCell;
        
        [newCell setAppearanceWithBlock:^{
            weakCell.rightUtilityButtons = [self rightButtons];
            weakCell.delegate = self;
            weakCell.containingTableView = tableView;
        } force:NO];
        
        [newCell setCellHeight:newCell.frame.size.height];
        Favorites *favorite = tableData[indexPath.section];
        
        newCell.directionBoundLabel.text = [NSString stringWithFormat:@"%@ Bound",favorite.trip_headsign];
        
        cell = newCell;
    }
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *stop_name = [[NSString alloc]init];
    if ([self.selectedSegment isEqualToString:@"Current"]) {
        StopTimes *stopTime = tableData[section];
        stop_name = stopTime.stopName;
    } else {
        Favorites *favorite = tableData[section];
        stop_name = favorite.stop_name;
    }
    return stop_name;
}

- (void) getTableData {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    _managedObjectContext = appDelegate.managedObjectContext;
    
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Favorites" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    _stationList = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    Metro *metro = [[Metro alloc] init];
    tableData = [[NSMutableArray alloc] init];
    grandTotalSeconds = 0;
    for (Favorites *favorites in _stationList) {
        
        if ([self.selectedSegment isEqualToString:@"Current"]) {
            NSMutableArray *stopTimeArray = [metro getArrivalTimeFromStopSingle:favorites.route_id withStopId:favorites.stop_id andDirectionId:favorites.direction_id forAgency:favorites.agency_id forDatabase:favorites.agency_id];
            if(stopTimeArray.count > 0){
                StopTimes *stopTimes = [stopTimeArray firstObject];
                stopTimes.routeId = favorites.route_id;
                stopTimes.agencyId = favorites.agency_id;
                stopTimes.stopId = favorites.stop_id;
                [tableData addObject:stopTimes];
            }
        } else {
            [tableData addObject:favorites];
        }
    }
    
    [timer invalidate];
    timerContainer = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
    
    if ([self.selectedSegment isEqualToString:@"Current"]) {
        [self startTimer];
    } else {
        [timer invalidate];
    }
    
    
}

-(int)getTotalSecondsFromDate:(NSString *)arrivalTimeString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter2 setDateFormat:@"yyyy-MM-dd"];
    NSDate *today = [NSDate date];
    NSString *currentTimeString = [timeFormatter stringFromDate:today];
    NSDate *currentTime = [timeFormatter dateFromString:currentTimeString];
    
    NSDate *arrivalTime = [timeFormatter dateFromString:arrivalTimeString];
    int totalCellSeconds = [arrivalTime timeIntervalSinceDate:currentTime];
    
    return totalCellSeconds;
}

-(void)startTimer {
    timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}


- (void)timerFired
{
    NSArray *cells = [self.tableView visibleCells];
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    for (StopArrivalTimeCell *cell in cells) {
        if(cell.totalSeconds <= 0){
            cell.arrivalTimerLabel.textColor = [UIColor grayColor];
            cell.arrivalTimeLabel.textColor = [UIColor grayColor];
            cell.directionBoundLabel.textColor = [UIColor grayColor];
            cell.deleteFlag = YES;
            //[self deleteRow];
        } else if (cell.totalSeconds <= -10) {
            [cell endTimer];
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            [indexes addObject:cellIndexPath];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            
            [self getTableData];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            
            
        } else {
            NSLog(@"Cell:%@ at %d Seconds",cell.arrivalTimeLabel.text,cell.totalSeconds);
        }
    }
    
}

-(void)deleteRow{
    NSArray *cells = [self.tableView visibleCells];
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    if ([[cells firstObject] isKindOfClass:[StopArrivalTimeCell class]]) {
        for (StopArrivalTimeCell *cell in cells)
        {
            int totalCellSeconds = cell.totalSeconds;
            
            if(totalCellSeconds <= -10){
                [cell endTimer];
                [self getTableData];
                NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                [indexes addObject:cellIndexPath];
            }
        }
        if (indexes.count > 0){
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.selectedSegment isEqualToString:@"All"]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self performSegueWithIdentifier:@"listTimes" sender:self];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showStopTimes"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        StopTimes *stopTimes = tableData[indexPath.section];
        
        StopSequenceViewController *stopSequenceController = [segue destinationViewController];
        stopSequenceController.stopTimes = stopTimes;
        stopSequenceController.stopTimes.routeId = stopTimes.routeId;
        stopSequenceController.stopTimes.stopId = stopTimes.stopId;
        stopSequenceController.stopTimes.agencyId = stopTimes.agencyId;
    } else if([segue.identifier isEqualToString:@"listTimes"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Favorites *favorites = tableData[indexPath.section];
        StopTimes *stopTimes = [[StopTimes alloc]init];
        AllStopTimeViewController *allStopTimeController = [segue destinationViewController];
        allStopTimeController.navItem.title = favorites.stop_name;
        allStopTimeController.bounds = @{@"trip_headsign":favorites.trip_headsign,@"direction_id":favorites.direction_id};
        allStopTimeController.stopTimes = stopTimes;
        allStopTimeController.stopTimes.routeId = favorites.route_id;
        allStopTimeController.stopTimes.stopId = favorites.stop_id;
    }
}

- (IBAction)control:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if (![self.segmentItems[segmentedControl.selectedSegmentIndex] isEqualToString:self.selectedSegment]) {
        self.selectedSegment = self.segmentItems[segmentedControl.selectedSegmentIndex];
        
        if ([self.segmentItems[segmentedControl.selectedSegmentIndex] isEqualToString:@"All"]){
            if([self.tableView numberOfRowsInSection:0] > 0){
                NSArray *cells = [self.tableView visibleCells];
                
                for(id cell in cells){
                    if ([cell isKindOfClass:[StopArrivalTimeCell class]]) {
                        [cell endTimer];
                    }
                }
            }
        }
        
        [self getTableData];
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    
    switch (index) {
        case 0:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            Favorites *favorites = tableData[cellIndexPath.section];
            
            [tableData removeObjectAtIndex:cellIndexPath.section];
            
            [self.managedObjectContext deleteObject:favorites];
            
            [self.tableView beginUpdates];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:cellIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (state == 2) {
        self.doorOpen = indexPath.section;
        // Remove the pan gesture to disallow sliding
        if ([(NSObject *)self.slidingViewController.delegate isKindOfClass:[MEDynamicTransition class]]) {
            MEDynamicTransition *dynamicTransition = (MEDynamicTransition *)self.slidingViewController.delegate;
            if (!self.dynamicTransitionPanGesture) {
                self.dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:dynamicTransition action:@selector(handlePanGesture:)];
            }
            
            [self.view removeGestureRecognizer:self.dynamicTransitionPanGesture];
        } else {
            
            [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
            
        }
    }
    
    if (self.doorOpen == indexPath.section && state != 2) {
        self.doorOpen = 99;
        // Add the pan gesture to allow sliding
        if ([(NSObject *)self.slidingViewController.delegate isKindOfClass:[MEDynamicTransition class]]) {
            MEDynamicTransition *dynamicTransition = (MEDynamicTransition *)self.slidingViewController.delegate;
            if (!self.dynamicTransitionPanGesture) {
                self.dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:dynamicTransition action:@selector(handlePanGesture:)];
            }
            
            [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
            [self.view addGestureRecognizer:self.dynamicTransitionPanGesture];
        } else {
            [self.view removeGestureRecognizer:self.dynamicTransitionPanGesture];
            [self.view addGestureRecognizer:self.slidingViewController.panGesture];
        }
    }
    
}

@end