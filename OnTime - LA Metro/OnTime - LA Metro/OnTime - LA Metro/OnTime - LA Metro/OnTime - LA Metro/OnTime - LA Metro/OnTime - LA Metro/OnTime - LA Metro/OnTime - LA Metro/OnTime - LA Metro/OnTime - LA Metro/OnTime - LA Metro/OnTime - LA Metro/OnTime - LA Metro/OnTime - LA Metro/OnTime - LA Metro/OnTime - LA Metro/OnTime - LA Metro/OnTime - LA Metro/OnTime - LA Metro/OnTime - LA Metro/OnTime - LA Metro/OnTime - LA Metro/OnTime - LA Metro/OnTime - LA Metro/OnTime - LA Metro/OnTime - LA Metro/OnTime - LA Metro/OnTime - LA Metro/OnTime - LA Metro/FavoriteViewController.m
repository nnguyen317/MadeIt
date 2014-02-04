//
//  FavoriteViewController.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/12/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "FavoriteViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"

@interface FavoriteViewController ()
{
    NSTimer *timer;
    NSMutableArray *timerContainer;
    NSMutableArray *tableData;
    int grandTotalSeconds;
    int timerSeconds;
}

@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@property (nonatomic, strong) NSArray *stationList;

@end

@implementation FavoriteViewController
@synthesize managedObjectContext = _managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ECSlidingViewController *this = [[ECSlidingViewController alloc] init];

    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
}
- (void)viewDidAppear:(BOOL)animated{
    
    //[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self getTableData];
    [timer invalidate];
    timerContainer = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
    [self startTimer];
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
    //if(tableData.count > 0){
        //for (int i = 0; i<tableData.count; i++) {
            //StopTimes *stopTimes = tableData[i];
            //int arrivalSeconds = [self getTotalSecondsFromDate:stopTimes.arrivalTime];
            //if (arrivalSeconds <= 0){
                NSArray *cells = [self.tableView visibleCells];
                for (StopArrivalTimeCell *cell in cells)
                {
                    //UILabel *textField = cell.arrivalTimeLabel;
                    //StopTimes *stopTimes = tableData[i];
                    //int totalCellSeconds = [self getTotalSecondsFromDate:textField.text];
                    
                    if(cell.totalSeconds <= 0){
                        cell.arrivalTimerLabel.textColor = [UIColor grayColor];
                        cell.arrivalTimeLabel.textColor = [UIColor grayColor];
                        cell.directionBoundLabel.textColor = [UIColor grayColor];
                        [self performSelector:@selector(deleteRow) withObject:nil afterDelay:10];
                        break;
                    } else {
                    }
                }

            //}
        //}
    //}else {
    //        [timer invalidate];
    //}
    
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
    
    /*
    for (int section = 0; section < [self.tableView numberOfSections]; section++) {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            //StopArrivalTimeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"StopTimeCell" forIndexPath:cellPath];
            UITableViewCell* cells = [self.tableView cellForRowAtIndexPath:cellPath];
            for (StopArrivalTimeCell *cell in cells){
                
            }
            NSLog(@"Cell label section %d row %d: %@",section,row,cell.arrivalTimeLabel.text);
            
        }
    }
     */
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
