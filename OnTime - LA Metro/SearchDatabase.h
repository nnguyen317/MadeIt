//
//  SearchDatabase.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/18/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "FMDatabase.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

@interface SearchDatabase : NSObject

- (NSMutableArray *)searchDatabase: (NSString *)sql withClassName: (NSString *)tableClassName andClass:(id)TableClass forDatabase:(NSString *)databaseName;
- (NSString *)singleQuery:(NSString *)databaseName withDate:(NSString *)date;
- (NSString *)calendarDateQuery:(NSString *)routeId withDate:(NSString *)date andDay:(NSString *)day;
- (NSMutableArray *)regularQuery:(NSString *)sql;

@end
