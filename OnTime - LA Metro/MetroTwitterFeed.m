//
//  MetroTwitterFeed.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/19/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "MetroTwitterFeed.h"

@implementation MetroTwitterFeed

@synthesize dataSource = _dataSource;

- (NSArray *)getTimeLine {
    _dataSource = [[NSArray alloc]init];
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account
                                  accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType
                                     options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSArray *arrayOfAccounts = [account
                                         accountsWithAccountType:accountType];
             
             if ([arrayOfAccounts count] > 0)
             {
                 ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                 
                 NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
                 
                 NSMutableDictionary *parameters =
                 [[NSMutableDictionary alloc] init];
                 [parameters setObject:@"Metrolink" forKey:@"screen_name"];
                 [parameters setObject:@"10" forKey:@"count"];
                 
                 SLRequest *postRequest = [SLRequest
                                           requestForServiceType:SLServiceTypeTwitter
                                           requestMethod:SLRequestMethodGET
                                           URL:requestURL parameters:parameters];
                 
                 postRequest.account = twitterAccount;
                 
                 [postRequest performRequestWithHandler:
                  ^(NSData *responseData, NSHTTPURLResponse
                    *urlResponse, NSError *error)
                  {
                      _dataSource = [NSJSONSerialization
                                         JSONObjectWithData:responseData
                                         options:NSJSONReadingMutableLeaves
                                         error:&error];
                      //NSLog(@"%@",_dataSource);
                  }];
             }
         } else {
             // Handle failure to get account access
         }
     }];
    
    return _dataSource;
}
@end
