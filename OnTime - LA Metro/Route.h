//
//  Route.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/15/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Agency.h"

@interface Route : Agency
@property (nonatomic, strong) NSString *routeName;
@property (nonatomic, strong) NSString *routeId;

@end
