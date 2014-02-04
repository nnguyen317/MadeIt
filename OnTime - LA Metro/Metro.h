//
//  Metro.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/17/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchDatabase.h"
#import <objc/runtime.h>
#import "Agency.h"
#import "Route.h"
#import "Stop.h"
#import "StopTimes.h"

@interface Metro : NSObject

- (NSMutableArray *) getMetroAgencyList:(NSString *)databaseName;
- (NSMutableArray *) getRoutes: (NSString *)agencyId forDatabase:(NSString *)databaseName;
- (NSMutableArray *) getStopsForRoute: (NSString *) routeId forAgency:(NSString *)agencyId forDatabase:(NSString *)databaseName;
-(NSMutableArray *) getArrivalTimeFromStop: (NSString *) routeID withStopId: (NSString *)stopId andDirectionId: (NSString *) directionId forAgency:(NSString *)agencyId forDatabase:(NSString *)databaseName  forAll:(BOOL)all;
- (id) getArrivalTimeFromStopSingle: (NSString *) routeID withStopId: (NSString *)stopId andDirectionId: (NSString *) directionId forAgency:(NSString *)agencyId forDatabase:(NSString *)databaseName;
- (int)getTotalSecondsFromDate:(NSString *)arrivalTimeString;
- (NSString *)convertToTime:(int)seconds;
- (id)getStopSequenceArrivalTimes:(NSString *) routeID withTripId:(NSString *)tripId withStopSequence:(NSString *)stopSequence;
- (id)getStopBounds:(NSString *) routeID;

@end
