//
//  TweetFeedCell.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/19/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "TweetFeedCell.h"

@implementation TweetFeedCell

@synthesize profileImage = _profileImage;
@synthesize tweetLabel = _tweetLabel;
@synthesize dateFooter = _dateFooter;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
