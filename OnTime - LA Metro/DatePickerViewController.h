//
//  DatePickerViewController.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/24/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *useCurrentButton;
- (IBAction)cancelPress:(id)sender;
- (IBAction)Ogay:(id)sender;
- (IBAction)current:(id)sender;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;


@end
