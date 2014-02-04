//
//  TweetFeedCell.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/19/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetFeedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *dateFooter;

@end
