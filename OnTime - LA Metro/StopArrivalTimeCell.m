//
//  StopArrivalTimeCell.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/22/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import "StopArrivalTimeCell.h"
#import "AppDelegate.h"

@interface StopArrivalTimeCell()
{
    NSTimer *timer;
    NSString *timerText;
}

@end
@implementation StopArrivalTimeCell
@synthesize arrivalTimerLabel   = _arrivalTimerLabel;
@synthesize arrivalTimeLabel    = _arrivalTimeLabel;
@synthesize directionBoundLabel = _directionBoundLabel;
@synthesize currSeconds         = _currSeconds;
@synthesize currMinutes         = _currMinutes;
@synthesize directionId         = _directionId;
@synthesize totalSeconds        = _totalSeconds;
@synthesize deleteFlag = _deleteFlag;
@synthesize arrivalSeconds = _arrivalSeconds;
@synthesize imageView = _imageView;
@synthesize cellKey = _cellKey;
@synthesize doneDelete = _doneDelete;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
                
    }
    
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    
    // Configure the view for the selected state
}

-(void)awakeFromNib {
    
    
    //NSString *boldFontName = @"Bariol-Bold";
    NSString *fontName = @"Bariol-Regular";
    NSString *timerFont = @"ArialRoundedMTBold";
    self.arrivalTimerLabel.font = [UIFont fontWithName:timerFont size:20.0f];
    self.arrivalTimeLabel.font = [UIFont fontWithName:fontName size:12.0f];
    self.directionBoundLabel.font = [UIFont fontWithName:fontName size:14.0f];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = appDelegate.selectionColor;
    self.selectedBackgroundView = bgColorView;
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

-(void)startTimer {
    timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}


- (void)timerFired
{
    /*
    if((self.currMinutes>0 || self.currSeconds>=0) && self.currMinutes>=0) {
        if(self.currSeconds==0) {
            self.currMinutes-=1;
            self.currSeconds=59;
        } else if(self.currSeconds>0) {
            self.currSeconds-=1;
        }
        
        if(self.currMinutes>-1)
        self.arrivalTimerLabel.text = [NSString stringWithFormat:@"%d%@%2d",self.currMinutes,@":",self.currSeconds];
    
    } else {
         [timer invalidate];
    }
    */
    self.totalSeconds -= 1;
    self.currHours   = self.totalSeconds / 3600;
    self.currMinutes = (self.totalSeconds / 60) % 60;
    self.currSeconds = self.totalSeconds % 60;
    
    if (self.totalSeconds >= 0) {
        self.arrivalTimerLabel.text = [NSString stringWithFormat:@"%02d%@%02d%@%02d",self.currHours,@":",self.currMinutes,@":",self.currSeconds];
    }
    
    if(self.totalSeconds <= 0) {
        //[timer invalidate];
        self.arrivalTimerLabel.textColor = [UIColor grayColor];
        self.arrivalTimeLabel.textColor = [UIColor grayColor];
        self.directionBoundLabel.textColor = [UIColor grayColor];
        self.arrivalTimerLabel.text = @"00:00:00";
    }
    

}

- (void)endTimer {
    [timer invalidate];
}

@end
