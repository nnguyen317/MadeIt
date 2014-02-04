//
//  SideBarCell.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/26/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideBarCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UIView *bgView;

@property (nonatomic, weak) IBOutlet UIView *topSeparator;

@property (nonatomic, weak) IBOutlet UIView *bottomSeparator;

@property (nonatomic, weak) IBOutlet UIImageView* iconImageView;


@end
