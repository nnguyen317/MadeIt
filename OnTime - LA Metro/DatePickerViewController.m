//
//  DatePickerViewController.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/24/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "DatePickerViewController.h"
#import "AppDelegate.h"

@interface DatePickerViewController ()

@end

@implementation DatePickerViewController

@synthesize datePicker = _datePicker;


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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)cancelPress:(id)sender{
    [self dismissViewControllerAnimated:YES completion:NULL];

}


- (IBAction)Ogay:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.setTime = [_datePicker date];
    [self dismissViewControllerAnimated:YES completion:NULL];

}

- (IBAction)current:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.setTime = nil;
    [self dismissViewControllerAnimated:YES completion:NULL];
}





@end
