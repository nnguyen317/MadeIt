//
//  StopTimeViewController.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/21/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import "StopTimeViewController.h"
#import "StopSequenceViewController.h"
#import "StationsCell.h"
#import "AllStopTimeViewController.h"

@interface StopTimeViewController ()
{
    NSTimer *timer;
    NSTimer *timerDelete;
    NSString *timerText;
    int currMinute;
    int currSeconds;
    int currHours;
    
    //Keeping track of the total seconds for Inbound and Outbound
    int InboundtotalSeconds;
    int OutboundtotalSeconds;
    
    //Popping the top of the container as the timer removes and inserts rows
    
}

@property (nonatomic,strong) NSMutableArray *stopTimeList;
@property (nonatomic,strong) NSMutableArray *stopTimeContainer;
@property (nonatomic, strong) NSArray *segmentItems;
@property (nonatomic, strong) NSString *selectedSegment;
@end

@implementation StopTimeViewController
@synthesize stopTimeList = _stopTimeList;
@synthesize stopTimes = _stopTimes;
@synthesize stopArray = _stopArray;
@synthesize stopTimeContainer = _stopTimeContainer;
@synthesize segmentItems = _segmentItems;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.segmentItems = @[@"Current",@"All"];
    self.selectedSegment = self.segmentItems[0];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self getTableData];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [self getTableData];
}


- (void)viewWillDisappear:(BOOL)animated {
    [timer invalidate];
    [timerDelete invalidate];
    
    NSArray *cells = [self.tableView visibleCells];
    
    
    
    if (![self.selectedSegment isEqualToString:@"All"]) {
        for(id cell in cells){
            if ([cell isKindOfClass:[StopArrivalTimeCell class]]) {
                [cell endTimer];
            }
        }
    }


    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.setTime = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.stopArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StopTimeCell";
    id cell = nil;
    
    if ([self.selectedSegment isEqualToString:@"Current"]) {
        CellIdentifier = @"StopTimeCell";
        StopArrivalTimeCell *newcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (newcell == nil) {
            newcell = [[StopArrivalTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [cell endTimer];
        StopTimes *stopTimes = [[StopTimes alloc] init];
        Metro *metro = [[Metro alloc] init];
        
        stopTimes = self.stopArray[indexPath.row];
        self.stopArray[indexPath.row] = stopTimes;
        
        InboundtotalSeconds = [metro getTotalSecondsFromDate:stopTimes.arrivalTime];
        
        if(InboundtotalSeconds >= 86400) {
            InboundtotalSeconds -= 86400;
        }
        newcell.totalSeconds = InboundtotalSeconds;
        newcell.arrivalSeconds = stopTimes.arrivalTime;
        
        currHours   = InboundtotalSeconds / 3600;
        currMinute = (InboundtotalSeconds / 60) % 60;
        currSeconds = InboundtotalSeconds % 60;
        
        if (currMinute == 60) {
            currHours = currHours + 1;
            currMinute = 0;
        }
        
        timerText = [NSString stringWithFormat:@"%02d%@%02d%@%02d",currHours,@":",currMinute,@":",currSeconds];
        
        
        newcell.arrivalTimerLabel.textColor = [UIColor blackColor];
        newcell.arrivalTimeLabel.textColor = [UIColor blackColor];
        newcell.directionBoundLabel.textColor = [UIColor blackColor];
        newcell.arrivalTimerLabel.text = timerText;
        newcell.arrivalTimeLabel.text = [NSString stringWithFormat:@"%@ Scheduled Arrival Time",[metro convertToTime:[stopTimes.arrivalTime integerValue]]];
        newcell.directionBoundLabel.text = [NSString stringWithFormat:@"%@ Bound",stopTimes.tripHeadsign];
        newcell.directionId = stopTimes.directionId;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.setTime){
            [timer invalidate];
        } else {
            [newcell startTimer];
        }
        
        cell = newcell;
    } else if ([self.selectedSegment isEqualToString:@"All"]) {
        CellIdentifier = @"allTimes";
        StationsCell *newCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (newCell == nil) {
            newCell = [[StationsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        NSDictionary *bounds = self.stopArray[indexPath.row];
        
        newCell.stationLabel.text = [NSString stringWithFormat:@"%@ Bound",bounds[@"trip_headsign"]];
        
        cell = newCell;
    }
    
    return cell;
}

-(void)getTableData {
    
    Metro *metro = [[Metro alloc] init];
    StopTimes *stopTimes = [[StopTimes alloc]init];
    
    self.stopArray = [[NSMutableArray alloc] init];
    
    [timer invalidate];
    [timerDelete invalidate];
    
    //Grab a list for stop times
    if (!self.selectedSegment || [self.selectedSegment isEqualToString:@"Current"]) {
        self.tableView.rowHeight = 100.0f;
        
        self.stopTimeList = [metro getArrivalTimeFromStop:self.stopTimes.routeId withStopId:self.stopTimes.stopId andDirectionId:@"0" forAgency:self.stopTimes.agencyId forDatabase:self.stopTimes.agencyId forAll:NO];
        
        //Add list to containers
        self.stopTimeContainer  = self.stopTimeList;
        
        if(self.stopTimeContainer.count > 0) {
            [self.stopArray addObject:[self.stopTimeContainer firstObject]];
            [self.stopTimeContainer removeObjectAtIndex:0];
        }
        
        if(self.stopTimeContainer.count > 0) {
            for (stopTimes in self.stopTimeContainer) {
                StopTimes *stopTimes2 = [[StopTimes alloc] init];
                stopTimes2 = [self.stopArray firstObject];
                if (stopTimes.directionId != stopTimes2.directionId) {
                    [self.stopArray addObject:stopTimes];
                    [self.stopTimeContainer removeObjectAtIndex:0];
                    break;
                }
            }
        }
        [self startTimerForInbound];
    } else if ([self.selectedSegment isEqualToString:@"All"]) {
        self.tableView.rowHeight = 50.0f;
        [timer invalidate];
        self.stopArray = [metro getStopBounds:self.stopTimes.routeId];
    }
    
    [self.tableView reloadData];
    
}



-(void)startTimerForInbound {
    timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFiredForInbound) userInfo:nil repeats:YES];
}

-(void)startTimerForDelete {
    timerDelete =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(deleteRow) userInfo:nil repeats:YES];
}

- (void)timerFiredForInbound
{

    NSArray *cells = [self.tableView visibleCells];
    BOOL insert = NO;
    for (StopArrivalTimeCell *cell in cells) {
        if(cell.totalSeconds <= 1){
            if (cell.deleteFlag == YES) {
                break;
            } else {
                cell.deleteFlag = YES;
                insert = YES;
            }
        } else {
        }
    }
    
    if(insert) {
        [self insertRow];
    }
}

-(void)insertRow {
    NSArray *cells = [self.tableView visibleCells];
    
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    NSMutableArray *stopTimesToDelete = [[NSMutableArray alloc]init];
    int currentRows = [self.tableView numberOfRowsInSection:0];
    for (StopArrivalTimeCell *cell in cells) {
        if (cell.deleteFlag == YES) {
            for (StopTimes *stopTimes in self.stopTimeContainer) {
                if ([stopTimes.directionId isEqualToString:cell.directionId]) {
                    [self.stopArray addObject:stopTimes];
                    [stopTimesToDelete addObject:stopTimes];
                    [indexes addObject:[NSIndexPath indexPathForRow:currentRows inSection:0]];
                    currentRows+=1;
                    break;
                }
            }
            
        }
    }
    
    
    for (StopTimes *stopTimes in stopTimesToDelete) {
        [self.stopTimeContainer removeObjectIdenticalTo:stopTimes];
    }
    
    
    //[indexes addObject:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0]];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    
    
    
    
    //[self performSelector:@selector(deleteRow) withObject:nil afterDelay:60];
    [self startTimerForDelete];
}

-(void)deleteRow {
    NSArray *cells = [self.tableView visibleCells];
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    BOOL delete = NO;
    for (StopArrivalTimeCell *cell in cells)
    {
        int totalCellSeconds = cell.totalSeconds;
        
        StopTimes *stopTimeToDelete = [[StopTimes alloc]init];
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
        if(totalCellSeconds <= -60){
            for (StopTimes *stopTimes in self.stopArray) {
                if ([cell.arrivalSeconds isEqualToString:stopTimes.arrivalTime]) {
                    [cell endTimer];
                    stopTimeToDelete = stopTimes;
                    [indexes addObject:cellIndexPath];
                    delete = YES;
                    break;
                }
            }
            
            [self.stopArray removeObjectIdenticalTo:stopTimeToDelete];
        
        }
    }
    
    if (delete) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        delete = NO;
    }
    
}


-(int)getTimeInSeconds {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *today = [NSDate date];
    NSString *currentTimeString = [[NSString alloc] init];
    
    if(appDelegate.setTime){
        currentTimeString = [timeFormatter stringFromDate:appDelegate.setTime];
    } else {
        currentTimeString = [timeFormatter stringFromDate:today];
    }
    
    NSArray *timeArray = [currentTimeString componentsSeparatedByString:@":"];
    int time = 0;
    int i = 0;
    for (NSString *item in timeArray) {
        int tempInt = 0;
        if (i==0) {
            tempInt = [item integerValue] * 3600;
        } else if (i==1) {
            tempInt = [item integerValue] * 60;
        } else {
            tempInt = [item integerValue];
        }
        time += tempInt;
        i+=1;
    }
    
    return time;
}

- (NSString *)convertToTime:(int)seconds {
    int thisHour   = seconds / 3600;
    int thisMinute = (seconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d%@%02d",thisHour,@":",thisMinute];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showStopTimes"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        StopTimes *stopTimes = [_stopArray objectAtIndex:indexPath.row];
        StopSequenceViewController *stopSequenceController = [segue destinationViewController];
        stopSequenceController.stopTimes = stopTimes;
        stopSequenceController.stopTimes.routeId = self.stopTimes.routeId;
    } else if([segue.identifier isEqualToString:@"listTimes"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [_stopArray objectAtIndex:indexPath.row];
        AllStopTimeViewController *allStopTimeController = [segue destinationViewController];
        allStopTimeController.navItem.title = self.stopTimes.stopName;
        allStopTimeController.bounds = self.stopArray[indexPath.row];
        allStopTimeController.stopTimes = self.stopTimes;
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
@end
