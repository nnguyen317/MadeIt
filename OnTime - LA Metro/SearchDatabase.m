//
//  SearchDatabase.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/18/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import "SearchDatabase.h"

@implementation SearchDatabase

-(NSMutableArray *)searchDatabase: (NSString *)sql withClassName: (NSString *)tableClassName andClass:(id)TableClass forDatabase:(NSString *)databaseName {
    unsigned int count;
    NSMutableArray *tableArrayWithOjbects = [[NSMutableArray alloc] init];
    NSString *dbPath = [[NSString alloc] init];
    
    dbPath = [(AppDelegate *) [[UIApplication sharedApplication] delegate] dbPathMetroLink];
    
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    [database open];
    FMResultSet *results = [database executeQuery:sql];

    Ivar *vars = class_copyIvarList(TableClass, &count);

    while ([results next]) {
        id thisObject = [[NSClassFromString(tableClassName) alloc] init];
        for (NSUInteger i=0; i<count; i++) {
            Ivar var = vars[i];
            object_setIvar(thisObject, var, [results stringForColumnIndex:i]);
        }
        [tableArrayWithOjbects addObject:thisObject];
    }
    
    free(vars);
    [database close];
    
    return tableArrayWithOjbects;
}

-(NSString *)singleQuery:(NSString *)databaseName withDate:(NSString *)date {
    NSString *serviceId = [[NSString alloc] init];
    NSString *dbPath = [[NSString alloc] init];
    NSString *sql = [NSString stringWithFormat:@"SELECT service_id FROM calendar_dates WHERE date = '%@'",date];
    
    if([databaseName isEqualToString:@"Metrolink"]) {
        dbPath = [(AppDelegate *) [[UIApplication sharedApplication] delegate] dbPathMetroLink];
    } else if ([databaseName isEqualToString:@"MetroRail" ]){
        dbPath = [(AppDelegate *) [[UIApplication sharedApplication] delegate] dbPathMetroRail];
    }
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    [database open];
    FMResultSet *results = [database executeQuery:sql];
    
    
    while ([results next]) {
        
        serviceId = [results stringForColumn:@"service_id"];
        
    }
    [database close];
    
    return serviceId;
}

-(NSString *)calendarDateQuery:(NSString *)routeId withDate:(NSString *)date andDay:(NSString *)day {
    NSDictionary *calendarDate = [[NSDictionary alloc] init];
    NSString *serviceId = [[NSString alloc]init];
    
    NSString *dbPath = [[NSString alloc] init];
    NSString *sql = [NSString stringWithFormat:@"SELECT cd.* FROM trips t JOIN calendar_dates cd on (cd.service_id = t.service_id) WHERE t.route_id = '%@' AND cd.date = '%@' ORDER BY exception_type ASC LIMIT 1",routeId,date];
    
    dbPath = [(AppDelegate *) [[UIApplication sharedApplication] delegate] dbPathMetroLink];
  
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    [database open];
    FMResultSet *results = [database executeQuery:sql];
    
    
    while ([results next]) {
        calendarDate = @{@"service_id":[results stringForColumn:@"service_id"],
                         @"exception":[results stringForColumn:@"exception_type"],
                         @"date":[results stringForColumn:@"exception_type"]};
    }
    
    
    if(calendarDate.count > 0) {
        if([calendarDate[@"exception"] isEqualToString:@"2"]) {
            NSString *sql2 = [NSString stringWithFormat:@"SELECT t.service_id FROM trips t,calendar c WHERE (c.service_id = t.service_id) and t.route_id = '%@' AND t.service_id <> '%@' AND c.%@ LIMIT 1",routeId,calendarDate[@"service_id"],day];
            FMResultSet *results2 = [database executeQuery:sql2];
            while ([results2 next]) {
                serviceId = [results2 stringForColumn:@"service_id"];
            }
        } else if ([calendarDate[@"exception"] isEqualToString:@"1"]) {
            serviceId = calendarDate[@"service_id"];
        }
    } else {
        NSString *sql2 = [NSString stringWithFormat:@"SELECT t.service_id FROM trips t,calendar c WHERE (c.service_id = t.service_id) and t.route_id = '%@' AND c.%@ LIMIT 1",routeId,day];
        FMResultSet *results2 = [database executeQuery:sql2];
        while ([results2 next]) {
            serviceId = [results2 stringForColumn:@"service_id"];
        }

    }
    
    [database close];
    
    return serviceId;
}

-(NSMutableArray *)regularQuery:(NSString *)sql {
    
    NSString *dbPath = [[NSString alloc] init];
    NSMutableArray *resultQuery = [[NSMutableArray alloc] init];
    
    dbPath = [(AppDelegate *) [[UIApplication sharedApplication] delegate] dbPathMetroLink];
    
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    [database open];
    FMResultSet *results = [database executeQuery:sql];
    
    
    while ([results next]) {
        [resultQuery addObject:[results resultDictionary]];
    }
    
    
    
    [database close];
    
    return resultQuery;
}

@end
