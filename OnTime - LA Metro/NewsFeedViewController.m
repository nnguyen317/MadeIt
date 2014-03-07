//
//  NewsFeedViewController.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/25/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "NewsFeedViewController.h"
#import "TweetFeedCell.h"
#import "AppDelegate.h"
#import "MenuViewController.h"
#import "MEDynamicTransition.h"
#import "UIViewController+ECSlidingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"

@interface NewsFeedViewController ()
@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) NSString *choice;
@property (nonatomic, strong) NSArray *metroLinkUsers;
@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;
@property BOOL isError;

@end

@implementation NewsFeedViewController
@synthesize dataSource = _dataSource;
@synthesize tweets = _tweets;
@synthesize choice = _choice;
@synthesize metroLinkUsers = _metroLinkUsers;
@synthesize activityIndicator = _activityIndicator;
@synthesize statusView = _statusView;

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
    self.statusView.layer.cornerRadius = 5;
    self.statusView.layer.masksToBounds = YES;
    
    _dataSource = [[NSMutableArray alloc]init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _choice = appDelegate.choice;
    _tweets = [[NSArray alloc]init];
    self.isError = NO;
    self.statusView.hidden = NO;
    self.activityIndicator.hidden = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    
    
    
    //self.activityIndicator.hidden = YES;
    if([_choice isEqualToString:@"Metrolink"]) {
        _metroLinkUsers = @[@"MetrolinkANT",@"MetrolinkIEOC",@"MetrolinkOC",@"MetrolinkRIV",@"MetrolinkSB",@"MetrolinkVC",@"Metrolink91"];
        self.navBarItem.title = _choice;
    } else if([_choice isEqualToString:@"Amtrak"]) {
        _metroLinkUsers = @[@"PACSurfliners"];
        self.navBarItem.title = _choice;
    } else {
        _metroLinkUsers = @[@"metrolaalerts"];
        self.navBarItem.title = _choice;
    }
    
    if(_dataSource.count == 0 || !_dataSource) {
        Reachability *reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        
        reach.reachableBlock = ^(Reachability*reach)
        {
            [self getTimeLine];
        };
        
        reach.unreachableBlock = ^(Reachability*reach)
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Sorry"
                                      message:@"An internet connection is needed to obtain news feed"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [alertView show];
            self.statusView.hidden = YES;
            self.activityIndicator.hidden = YES;
        };
        
        // Start the notifier, which will cause the reachability object to retain itself!
        [reach startNotifier];
        
        
    } else {
        self.statusView.hidden = YES;
        self.activityIndicator.hidden = YES;
    }
    
    //[self getTimeLine];
    
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    /*
    _tweets = [[NSArray alloc]init];
    self.isError = NO;
    self.statusView.hidden = NO;
    self.activityIndicator.hidden = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    
    
    
    //self.activityIndicator.hidden = YES;
    if([_choice isEqualToString:@"Metrolink"]) {
        _metroLinkUsers = @[@"MetrolinkANT",@"MetrolinkIEOC",@"MetrolinkOC",@"MetrolinkRIV",@"MetrolinkSB",@"MetrolinkVC",@"Metrolink91"];
        self.navBarItem.title = _choice;
    } else if([_choice isEqualToString:@"Amtrak"]) {
        _metroLinkUsers = @[@"PACSurfliners"];
        self.navBarItem.title = _choice;
    } else {
        _metroLinkUsers = @[@"metrolaalerts"];
        self.navBarItem.title = _choice;
    }
    
    if(_dataSource.count == 0 || !_dataSource) {
        Reachability *reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        
        reach.reachableBlock = ^(Reachability*reach)
        {
            [self getTimeLine];
        };
        
        reach.unreachableBlock = ^(Reachability*reach)
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Sorry"
                                      message:@"An internet connection is needed to obtain news feed"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [alertView show];
            self.statusView.hidden = YES;
            self.activityIndicator.hidden = YES;
        };
        
        // Start the notifier, which will cause the reachability object to retain itself!
        [reach startNotifier];

        
    } else {
        self.statusView.hidden = YES;
        self.activityIndicator.hidden = YES;
    }
    
    */
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if ([(NSObject *)self.slidingViewController.delegate isKindOfClass:[MEDynamicTransition class]]) {
        MEDynamicTransition *dynamicTransition = (MEDynamicTransition *)self.slidingViewController.delegate;
        if (!self.dynamicTransitionPanGesture) {
            self.dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:dynamicTransition action:@selector(handlePanGesture:)];
        }
        
        [self.navigationController.view removeGestureRecognizer:self.slidingViewController.panGesture];
        [self.navigationController.view addGestureRecognizer:self.dynamicTransitionPanGesture];
    } else {
        [self.navigationController.view removeGestureRecognizer:self.dynamicTransitionPanGesture];
        [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    }
    _revealButton.target = self;
    _revealButton.action = @selector(revealMenu:);
}

-(void)viewWillDisappear:(BOOL)animated {
    self.statusView.hidden = YES;
    self.activityIndicator.hidden = YES;
    
}

-(void)viewDidAppear:(BOOL)animated {
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Set the text color of our header/footer text.
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    header.contentView.backgroundColor = [appDelegate colorWithHexString:@"43677F"];
    
    // You can also do this to set the background color of our header/footer,
    //    but the gradients/other effects will be retained.
    // view.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_dataSource count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSource[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *tweet = [_dataSource[section] firstObject];
    
    return tweet[@"user"][@"name"];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"TweetCell";
    
    TweetFeedCell *cell = [self.tweetTableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TweetFeedCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *tweet = _dataSource[indexPath.section][indexPath.row];
    
    dispatch_queue_t myqueue = dispatch_queue_create("myqueue", NULL);
    
    // execute a task on that queue asynchronously
    dispatch_async(myqueue, ^{
        NSURL *url = [NSURL URLWithString:tweet[@"user"][@"profile_image_url"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.profileImage.image = [UIImage imageWithData:data]; //UI updates should be done on the main thread
        });
    });
    cell.tweetLabel.text = tweet[@"text"];
    cell.dateFooter.text = tweet[@"created_at"];
    return cell;
}


- (void)getTimeLine{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account
                                  accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        [account requestAccessToAccountsWithType:accountType
                                         options:nil completion:^(BOOL granted, NSError *error)
         {
             if (granted == YES)
             {
                 NSArray *arrayOfAccounts = [account
                                             accountsWithAccountType:accountType];
                 
                 if ([arrayOfAccounts count] > 0)
                 {
                     ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                     
                     NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
                     
                     
                     for (NSString *user in _metroLinkUsers){
                         NSMutableDictionary *parameters =
                         [[NSMutableDictionary alloc] init];
                         [parameters setObject:@"10" forKey:@"count"];
                         [parameters setObject:[NSString stringWithFormat:@"%@",user] forKey:@"screen_name"];
                         
                         SLRequest *postRequest = [SLRequest
                                                   requestForServiceType:SLServiceTypeTwitter
                                                   requestMethod:SLRequestMethodGET
                                                   URL:requestURL parameters:parameters];
                         
                         postRequest.account = twitterAccount;
                         
                         [postRequest performRequestWithHandler:
                          ^(NSData *responseData, NSHTTPURLResponse
                            *urlResponse, NSError *error)
                          {
                              
                              if ([urlResponse statusCode] == 200) {
                                  self.isError = NO;
                                  
                                  _tweets = [NSJSONSerialization
                                             JSONObjectWithData:responseData
                                             options:NSJSONReadingMutableLeaves
                                             error:&error];
                                  
                                  if (_tweets.count != 0) {
                                      [self.dataSource addObject:_tweets];
                                      if (_dataSource.count != 0) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self.tweetTableView reloadData];
                                              self.statusView.hidden = YES;
                                              self.activityIndicator.hidden = YES;
                                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                          });
                                      }
                                  }
                              } else {
                                  self.isError = YES;
                              }
                              
                          }];
                         if (self.isError == YES) {
                             UIAlertView *alertView = [[UIAlertView alloc]
                                                       initWithTitle:@"Sorry"
                                                       message:@"Unable to obtain news feed"
                                                       delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                             self.statusView.hidden = YES;
                             self.activityIndicator.hidden = YES;
                             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                             [alertView show];
                             break;
                         }
                     }
                     
                 }
             } else {
                 UIAlertView *alertView = [[UIAlertView alloc]
                                           initWithTitle:@"Sorry"
                                           message:@"Unable to acces your account"
                                           delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                 self.statusView.hidden = YES;
                 self.activityIndicator.hidden = YES;
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                 [alertView show];
             }
             
         }];
    } else {
        SLComposeViewController *fbCompose=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [fbCompose setInitialText:@""];
        [self presentViewController:fbCompose animated:YES completion:nil];
    }
    

}

@end
