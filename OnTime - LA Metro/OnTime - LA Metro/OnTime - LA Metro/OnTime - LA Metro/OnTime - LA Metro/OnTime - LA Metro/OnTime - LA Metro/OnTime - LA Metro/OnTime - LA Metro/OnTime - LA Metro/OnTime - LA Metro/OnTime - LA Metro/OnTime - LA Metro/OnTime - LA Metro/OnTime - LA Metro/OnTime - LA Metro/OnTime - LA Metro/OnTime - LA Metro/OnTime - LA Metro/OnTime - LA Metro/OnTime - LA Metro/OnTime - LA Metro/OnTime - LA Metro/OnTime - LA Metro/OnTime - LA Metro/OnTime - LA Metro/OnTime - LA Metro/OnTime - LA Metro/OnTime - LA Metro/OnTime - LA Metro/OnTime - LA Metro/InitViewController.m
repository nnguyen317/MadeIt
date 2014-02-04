//
//  InitViewController.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/15/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "InitViewController.h"

@interface InitViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"favorites"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
