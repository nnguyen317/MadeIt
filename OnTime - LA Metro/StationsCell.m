//
//  StationsCell.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/27/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import "StationsCell.h"

@implementation StationsCell
@synthesize stationLabel = _stationLabel;

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
