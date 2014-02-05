//
//  Favorites.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 2/3/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Favorites : NSManagedObject

@property (nonatomic, retain) NSString * agency_id;
@property (nonatomic, retain) NSString * direction_id;
@property (nonatomic, retain) NSString * route_id;
@property (nonatomic, retain) NSString * stop_id;
@property (nonatomic, retain) NSString * stop_name;
@property (nonatomic, retain) NSString * trip_headsign;

@end
