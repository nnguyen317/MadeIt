//
//  AppDelegate.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/13/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import <sqlite3.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSString *databaseNameMetroLink;
@property (strong, nonatomic) NSString *databaseNameMetroRail;
@property (strong, nonatomic) NSString *dbPathMetroLink;
@property (strong, nonatomic) NSString *dbPathMetroRail;
@property (strong, nonatomic) NSString *choice;
@property (strong, nonatomic) NSDate *setTime;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
