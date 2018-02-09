//
//  CompanyApps.h
//  calendar
//
//  Created by Mehul Bhavani on 19/12/16.
//  Copyright © 2016 AppYogi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ CompletionBlock) (NSArray *appsList, NSError *error);

@interface CompanyApps : NSObject

- (void)fetchAppForDeveloperIds:(NSArray *)devIds completionBlock:(CompletionBlock)block;

@end
