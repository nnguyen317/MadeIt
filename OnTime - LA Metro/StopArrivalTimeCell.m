//
//  StopArrivalTimeCell.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/22/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import "StopArrivalTimeCell.h"

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
