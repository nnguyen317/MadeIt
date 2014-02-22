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
    
    NSString *sql = [NSString stringWithFormat:@"SELECT route_id,route_long_name,route_color,route_img FROM routes WHERE agency_id = '%@'",agencyId];
    
    routes = [self databaseSearch:sql withClassName:@"Route" andClass:[Route class] forDatabase:databaseName];
    
    return routes;
}

-(NSMutableArray *) getStopsForRoute: (NSString *) routeId forAgency:(NSString *)agencyId forDatabase:(NSString *)databaseName {
    
    NSMutableArray *stops = [[NSMutableArray alloc] init];
    
    
    NSString *sqlStops = [NSString stringWithFormat:@"SELECT stop_id,stop_name,trip_id,stop_sequence FROM top_stops WHERE agency_id = '%@' and route_id = '%@' ORDER BY stop_sequence",agencyId,routeId];
    
    stops = [self databaseSearch:sqlStops withClassName:@"Stop" andClass:[Stop class] forDatabase:databaseName];
    
    return stops;
}


-(NSMutableArray *) getArrivalTimeFromStop: (NSString *) routeID withStopId: (NSString *)stopId andDirectionId: (NSString *) directionId forAgency:(NSString *)agencyId forDatabase:(NSString *)databaseName  forAll:(BOOL)all {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SearchDatabase *search = [[SearchDatabase alloc] init];
    NSMutableArray *stopTimes = [[NSMutableArray alloc] init];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"EEE"];
    [dateFormatter3 setDateFormat:@"yyyyMMdd"];
    NSDate *today = [NSDate date];
    
    NSString *dayOfWeek = [[NSString alloc] init];
    NSString *dayQuery = [[NSString alloc] init];
    NSString *date = [[NSString alloc]init];
    if(appDelegate.setTime){
        today = appDelegate.setTime;
    }
    
    dayOfWeek = [dateFormatter2 stringFromDate:today];
    date = [dateFormatter3 stringFromDate:today];
    
    NSString *stopSql = [[NSString alloc] init];
    
    if ([dayOfWeek isEqualToString:@"Mon"]){
        dayQuery = @"monday = 1";
    } else if ([dayOfWeek isEqualToString:@"Tue"]){
        dayQuery = @"tuesday = 1";
    } else if ([dayOfWeek isEqualToString:@"Wed"]){
        dayQuery = @"wednesday = 1";
    } else if ([dayOfWeek isEqualToString:@"Thu"]){
        dayQuery = @"thursday = 1";
    } else if ([dayOfWeek isEqualToString:@"Fri"]){
        dayQuery = @"friday = 1";
    } else if ([dayOfWeek isEqualToString:@"Sat"]){
        dayQuery = @"saturday = 1";
    } else if ([dayOfWeek isEqualToString:@"Sun"]){
        dayQuery = @"sunday = 1";
    }
    
    NSString *serviceId = [search calendarDateQuery:routeID withDate:date andDay:dayQuery];
    
    int currentTime = [self getTimeInSeconds];
    
    if ([appDelegate.choice isEqualToString:@"MetroRail"] || [appDelegate.choice isEqualToString:@"Amtrak"]) {
        if (currentTime >= 0 && currentTime <= 14400) {
            
            int newcurrentTime = [self getTimeForAfterMidnight];
            NSString *newDayQuery = [[NSString alloc]init];
            
            if ([dayOfWeek isEqualToString:@"Mon"]){
                newDayQuery = @"sunday = 1";
            } else if ([dayOfWeek isEqualToString:@"Tue"]){
                newDayQuery = @"monday = 1";
            } else if ([dayOfWeek isEqualToString:@"Wed"]){
                newDayQuery = @"tuesday = 1";
            } else if ([dayOfWeek isEqualToString:@"Thu"]){
                newDayQuery = @"wednesday = 1";
            } else if ([dayOfWeek isEqualToString:@"Fri"]){
                newDayQuery = @"thursday = 1";
            } else if ([dayOfWeek isEqualToString:@"Sat"]){
                newDayQuery = @"friday = 1";
            } else if ([dayOfWeek isEqualToString:@"Sun"]){
                newDayQuery = @"saturday = 1";
            }
            
            int epochDate = [today timeIntervalSince1970];
            epochDate -= 86400;
            
            NSDate *newToday = [NSDate dateWithTimeIntervalSince1970:epochDate];
            NSString *newDate = [dateFormatter3 stringFromDate:newToday];
            
            NSString *serviceId2 = [search calendarDateQuery:routeID withDate:newDate andDay:newDayQuery];
            
            if(all == YES) {
                stopSql = [NSString stringWithFormat:@" \
                           SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                           FROM trips as T1                 \
                           JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '%@' AND AND T1.service_id = '%@'                \
                           JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'\
                           JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ AND strftime('%@') between strftime(T4.start_date) and strftime(T4.end_date)  ORDER BY arrival_time",routeID,directionId,serviceId2,stopId,newDayQuery,newDate];
            }  else if ([serviceId2 isEqualToString:@""]) {
                stopSql = [NSString stringWithFormat:@" \
                           SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                           FROM trips as T1                 \
                           JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '0' AND arrival_time > %d              \
                           JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                           JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ AND strftime('%@') between strftime(T4.start_date) and strftime(T4.end_date) \
                           UNION \
                           SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                           FROM trips as T1                 \
                           JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '1' AND arrival_time > %d                \
                           JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                           JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ AND strftime('%@') between strftime(T4.start_date) and strftime(T4.end_date)\
                           ORDER BY arrival_time",routeID,currentTime,stopId,dayQuery,newDate,routeID,currentTime,stopId,dayQuery,newDate];
            } else {
                stopSql = [NSString stringWithFormat:@" \
                           SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                           FROM trips as T1                 \
                           JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '0' AND arrival_time > %d AND T1.service_id = '%@'                \
                           JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                           JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ \
                           UNION \
                           SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                           FROM trips as T1                 \
                           JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '1' AND arrival_time > %d AND T1.service_id = '%@'                \
                           JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                           JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ \
                           ORDER BY arrival_time",routeID,newcurrentTime,serviceId2,stopId,newDayQuery,routeID,newcurrentTime,serviceId2,stopId,newDayQuery];
            }
            
            NSMutableArray *stopTimes2 = [[NSMutableArray alloc]init];
            stopTimes2 = [self databaseSearch:stopSql withClassName:@"StopTimes" andClass:[StopTimes class] forDatabase:databaseName];
            [stopTimes addObjectsFromArray:stopTimes2];
        }
        
    }
    
    if (all == YES) {
        if ([serviceId isEqualToString:@""]) {
            stopSql = [NSString stringWithFormat:@" \
                       SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                       FROM trips as T1                 \
                       JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '%@'                \
                       JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                       JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ AND strftime('%@') between strftime(T4.start_date) and strftime(T4.end_date) ORDER BY arrival_time\
                       ",routeID,directionId,stopId,dayQuery,date];
        } else {
            stopSql = [NSString stringWithFormat:@" \
                       SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                       FROM trips as T1                 \
                       JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '%@' AND T1.service_id = '%@'                \
                       JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                       JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ AND strftime('%@') between strftime(T4.start_date) and strftime(T4.end_date) ORDER BY arrival_time\
                       ",routeID,directionId,serviceId,stopId,dayQuery,date];
        }
    } else if ([serviceId isEqualToString:@""]) {
        stopSql = [NSString stringWithFormat:@" \
                   SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                   FROM trips as T1                 \
                   JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '0' AND arrival_time > %d              \
                   JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                   JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ AND strftime('%@') between strftime(T4.start_date) and strftime(T4.end_date) \
                   UNION \
                   SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                   FROM trips as T1                 \
                   JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '1' AND arrival_time > %d                \
                   JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                   JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ AND strftime('%@') between strftime(T4.start_date) and strftime(T4.end_date)\
                   ORDER BY arrival_time",routeID,currentTime,stopId,dayQuery,date,routeID,currentTime,stopId,dayQuery,date];
    } else {
        stopSql = [NSString stringWithFormat:@" \
                   SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                   FROM trips as T1                 \
                   JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '0' AND arrival_time > %d AND T1.service_id = '%@'                \
                   JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                   JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ \
                   UNION \
                   SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                   FROM trips as T1                 \
                   JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '1' AND arrival_time > %d AND T1.service_id = '%@'                \
                   JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                   JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ \
                   ORDER BY arrival_time",routeID,currentTime,serviceId,stopId,dayQuery,routeID,currentTime,serviceId,stopId,dayQuery];
    }
    
    [stopTimes addObjectsFromArray:[self databaseSearch:stopSql withClassName:@"StopTimes" andClass:[StopTimes class] forDatabase:databaseName]];
    
    return stopTimes;
    
}

-(id) getArrivalTimeFromStopSingle: (NSString *) routeID withStopId: (NSString *)stopId andDirectionId: (NSString *) directionId forAgency:(NSString *)agencyId forDatabase:(NSString *)databaseName {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SearchDatabase *search = [[SearchDatabase alloc] init];
    NSMutableArray *stopTimes = [[NSMutableArray alloc] init];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"EEE"];
    [dateFormatter3 setDateFormat:@"yyyyMMdd"];
    NSDate *today = [NSDate date];
    
    NSString *dayOfWeek = [[NSString alloc] init];
    NSString *dayQuery = [[NSString alloc] init];
    NSString *date = [[NSString alloc]init];
    if(appDelegate.setTime){
        today = appDelegate.setTime;
    }
    
    dayOfWeek = [dateFormatter2 stringFromDate:today];
    date = [dateFormatter3 stringFromDate:today];
    
    NSString *stopSql = [[NSString alloc] init];
    
    if ([dayOfWeek isEqualToString:@"Mon"]){
        dayQuery = @"monday = 1";
    } else if ([dayOfWeek isEqualToString:@"Tue"]){
        dayQuery = @"tuesday = 1";
    } else if ([dayOfWeek isEqualToString:@"Wed"]){
        dayQuery = @"wednesday = 1";
    } else if ([dayOfWeek isEqualToString:@"Thu"]){
        dayQuery = @"thursday = 1";
    } else if ([dayOfWeek isEqualToString:@"Fri"]){
        dayQuery = @"friday = 1";
    } else if ([dayOfWeek isEqualToString:@"Sat"]){
        dayQuery = @"saturday = 1";
    } else if ([dayOfWeek isEqualToString:@"Sun"]){
        dayQuery = @"sunday = 1";
    }
    
    NSString *serviceId = [search calendarDateQuery:routeID withDate:date andDay:dayQuery];
    
    int currentTime = [self getTimeInSeconds];
    
    if ([appDelegate.choice isEqualToString:@"MetroRail"]) {
        if (currentTime >= 0 && currentTime <= 14400) {
            
            int newcurrentTime = [self getTimeForAfterMidnight];
            NSString *newDayQuery = [[NSString alloc]init];
            
            if ([dayOfWeek isEqualToString:@"Mon"]){
                newDayQuery = @"sunday = 1";
            } else if ([dayOfWeek isEqualToString:@"Tue"]){
                newDayQuery = @"monday = 1";
            } else if ([dayOfWeek isEqualToString:@"Wed"]){
                newDayQuery = @"tuesday = 1";
            } else if ([dayOfWeek isEqualToString:@"Thu"]){
                newDayQuery = @"wednesday = 1";
            } else if ([dayOfWeek isEqualToString:@"Fri"]){
                newDayQuery = @"thursday = 1";
            } else if ([dayOfWeek isEqualToString:@"Sat"]){
                newDayQuery = @"friday = 1";
            } else if ([dayOfWeek isEqualToString:@"Sun"]){
                newDayQuery = @"saturday = 1";
            }
            
            int epochDate = [today timeIntervalSince1970];
            epochDate -= 86400;
            
            NSDate *newToday = [NSDate dateWithTimeIntervalSince1970:epochDate];
            NSString *newDate = [dateFormatter3 stringFromDate:newToday];
            
            NSString *serviceId2 = [search calendarDateQuery:routeID withDate:newDate andDay:newDayQuery];
            /*
            stopSql = [NSString stringWithFormat:@"SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence \
                       FROM trips as T1 \
                       JOIN \
                       stop_times as T2 \
                       on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '%@' AND arrival_time > %d AND T1.service_id = '%@'\
                       JOIN stops as T3 \
                       on T2.stop_id=T3.stop_id AND T3.stop_id = '%@' \
                       JOIN calendar as T4 \
                       on T1.service_id=T4.service_id AND T4.%@ ORDER BY T2.arrival_time LIMIT 1",routeID,directionId,newcurrentTime,serviceId2,stopId,newDayQuery];
            */
            if ([serviceId2 isEqualToString:@""]) {
                stopSql = [NSString stringWithFormat:@" \
                           SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                           FROM trips as T1                 \
                           JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '%@' AND arrival_time > %d              \
                           JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                           JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ AND strftime('%@') between strftime(T4.start_date) and strftime(T4.end_date) ORDER BY T2.arrival_time ASC LIMIT 1",routeID,directionId,currentTime,stopId,newDayQuery,newDate];
            } else {
                stopSql = [NSString stringWithFormat:@" \
                           SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                           FROM trips as T1                 \
                           JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '%@' AND arrival_time > %d AND T1.service_id = '%@'                \
                           JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                           JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@  ORDER BY T2.arrival_time ASC LIMIT 1",routeID,directionId,currentTime,serviceId2,stopId,newDayQuery];
            }
            NSMutableArray *stopTimes2 = [[NSMutableArray alloc]init];
            stopTimes2 = [self databaseSearch:stopSql withClassName:@"StopTimes" andClass:[StopTimes class] forDatabase:databaseName];
            [stopTimes addObjectsFromArray:stopTimes2];
        } else {
            /*
            stopSql = [NSString stringWithFormat:@"SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence \
                       FROM trips as T1 \
                       JOIN \
                       stop_times as T2 \
                       on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '%@' AND arrival_time > %d AND T1.service_id = '%@' \
                       JOIN stops as T3 \
                       on T2.stop_id=T3.stop_id AND T3.stop_id = '%@' \
                       JOIN calendar as T4 \
                       on T1.service_id=T4.service_id AND T4.%@ ORDER BY T2.arrival_time LIMIT 1",routeID,directionId,currentTime,serviceId,stopId,dayQuery];
             */
            if ([serviceId isEqualToString:@""]) {
                stopSql = [NSString stringWithFormat:@" \
                           SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                           FROM trips as T1                 \
                           JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '%@' AND arrival_time > %d              \
                           JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                           JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ AND strftime('%@') between strftime(T4.start_date) and strftime(T4.end_date)  ORDER BY T2.arrival_time ASC LIMIT 1",routeID,directionId,currentTime,stopId,dayQuery,date];
            } else {
                stopSql = [NSString stringWithFormat:@" \
                           SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                           FROM trips as T1                 \
                           JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '%@' AND arrival_time > %d AND T1.service_id = '%@'                \
                           JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                           JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@  ORDER BY T2.arrival_time ASC LIMIT 1",routeID,directionId,currentTime,serviceId,stopId,dayQuery];
            }
            
            [stopTimes addObjectsFromArray:[self databaseSearch:stopSql withClassName:@"StopTimes" andClass:[StopTimes class] forDatabase:databaseName]];
        }
        
    } else {
        if ([serviceId isEqualToString:@""]) {
            stopSql = [NSString stringWithFormat:@" \
                       SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                       FROM trips as T1                 \
                       JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '%@' AND arrival_time > %d              \
                       JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                       JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@ AND strftime('%@') between strftime(T4.start_date) and strftime(T4.end_date)  ORDER BY T2.arrival_time ASC LIMIT 1",routeID,directionId,currentTime,stopId,dayQuery,date];
        } else {
            stopSql = [NSString stringWithFormat:@" \
                       SELECT T3.stop_name,T2.arrival_time,T1.direction_id, T1.trip_headsign,T1.trip_id,T2.stop_sequence  \
                       FROM trips as T1                 \
                       JOIN stop_times as T2 on T1.trip_id=T2.trip_id AND route_id = '%@' AND direction_id = '%@' AND arrival_time > %d AND T1.service_id = '%@'                \
                       JOIN stops as T3 on T2.stop_id=T3.stop_id AND T3.stop_id = '%@'                 \
                       JOIN calendar as T4 on T1.service_id=T4.service_id AND T4.%@  ORDER BY T2.arrival_time ASC LIMIT 1",routeID,directionId,currentTime,serviceId,stopId,dayQuery];
        }
        
        [stopTimes addObjectsFromArray:[self databaseSearch:stopSql withClassName:@"StopTimes" andClass:[StopTimes class] forDatabase:databaseName]];
    }
    
    
    
    return stopTimes;
}

- (id)getStopSequenceArrivalTimes:(NSString *) routeID withTripId:(NSString *)tripId withStopSequence:(NSString *)stopSequence
{
    NSMutableArray *stopSequences = [[NSMutableArray alloc]init];
    NSString *stopSql = [[NSString alloc]init];
    
    stopSql = [NSString stringWithFormat:@"select s.stop_name,st.arrival_time from trips t JOIN stop_times st on (st.trip_id = t.trip_id) and st.trip_id = '%@' AND t.route_id = '%@' JOIN stops s on (st.stop_id = s.stop_id) AND st.stop_sequence >= %@ ORDER BY st.stop_sequence",tripId,routeID,stopSequence];
    
    stopSequences = [self databaseSearch:stopSql withClassName:@"StopTimes" andClass:[StopTimes class] forDatabase:@""];
    
    return stopSequences;
}


- (id)getStopBounds:(NSString *) routeID
{
    NSMutableArray *directionBound = [[NSMutableArray alloc]init];
    NSString *sql = [[NSString alloc]init];
    SearchDatabase *searchDB = [[SearchDatabase alloc] init];
    sql = [NSString stringWithFormat:@" \
           select trip_headsign,direction_id,count(trip_id) as C \
           FROM trips t \
           WHERE \
           route_id = '%@' AND \
           direction_id = 0 \
           UNION \
           select trip_headsign,direction_id,count(trip_id) as C \
           FROM trips t \
           WHERE \
           route_id = '%@' AND \
           direction_id = 1 \
           GROUP BY trip_headsign \
           ORDER BY C DESC \
           LIMIT 2 \
           ",routeID,routeID];
    
    directionBound = [searchDB regularQuery:sql];
    
    return directionBound;
}

-(NSMutableArray *) databaseSearch: (NSString *)sql withClassName:(NSString*)className andClass:(id)ThisClass forDatabase:(NSString *)databaseName {
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    SearchDatabase *searchTable = [[SearchDatabase alloc] init];
    resultArray = [searchTable searchDatabase:sql withClassName:className andClass:ThisClass forDatabase:databaseName];
    
    return resultArray;
}


-(int)getTotalSecondsFromDate:(NSString *)arrivalTimeString{
    
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
    
    int totalSeconds = [arrivalTimeString integerValue] - time;
    return totalSeconds;
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

-(int)getTimeForAfterMidnight {
    
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
            if ([item integerValue] >= 0 && [item integerValue] <= 3) {
                tempInt = ([item integerValue] *  3600) + 86400;
            } else {
                tempInt = [item integerValue] * 3600;
            }
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
    NSString *time = @" AM";
    
    int thisHour = 0;
    
    if(seconds >= 86400) {
        seconds -= 86400;
    }
    
    thisHour = seconds / 3600;
    int thisMinute = (seconds / 60) % 60;
    int thisSecond = seconds % 60;
    
    if (thisHour > 12 ) {
        thisHour -= 12;
        time = @" PM";
    } else if (thisHour == 12) {
        time = @" PM";
    } else if (thisHour == 0) {
        thisHour = 12;
        time = @" AM";
    }
    
    if(thisSecond > 0) {
        thisMinute += 1;
    }
    
    return [NSString stringWithFormat:@"%02d%@%02d%@",thisHour,@":",thisMinute,time];
}

@end