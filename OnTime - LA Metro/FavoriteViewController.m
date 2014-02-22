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

@interface FavoriteNavigationController ()
@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;
@property (nonatomic, strong) METransitions *transitions;

@end

@implementation FavoriteNavigationController

@synthesize dynamicTransitionPanGesture = _dynamicTransitionPanGesture;

- (UIPanGestureRecognizer *)dynamicTransitionPanGesture {
    if (_dynamicTransitionPanGesture) return _dynamicTransitionPanGesture;
    
    _dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.transitions.dynamicTransition action:@selector(handlePanGesture:)];
    
    return _dynamicTransitionPanGesture;
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    self.navigationBar.translucent = NO;
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    // Change the tab bar background
    //UIImage *tabBarBackground = [UIImage imageNamed:@"CustomUITabbar.png"];
    [[UITabBar appearance] setTintColor:[UIColor grayColor]];
	// Do any additional setup after loading the view.
    // Add the pan gesture to allow sliding
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    if ([(NSObject *)self.slidingViewController.delegate isKindOfClass:[MEDynamicTransition class]]) {
        MEDynamicTransition *dynamicTransition = (MEDynamicTransition *)self.slidingViewController.delegate;
        if (!self.dynamicTransitionPanGesture) {
            self.dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:dynamicTransition action:@selector(handlePanGesture:)];
        }
        
        [self.navigationController.view removeGestureRecognizer:self.slidingViewController.panGesture];
        [self.navigationController.view addGestureRecognizer:self.dynamicTransitionPanGesture];
    } else {
        [self.navigationController.view removeGestureRecognizer:self.dynamicTransitionPanGesture];
        [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    }
    
}

@end

@interface FavoriteViewController () <UIGestureRecognizerDelegate>
{
    NSTimer *timer;
    NSTimer *timerDelete;
    NSMutableArray *timerContainer;
    int grandTotalSeconds;
    int timerSeconds;
}

@property (nonatomic, strong) NSArray *stationList;
@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;
@property (nonatomic, strong) METransitions *transitions;
@property (nonatomic, strong) NSArray *segmentItems;
@property (nonatomic, strong) NSString *selectedSegment;
@property (nonatomic) NSInteger doorOpen;
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSMutableDictionary *stopTimeDictionary;
@property (nonatomic, strong) NSMutableArray *stopTimeObject;
@end

@implementation FavoriteViewController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize revealButtonItem = _revealButtonItem;
@synthesize segmentItems = _segmentItems;
@synthesize selectedSegment = _selectedSegment;
@synthesize doorOpen = _doorOpen;
@synthesize tableData = _tableData;

- (UIPanGestureRecognizer *)dynamicTransitionPanGesture {
    if (_dynamicTransitionPanGesture) return _dynamicTransitionPanGesture;
    
    _dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.transitions.dynamicTransition action:@selector(handlePanGesture:)];
    
    return _dynamicTransitionPanGesture;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableData = [[NSMutableArray alloc] init];
    self.stopTimeDictionary = [[NSMutableDictionary alloc] init];
    self.stopTimeObject = [[NSMutableArray alloc] init];

    self.segmentItems = @[@"Current",@"All"];
    self.selectedSegment = self.segmentItems[0];
    self.segmentBackgroundView.backgroundColor = [self colorWithHexString:@"2980b9"];
    self.segmentedControl.tintColor = [UIColor whiteColor];
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
 
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    
    self.tableData = [[NSMutableArray alloc]init];
    [self getTableData];
    [self.tableView reloadData];
    
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

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
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
    return self.tableData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSDictionary *stopDictionary = self.tableData[section];
    NSArray *allKeys = [stopDictionary allKeys];
    NSString *key = [allKeys firstObject];
    
    NSMutableArray *stopArray = [stopDictionary objectForKey:key];
    
    return stopArray.count;
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
        //StopTimes *stopTimes = self.tableData[indexPath.section];
        NSDictionary *stopDictionary = self.tableData[indexPath.section];
        NSArray *allKeys = [stopDictionary allKeys];
        NSString *key = [allKeys firstObject];
        NSMutableArray *stopArray = [stopDictionary objectForKey:key];
        StopTimes *stopTimes = stopArray[indexPath.row];
        
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
                newCell.imageView.image = [UIImage imageNamed:stopTimes.routeImg];
                newCell.currHours = currHours;
                newCell.currMinutes = currMinute;
                newCell.currSeconds = currSeconds;
                newCell.cellKey = key;
                newCell.arrivalSeconds = stopTimes.arrivalTime;
                
                NSDictionary *favoritesSection = @{@"totalSeconds":[NSNumber numberWithInt:arrivalTotalSeconds],
                                                   @"startTimer":[NSNumber numberWithInt:0],
                                                   };
                [timerContainer addObject:favoritesSection];
                [newCell endTimer];
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
        //Favorites *favorite = self.tableData[indexPath.section];
        NSDictionary *stopDictionary = self.tableData[indexPath.section];
        NSArray *allKeys = [stopDictionary allKeys];
        NSString *key = [allKeys firstObject];
        NSMutableArray *stopArray = [stopDictionary objectForKey:key];
        Favorites *favorite = stopArray[indexPath.row];
        
        newCell.directionBoundLabel.text = [NSString stringWithFormat:@"%@ Bound",favorite.trip_headsign];
        newCell.imageView.image = [UIImage imageNamed:favorite.route_img];
        cell = newCell;
    }
    
    return cell;
}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //NSString *stop_name = [[NSString alloc]init];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 16)];
    view.backgroundColor = [self colorWithHexString:@"43677F"];
    
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 16)];
    NSString *FontName = @"Bariol-Bold";
    [label setFont:[UIFont fontWithName:FontName size:16]];
    label.textColor = [UIColor whiteColor];
    
    if ([self.selectedSegment isEqualToString:@"Current"]) {
        NSDictionary *stopDictionary = self.tableData[section];
        NSArray *allKeys = [stopDictionary allKeys];
        NSString *key = [allKeys firstObject];
        NSMutableArray *stopArray = [stopDictionary objectForKey:key];
        StopTimes *stopTimes = [stopArray firstObject];
        label.text = stopTimes.stopName;
    } else {
        NSDictionary *stopDictionary = self.tableData[section];
        NSArray *allKeys = [stopDictionary allKeys];
        NSString *key = [allKeys firstObject];
        NSMutableArray *stopArray = [stopDictionary objectForKey:key];
        Favorites *favorite = [stopArray firstObject];

        label.text = favorite.stop_name;
    }
    
    [view addSubview:label];
    
    return view;
}

/*
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Set the text color of our header/footer text.
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    header.contentView.backgroundColor = [self colorWithHexString:@"43677F"];
    
    // You can also do this to set the background color of our header/footer,
    //    but the gradients/other effects will be retained.
    // view.tintColor = [UIColor blackColor];
}

 */

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
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
    grandTotalSeconds = 0;
    for (Favorites *favorites in _stationList) {
        
        if ([self.selectedSegment isEqualToString:@"Current"]) {
            self.tableView.rowHeight = 80.0f;
            NSMutableArray *stopTimeArray = [metro getArrivalTimeFromStopSingle:favorites.route_id withStopId:favorites.stop_id andDirectionId:favorites.direction_id forAgency:favorites.agency_id forDatabase:favorites.agency_id];
            if(stopTimeArray.count > 0){
                StopTimes *stopTimes = [stopTimeArray firstObject];
                stopTimes.routeColor = favorites.route_color;
                stopTimes.routeId = favorites.route_id;
                stopTimes.agencyId = favorites.agency_id;
                stopTimes.stopId = favorites.stop_id;
                stopTimes.routeImg = favorites.route_img;
                
                
                NSString *dictionaryKey = [NSString stringWithFormat:@"%@-%@-%@",favorites.route_id,favorites.stop_id,favorites.direction_id];
                NSMutableArray *stopsArray = [[NSMutableArray alloc]init];
                
                [stopsArray addObject:stopTimes];
                
                NSMutableDictionary *stopDictionary = [[NSMutableDictionary alloc] init];
                [stopDictionary setObject:stopsArray forKey:dictionaryKey];
               // [stopDictionary setObject:favorites.route_img forKey:@"img"];
                
                NSInteger index = 0;
                BOOL objectExists = NO;
                
                for(NSDictionary *thisDictionary in self.tableData) {
                    NSArray *keys = [thisDictionary allKeys];
                    NSString *key = [keys firstObject];
                    
                    if([key isEqualToString:dictionaryKey]){
                        BOOL recordExists = NO;
                        NSMutableArray *tableArray = self.tableData[index][key];
                        for (int i = 0; i < tableArray.count; i++) {
                            StopTimes *stopTimes2 = tableArray[i];
                            if([stopTimes2.arrivalTime isEqualToString:stopTimes.arrivalTime]){
                                recordExists = YES;
                            }
                        }
                        
                        if(!recordExists){
                            [self.tableData[index][key] addObject:stopTimes];
                        }
                        // [self.tableData replaceObjectAtIndex:index withObject:stopDictionary];
                        objectExists = YES;
                    }
                    index++;
                }
                
                if (!objectExists) {
                    [self.tableData addObject:stopDictionary];
                }
            }
                 
        } else {
            self.tableView.rowHeight = 60.0f;
            //[self.stopTimeObject addObject:favorites];
            //[self.tableData setObject:self.stopTimeObject forKey:[NSString stringWithFormat:@"%@-%@-%@",favorites.route_id,favorites.stop_id,favorites.direction_id]];
            
            NSString *dictionaryKey = [NSString stringWithFormat:@"%@-%@-%@",favorites.route_id,favorites.stop_id,favorites.direction_id];
            NSMutableArray *stopsArray = [[NSMutableArray alloc]init];
            NSDictionary *stopDictionary = [[NSMutableDictionary alloc]init];
            [stopsArray addObject:favorites];
            stopDictionary = @{dictionaryKey:stopsArray};
            
            NSInteger index = 0;
            BOOL objectExists = NO;
            NSMutableArray *newTableData = [self.tableData mutableCopy];
            for(NSDictionary *thisDictionary in newTableData) {
                NSArray *keys = [thisDictionary allKeys];
                NSString *key = [keys firstObject];
                
                if([key isEqualToString:dictionaryKey]){
                    [self.tableData replaceObjectAtIndex:index withObject:stopDictionary];
                }
                index++;
            }
            if (!objectExists) {
                [self.tableData addObject:stopDictionary];
            }
        }
    }
    
    [timer invalidate];
    [timerDelete invalidate];
    
    timerContainer = [[NSMutableArray alloc] init];
    
    
    if ([self.selectedSegment isEqualToString:@"Current"]) {
        [self startTimer];
        [self startTimerForDelete];

    } else {
        [timer invalidate];
        [timerDelete invalidate];
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
    timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(insertRow) userInfo:nil repeats:YES];
}

-(void)startTimerForDelete {
    timerDelete =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(deleteRow) userInfo:nil repeats:YES];
}

- (void)timerFired
{
    NSArray *cells = [self.tableView visibleCells];
    BOOL insert = NO;
    for (StopArrivalTimeCell *cell in cells) {
        if(cell.totalSeconds <= 0){
            
            if (cell.deleteFlag) {
                continue;
            } else {
                cell.arrivalTimerLabel.textColor = [UIColor grayColor];
                cell.arrivalTimeLabel.textColor = [UIColor grayColor];
                cell.directionBoundLabel.textColor = [UIColor grayColor];
                
                cell.deleteFlag = YES;
                insert = YES;
            }
            //[self deleteRow];
        } else {
        
        }
    }
    
    if (insert) {
        [self insertRow];
    }
    
}

-(void)insertRow {
    NSArray *cells = [self.tableView visibleCells];
    
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    //NSMutableArray *stopTimesToDelete = [[NSMutableArray alloc]init];
   // int currentRows = [self.tableView numberOfRowsInSection:section];
    BOOL insert = NO;
    for (StopArrivalTimeCell *cell in cells) {
        if (cell.totalSeconds <= 0) {
            if (!cell.doneDelete) {
                cell.arrivalTimerLabel.textColor = [UIColor grayColor];
                cell.arrivalTimeLabel.textColor = [UIColor grayColor];
                cell.directionBoundLabel.textColor = [UIColor grayColor];
                //[self getTableData];
                for (int i = 0; i<self.tableData.count; i++) {
                    NSDictionary *stopDictionary = self.tableData[i];
                    NSArray *keys = [stopDictionary allKeys];
                    NSString *key = [keys firstObject];
                    //NSString *image = stopDictionary[@"img"];
                    
                    if([cell.cellKey isEqualToString:key]){
                        StopTimes *stopTime = [self.tableData[i][key] firstObject];
                        Metro *metro = [[Metro alloc] init];
                        
                        NSMutableArray *stopTimeArray = [metro getArrivalTimeFromStopSingle:stopTime.routeId withStopId:stopTime.stopId andDirectionId:stopTime.directionId forAgency:stopTime.agencyId forDatabase:stopTime.agencyId];
                        
                        if (stopTimeArray.count > 0) {
                            StopTimes *stopTime2 = [stopTimeArray firstObject];
                            stopTime2.stopId = stopTime.stopId;
                            stopTime2.agencyId = stopTime.agencyId;
                            stopTime2.routeId = stopTime.routeId;
                            stopTime2.routeImg = stopTime.routeImg;
                            [self.tableData[i][key] addObject:stopTime2];
                        }
                        
                        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                        int rowCount = [self.tableView numberOfRowsInSection:indexPath.section];
                        int tableRowCount = [self.tableData[i][key] count];
                        
                        if (rowCount < 2 && tableRowCount == 2) {
                            [indexes addObject:[NSIndexPath indexPathForRow:rowCount inSection:indexPath.section]];
                            cell.doneDelete = YES;
                            insert = YES;
                        } else {
                            NSLog(@"Did not insert %@ Lets try again",stopTime.stopName);
                            
                        }
                        
                    }
                }
            }
        }
    }
    
    if (insert) {
        //[self.tableView reloadData];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
    
    
}

-(void)deleteRow{
    NSArray *cells = [self.tableView visibleCells];
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    NSMutableArray *itemsToDelete = [[NSMutableArray alloc] init];
    BOOL deleteItems = NO;
    if ([[cells firstObject] isKindOfClass:[StopArrivalTimeCell class]]) {
        for (StopArrivalTimeCell *cell in cells)
        {
            int totalCellSeconds = cell.totalSeconds;
            
            if(totalCellSeconds <= -60){
                [cell endTimer];
                //[self getTableData];
                for (int i = 0; i<self.tableData.count; i++) {
                    NSDictionary *stopDictionary = self.tableData[i];
                    NSArray *keys = [stopDictionary allKeys];
                    NSString *key = [keys firstObject];
                    
                    if([cell.cellKey isEqualToString:key]){
                        NSArray *stopArray = self.tableData[i][key];
                        for (int j = 0; j < stopArray.count; j++) {
                            StopTimes *stopTime = stopArray[j];
                            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                            NSInteger rowCount = [self.tableView numberOfRowsInSection:indexPath.section];
                            NSInteger tableRowCount = [self.tableData[i][key] count];
                            if (rowCount > 1 && tableRowCount > 1) {
                                if ([cell.arrivalSeconds isEqualToString:stopTime.arrivalTime]) {
                                    NSDictionary *items = @{@"section":[NSString stringWithFormat:@"%d",i],@"row":key,@"deleteIndex":[NSNumber numberWithInt: indexPath.row],@"object":stopTime};
                                    [itemsToDelete addObject:items];
                                    deleteItems = YES;
                                    [indexes addObject:indexPath];
                                    cell.deleteFlag = NO;
                                    cell.doneDelete = NO;
                                    //[self.tableData[i][key] removeObjectIdenticalTo:stopTime];
                                }
                            }
                        }
                    }
                }

                //NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                
            }
        }
        
        if (deleteItems) {
            for (int i=0; i < itemsToDelete.count; i++) {
                NSDictionary *deleteItems = itemsToDelete[i];
                NSInteger section = [deleteItems[@"section"] integerValue];
                NSString *row = deleteItems[@"row"];
                //int index = [deleteItems[@"delete"] integerValue];
                //[self.tableData[section][row] removeObjectAtIndex:index];
                [self.tableData[section][row] removeObjectIdenticalTo:deleteItems[@"object"]];
            }
        }
                                 
        if (indexes.count > 0){
            [self.tableView beginUpdates];
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
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSDictionary *stopDictionary = self.tableData[indexPath.section];
    NSArray *keys = [stopDictionary allKeys];
    NSString *key = [keys firstObject];
    
    if([segue.identifier isEqualToString:@"showStopTimes"]) {
        StopTimes *stopTimes = self.tableData[indexPath.section][key][indexPath.row];
        
        StopSequenceViewController *stopSequenceController = [segue destinationViewController];
        stopSequenceController.stopTimes = stopTimes;
        stopSequenceController.stopTimes.routeId = stopTimes.routeId;
        stopSequenceController.stopTimes.stopId = stopTimes.stopId;
        stopSequenceController.stopTimes.agencyId = stopTimes.agencyId;
    } else if([segue.identifier isEqualToString:@"listTimes"]) {
        Favorites *favorites = self.tableData[indexPath.section][key][indexPath.row];
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
    self.tableData = [[NSMutableArray alloc]init];
    
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
        [self.tableView reloadData];
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    
    switch (index) {
        case 0:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            NSDictionary *stopDictionary = self.tableData[cellIndexPath.section];
            NSArray *keys = [stopDictionary allKeys];
            NSString *key = [keys firstObject];
            
            Favorites *favorites = self.tableData[cellIndexPath.section][key][cellIndexPath.row];
            
            [self.tableData removeObjectAtIndex:cellIndexPath.section];
            
            [[self managedObjectContext] deleteObject:favorites];
            [[self managedObjectContext] save:nil];
            
            [self.tableView beginUpdates];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:cellIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            
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
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
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
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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