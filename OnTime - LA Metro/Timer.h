//
//  Timer.h
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 12/20/13.
//  Copyright (c) 2013 Nam Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject {
    NSDate *start;
    NSDate *end;
}

- (void) startTimer;
- (void) stopTimer;
- (double) timeElapsedInSeconds;
- (double) timeElapsedInMilliseconds;
- (double) timeElapsedInMinutes;

@end
