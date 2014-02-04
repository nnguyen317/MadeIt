//
//  MenuViewController.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/15/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEDynamicTransition.h"


@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *choice;
@property (nonatomic, strong) MEDynamicTransition *dynamicTransition;

@end