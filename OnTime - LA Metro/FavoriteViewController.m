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

@end

@implementation FavoriteViewController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize revealButtonItem = _revealButtonItem;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIPanGestureRecognizer *)dynamicTransitionPanGesture {
    if (_dynamicTransitionPanGesture) return _dynamicTransitionPanGesture;
    
    _dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.transitions.dynamicTransition action:@selector(handlePanGesture:)];
    
    return _dynamicTransitionPanGesture;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
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
        
        [self.navigationController.view removeGestureRecognizer:self.slidingViewController.panGesture];
        [self.navigationController.view addGestureRecognizer:self.dynamicTransitionPanGesture];
    } else {
        [self.navigationController.view removeGestureRecognizer:self.dynamicTransitionPanGesture];
        [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    }
    
    [self getTableData];
    [timer invalidate];
    timerContainer = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
    [self startTimer];
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
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
    StopArrivalTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    timerSeconds = 0;
    
    if (cell == nil) {
        cell = [[StopArrivalTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
        
        cell.totalSeconds = arrivalTotalSeconds;
        int currHours   = arrivalTotalSeconds / 3600;
        int currMinute = (arrivalTotalSeconds / 60) % 60;
        int currSeconds = arrivalTotalSeconds % 60;
        
        
        if(arrivalTotalSeconds > grandTotalSeconds ){
            NSString *timerText = [NSString stringWithFormat:@"%02d%@%02d%@%02d",currHours,@":",currMinute,@":",currSeconds];
            cell.arrivalTimerLabel.textColor = [UIColor blackColor];
            cell.arrivalTimeLabel.textColor = [UIColor blackColor];
            cell.directionBoundLabel.textColor = [UIColor blackColor];
            cell.arrivalTimerLabel.text = timerText;
            cell.arrivalTimeLabel.text = [NSString stringWithFormat:@"Arrival time: %@",[metro convertToTime:[stopTimes.arrivalTime integerValue]]];
            cell.directionBoundLabel.text = [NSString stringWithFormat:@"%@ Bound",stopTimes.tripHeadsign];
            cell.directionId = stopTimes.directionId;
            cell.currHours = currHours;
            cell.currMinutes = currMinute;
            cell.currSeconds = currSeconds;
            
            NSDictionary *favoritesSection = @{@"totalSeconds":[NSNumber numberWithInt:arrivalTotalSeconds],
                                               @"startTimer":[NSNumber numberWithInt:0],
                                               };
            [timerContainer addObject:favoritesSection];
            [cell startTimer];
            
        }
        
    }
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    StopTimes *stopTime = tableData[section];
    return stopTime.stopName;
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
        NSMutableArray *stopTimeArray = [metro getArrivalTimeFromStopSingle:favorites.route_id withStopId:favorites.stop_id andDirectionId:favorites.direction_id forAgency:favorites.agency_id forDatabase:favorites.agency_id];
        if(stopTimeArray.count > 0){
            StopTimes *stopTimes = stopTimeArray[0];
            [tableData addObject:stopTimes];
        }
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
                for (StopArrivalTimeCell *cell in cells) {
                    if(cell.totalSeconds <= 0){
                        cell.arrivalTimerLabel.textColor = [UIColor grayColor];
                        cell.arrivalTimeLabel.textColor = [UIColor grayColor];
                        cell.directionBoundLabel.textColor = [UIColor grayColor];
                        [self performSelector:@selector(deleteRow) withObject:nil afterDelay:10];
                        break;
                    } else {
                    }
                }
}

-(void)deleteRow{
    NSArray *cells = [self.tableView visibleCells];
    
    int index = 0;
    
    for (StopArrivalTimeCell *cell in cells)
    {
        //UILabel *textField = cell.arrivalTimeLabel;
        //StopTimes *stopTimes = tableData[index];
        int totalCellSeconds = cell.totalSeconds;
        
        if(totalCellSeconds <= 0){
            [self getTableData];
            NSMutableArray *indexes = [[NSMutableArray alloc] init];

            [indexes addObject:[NSIndexPath indexPathForRow:0 inSection:index]];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            break;
        } else {
            index++;
        }
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showStopTimes"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        StopTimes *stopTimes = tableData[indexPath.section];
        Favorites *favorites = _stationList[indexPath.section];
        
        StopSequenceViewController *stopSequenceController = [segue destinationViewController];
        stopSequenceController.stopTimes = stopTimes;
        stopSequenceController.stopTimes.routeId = favorites.route_id;
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
