//
//  AllStopTimeViewController.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 2/1/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "AllStopTimeViewController.h"
#import "Metro.h"
#import "StopSequenceCell.h"
#import "StopSequenceViewController.h"

@interface AllStopTimeViewController ()

@property (nonatomic, strong) NSMutableArray *stopTimeList;

@end

@implementation AllStopTimeViewController
@synthesize stopTimes = _stopTimes;
@synthesize bounds = _bounds;
@synthesize navItem = _navItem;

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
    
    Metro *metro = [[Metro alloc] init];
    
    self.stopTimeList = [metro getArrivalTimeFromStop:self.stopTimes.routeId withStopId:self.stopTimes.stopId andDirectionId:self.bounds[@"direction_id"] forAgency:self.stopTimes.agencyId forDatabase:self.stopTimes.agencyId forAll:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.stopTimeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StopTimeCell";
    StopSequenceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[StopSequenceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    StopTimes *stopTimes = [[StopTimes alloc] init];
    Metro *metro = [[Metro alloc]init];
    // Configure the cell...
    stopTimes = self.stopTimeList[indexPath.row];
    
    if (stopTimes.tripShortName) {
        cell.stopName.text = [NSString stringWithFormat:@"%@ - %@ Bound",stopTimes.tripShortName, stopTimes.tripHeadsign];
    } else {
        cell.stopName.text = [NSString stringWithFormat:@"%@ Bound",stopTimes.tripHeadsign];
    }
    cell.arrivalTime.text = [metro convertToTime:[stopTimes.arrivalTime integerValue]];
    
    return cell;
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showStopTimes"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        StopTimes *stopTimes = [self.stopTimeList objectAtIndex:indexPath.row];
        StopSequenceViewController *stopSequenceController = [segue destinationViewController];
        stopSequenceController.stopTimes = stopTimes;
        stopSequenceController.stopTimes.routeId = self.stopTimes.routeId;
    }
    
}


@end
