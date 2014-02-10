//
//  SideBarCell.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/26/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "SideBarCell.h"

@implementation SideBarCell

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

-(void)awakeFromNib{
    
    self.bgView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    
    self.topSeparator.backgroundColor = [UIColor colorWithWhite:0.1f alpha:1.0f];
    self.bottomSeparator.backgroundColor = [UIColor colorWithWhite:0.3f alpha:1.0f];
    
    NSString* boldFontName = @"Harabara";
    
    self.titleLabel.textColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    self.titleLabel.font = [UIFont fontWithName:boldFontName size:16.0f];
    
}

@end
