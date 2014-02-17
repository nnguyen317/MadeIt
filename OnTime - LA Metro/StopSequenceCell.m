//
//  StopSequenceCell.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/20/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "StopSequenceCell.h"
#import "AppDelegate.h"

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

-(void)awakeFromNib {
    
    
    NSString *boldFontName = @"ArialRoundedMTBold";
    NSString *FontName = @"Bariol-Regular";
    self.arrivalTime.font = [UIFont fontWithName:boldFontName size:14.0f];
    self.stopName.font = [UIFont fontWithName:FontName size:14.0f];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = appDelegate.selectionColor;
    self.selectedBackgroundView = bgColorView;
}

@end
