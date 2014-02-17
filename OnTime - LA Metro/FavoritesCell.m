//
//  FavoritesCell.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 2/3/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "FavoritesCell.h"
#import "AppDelegate.h"

@implementation FavoritesCell
@synthesize imageView = _imageView;

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
    
    
    NSString *boldFontName = @"Bariol-Bold";
    NSString *FontName = @"Bariol-Regular";
    self.directionBoundLabel.font = [UIFont fontWithName:FontName size:16.0f];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = appDelegate.selectionColor;
    self.selectedBackgroundView = bgColorView;
}
@end
