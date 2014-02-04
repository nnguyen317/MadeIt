//
//  NewsFeedViewController.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/25/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface NewsFeedViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tweetTableView;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBarItem;


@end
