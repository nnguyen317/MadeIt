//
//  PDFMapZoomViewController.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/18/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFMapZoomViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButton;

@end
