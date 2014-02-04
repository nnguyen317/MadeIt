//
//  InitViewController.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/18/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+ECSlidingViewController.h"
#import "MEDynamicTransition.h"

@interface InitViewController : ECSlidingViewController <ECSlidingViewControllerDelegate>

@property (nonatomic, strong) MEDynamicTransition *dynamicTransition;

@end
