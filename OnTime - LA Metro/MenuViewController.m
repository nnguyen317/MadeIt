//
//  MenuViewController.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/15/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "MenuViewController.h"
#import "RoutesViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "SideBarCell.h"

@interface MenuViewController ()

@property (strong, nonatomic) NSArray *menu;

@end

@implementation MenuViewController
@synthesize menu = _menu;
@synthesize choice = _choice;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor clearColor];
    
    NSDictionary *object1 = @{@"name":@"Favorites",@"title":@"Favorites"};
    NSDictionary *object2 = @{@"name":@"Metrolink",@"title":@"Metrolink"};
    NSDictionary *object3 = @{@"name":@"Metro Rail",@"title":@"MetroRail"};
    NSDictionary *object4 = @{@"name":@"Rail 2 Rail",@"title":@"Amtrak"};
    NSDictionary *object5 = @{@"name":@"Metrolink Metro Map",@"title":@"MetroMap"};
    
    
    self.menu = @[object1,object2,object3,object4,object5];
    
    
    //[self.slidingViewController setAnchorRightRevealAmount:200.0f];
    //self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
}

- (void)viewWillAppear:(BOOL)animated{
    // Tell it which view should be created under left
  //  if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
    //    self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menu"]
    //}
    // Add the pan gesture to allow sliding
   // [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.menu.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"SidebarCell";
    SideBarCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[SideBarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.titleLabel.text = self.menu[indexPath.row][@"name"];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 46;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"%@",_menu[indexPath.row][@"title"]];
    
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.choice = identifier;
    
    UIViewController *newTopViewController;
    
    self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);
    
    if ([identifier isEqualToString:@"Metrolink"] || [identifier isEqualToString:@"MetroRail"] || [identifier isEqualToString:@"Amtrak"]) {
        
        identifier = [NSString stringWithFormat:@"Metro"];
        
        newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        
    } else {
        
        newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        
    }
    
    self.slidingViewController.topViewController= newTopViewController;
    
    [self.slidingViewController.topViewController.view addGestureRecognizer:self.slidingViewController.panGesture];
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    [self.slidingViewController resetTopViewAnimated:YES];
    
    //self.slidingViewController.underLeftViewController  = newTopViewController;
    /*
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
     */

}




@end
