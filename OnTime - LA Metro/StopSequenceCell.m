//
//  StopSequenceCell.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/20/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "StopSequenceCell.h"

@implementation StopSequenceCell

@synthesize stopName = _stopName;
@synthesize arrivalTime = _arrivalTime;

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
