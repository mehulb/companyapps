//
//  AppDelegate.h
//  companyapps
//
//  Created by Mehul Bhavani on 30/11/17.
//  Copyright © 2017 AppYogi Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;


@end

