//
//  InitViewController.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/18/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "InitViewController.h"
#import "METransitions.h"

@interface InitViewController ()
@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;
@property (nonatomic, strong) METransitions *transitions;

@end

@implementation InitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIPanGestureRecognizer *)dynamicTransitionPanGesture {
    if (_dynamicTransitionPanGesture) return _dynamicTransitionPanGesture;
    
    _dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.transitions.dynamicTransition action:@selector(handlePanGesture:)];
    
    return _dynamicTransitionPanGesture;
}

- (METransitions *)transitions {
    if (_transitions) return _transitions;
    
    _transitions = [[METransitions alloc] init];
    
    return _transitions;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.transitions.dynamicTransition.slidingViewController = self.slidingViewController;
    
    self.dynamicTransition = self.transitions.all[0][@"transition"];
    
    id<ECSlidingViewControllerDelegate> transition = self.dynamicTransition;
    self.slidingViewController.delegate = transition;
    
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGestureCustom;
    self.slidingViewController.customAnchoredGestures = @[self.dynamicTransitionPanGesture];

    
    self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Favorites"];
    
    [self.slidingViewController.topViewController.view addGestureRecognizer:self.slidingViewController.panGesture];
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    [self.slidingViewController resetTopViewAnimated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
