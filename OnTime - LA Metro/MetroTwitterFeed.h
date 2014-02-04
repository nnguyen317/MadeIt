//
//  MetroTwitterFeed.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/19/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface MetroTwitterFeed : NSObject

@property (nonatomic, strong) NSArray *dataSource;
- (NSArray *)getTimeLine;

@end
