//
//  RootViewController.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/18/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "MEDynamicTransition.h"

@interface RootViewController ()

@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;

@end

@implementation RootViewController

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
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    // Change the tab bar background
    //UIImage *tabBarBackground = [UIImage imageNamed:@"CustomUITabbar.png"];
    [[UITabBar appearance] setTintColor:[UIColor grayColor]];
	// Do any additional setup after loading the view.
    // Add the pan gesture to allow sliding
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
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
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
