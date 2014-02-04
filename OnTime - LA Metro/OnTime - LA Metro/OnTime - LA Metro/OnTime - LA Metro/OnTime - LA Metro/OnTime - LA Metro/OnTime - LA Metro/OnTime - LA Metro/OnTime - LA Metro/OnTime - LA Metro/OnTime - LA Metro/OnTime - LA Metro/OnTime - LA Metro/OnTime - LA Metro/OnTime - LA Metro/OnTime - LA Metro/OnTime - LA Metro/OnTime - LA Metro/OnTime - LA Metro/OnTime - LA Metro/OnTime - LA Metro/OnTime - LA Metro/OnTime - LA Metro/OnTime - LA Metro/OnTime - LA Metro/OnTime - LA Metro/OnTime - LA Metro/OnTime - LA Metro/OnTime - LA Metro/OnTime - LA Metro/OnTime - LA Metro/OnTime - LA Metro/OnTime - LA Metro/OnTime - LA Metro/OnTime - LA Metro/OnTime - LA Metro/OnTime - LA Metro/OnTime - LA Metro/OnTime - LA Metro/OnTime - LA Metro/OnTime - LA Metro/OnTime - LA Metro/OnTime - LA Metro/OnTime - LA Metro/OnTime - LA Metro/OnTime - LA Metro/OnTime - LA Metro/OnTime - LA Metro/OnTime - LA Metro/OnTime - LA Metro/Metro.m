//
//  Metro.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/17/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import "Metro.h"

@implementation Metro

-(NSMutableArray *) getMetroAgencyList:(NSString *)databaseName {
    
    NSString *sql = @"SELECT agency_id,agency_name FROM agency";
    NSMutableArray *agencyList = [[NSMutableArray alloc] init];
    
    agencyList = [self databaseSearch:sql withClassName:@"Agency" andClass:[Agency class] forDatabase:databaseName];
    
    return agencyList;
}

-(NSMutableArray *) getRoutes: (NSString *)agencyId forDatabase:(NSString *)databaseName {
    
    NSMutableArray *routes = [[NSMutableArray alloc] init];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT route_id,route_long_name FROM routes WHERE agency_id = '%@'",agencyId];
    
    routes = [self databaseSearch:sql withClassName:@"Route" andClass:[Route class] forDatabase:databaseName];

    return routes;
}

-(NSMutableArray *) getStopsForRoute: (NSString *) routeId forAgency:(NSString *)agencyId forDatabase:(NSString *)databaseName {
    
    NSMutableArray *stops = [[NSMutableArray alloc] init];
    
    //NSString *sqlStops = [NSString stringWithFormat:@"select st.stop_id,s.stop_name,t.trip_id from trips t, stop_times st,stops s where (t.trip_id = st.trip_id) and (s.stop_id = st.stop_id) and t.trip_id = (SELECT t.trip_id FROM trips t,routes r, stop_times st  WHERE (t.route_id = r.route_id) AND (st.trip_id = t.trip_id) and t.direction_id = 0 and r.route_id = '%@' AND r.agency_id = '%@' GROUP BY t.trip_id HAVING COUNT(*) = (SELECT count(*) as c FROM trips t,routes r, stop_times st  WHERE (t.route_id = r.route_id) AND (st.trip_id = t.trip_id) and t.direction_id = 0 AND r.route_id = '%@' AND r.agency_id = '%@' GROUP BY t.trip_id order by c desc limit 1) LIMIT 1) ORDER BY st.stop_sequence",routeId,agencyId,routeId,agencyId];
    
    NSString *sqlStops = [NSString stringWithFormat:@"SELECT s.stop_id,s.stop_name,t.trip_id,st.stop_sequence FROM trips t INNER JOIN routes r on (r.route_id = t.route_id) INNER JOIN agency a on (a.agency_id = r.agency_id) INNER JOIN stop_times st on (st.trip_id = t.trip_id) INNER JOIN stops s on (s.stop_id = st.stop_id) WHERE a.agency_id = '%@' and r.route_id = '%@' AND t.direction_id = '0' AND t.trip_id = (SELECT top_trip_id from trips WHERE route_id = '%@' and direction_id = '0' LIMIT 1) ORDER by st.stop_sequence ASC",agencyId,routeId,routeId];
    
    stops = [self databaseSearch:sqlStops withClassName:@"Stop" andClass:[Stop class] forDatabase:databaseName];
    
    return stops;
}


-(NSMutableArray *) getArrivalTimeFromStop: (NSString *) routeID withStopId: (NSString *)stopId andDirectionId: (NSString *) directionId forAgency:(NSString *)agencyId forDatabase:(NSString *)databaseName {
    
    
    NSMutableArray *stopTimes = [[NSMutableArray alloc] init];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"EEE"];
    [dateFormatter3 setDateFormat:@"yyyyMMdd"];
    NSDate *today = [NSDate date];
    NSString *dayOfWeek = [dateFormatter2 stringFromDate:today];
    NSString *stopSql = [[NSString alloc] init];
    
    if ([dayOfWeek isEqualToString:@"Mon"]){
        dayOfWeek = @"monday = 1";
    } else if ([dayOfWeek isEqualToString:@"Tue"]){
        dayOfWeek = @"tuesday = 1";
    } else if ([dayOfWeek isEqualToString:@"Wed"]){
        dayOfWeek = @"wednesday = 1";
    } else if ([dayOfWeek isEqualToString:@"Thu"]){
        dayOfWeek = @"thursday = 1";
    } else if ([dayOfWeek isEqualToString:@"Fri"]){
        dayOfWeek = @"friday = 1";
    } else if ([dayOfWeek isEqualToString:@"Sat"]){
        dayOfWeek = @"saturday = 1";
    } else if ([dayOfWeek isEqualToString:@"Sun"]){
        dayOfWeek = @"sunday = 1";
    }
    
    int currentTime = [self getTimeInSeconds];
    
        stopSql = [NSString stringWithFormat:@"SELECT s.stop_name,st.arrival_time,t.direction_id, t.trip_headsign FROM trips t INNER JOIN stop_times st on (st.trip_id = t.trip_id) INNER JOIN stops s on (s.stop_id = st.stop_id) INNER JOIN routes r on (r.route_id = t.route_id) INNER JOIN agency a on (a.agency_id = r.agency_id) INNER JOIN calendar c on (c.service_id = t.service_id) WHERE st.stop_id = '%@' AND r.route_id = '%@' AND a.agency_id = '%@' AND st.arrival_time > '%d' AND t.direction_id = '%@' and c.%@  GROUP BY st.arrival_time ORDER BY st.arrival_time",stopId,routeID,agencyId,currentTime,directionId,dayOfWeek];
    
    stopTimes = [self databaseSearch:stopSql withClassName:@"StopTimes" andClass:[StopTimes class] forDatabase:databaseName];
    
    return stopTimes;
    
}

-(id) getArrivalTimeFromStopSingle: (NSString *) routeID withStopId: (NSString *)stopId andDirectionId: (NSString *) directionId forAgency:(NSString *)agencyId forDatabase:(NSString *)databaseName {
    
    NSMutableArray *stopTimes = [[NSMutableArray alloc] init];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"EEE"];
    [dateFormatter3 setDateFormat:@"yyyyMMdd"];
    NSDate *today = [NSDate date];
    NSString *dayOfWeek = [dateFormatter2 stringFromDate:today];
    NSString *stopSql = [[NSString alloc] init];
    
    if ([dayOfWeek isEqualToString:@"Mon"]){
        dayOfWeek = @"monday = 1";
    } else if ([dayOfWeek isEqualToString:@"Tue"]){
        dayOfWeek = @"tuesday = 1";
    } else if ([dayOfWeek isEqualToString:@"Wed"]){
        dayOfWeek = @"wednesday = 1";
    } else if ([dayOfWeek isEqualToString:@"Thu"]){
        dayOfWeek = @"thursday = 1";
    } else if ([dayOfWeek isEqualToString:@"Fri"]){
        dayOfWeek = @"friday = 1";
    } else if ([dayOfWeek isEqualToString:@"Sat"]){
        dayOfWeek = @"saturday = 1";
    } else if ([dayOfWeek isEqualToString:@"Sun"]){
        dayOfWeek = @"sunday = 1";
    }
    
    int currentTime = [self getTimeInSeconds];
    
    stopSql = [NSString stringWithFormat:@"SELECT s.stop_name,st.arrival_time,t.direction_id, t.trip_headsign FROM trips t INNER JOIN stop_times st on (st.trip_id = t.trip_id) INNER JOIN stops s on (s.stop_id = st.stop_id) INNER JOIN routes r on (r.route_id = t.route_id) INNER JOIN agency a on (a.agency_id = r.agency_id) INNER JOIN calendar c on (c.service_id = t.service_id) INNER JOIN calendar_dates cc on (cc.service_id = c.service_id) WHERE st.stop_id = '%@' AND r.route_id = '%@' AND a.agency_id = '%@' AND st.arrival_time > %d AND t.direction_id = '%@' and c.%@  GROUP BY st.arrival_time ORDER BY st.arrival_time LIMIT 1",stopId,routeID,agencyId,currentTime,directionId,dayOfWeek];
    
    stopTimes = [self databaseSearch:stopSql withClassName:@"StopTimes" andClass:[StopTimes class] forDatabase:databaseName];
    
    return stopTimes;
    
}

-(NSMutableArray *) databaseSearch: (NSString *)sql withClassName:(NSString*)className andClass:(id)ThisClass forDatabase:(NSString *)databaseName {
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    SearchDatabase *searchTable = [[SearchDatabase alloc] init];
    resultArray = [searchTable searchDatabase:sql withClassName:className andClass:ThisClass forDatabase:databaseName];
    
    return resultArray;
}

-(int)getTotalSecondsFromDate:(NSString *)arrivalTimeString{
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *today = [NSDate date];
    NSString *currentTimeString = [timeFormatter stringFromDate:today];
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
    
    int totalSeconds = [arrivalTimeString integerValue] - time;
    return totalSeconds;
}

-(int)getTimeInSeconds {
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *today = [NSDate date];
    NSString *currentTimeString = [timeFormatter stringFromDate:today];
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

@end
