//
//  CompanyApps.m
//  calendar
//
//  Created by Mehul Bhavani on 19/12/16.
//  Copyright © 2016 AppYogi. All rights reserved.
//

#import "CompanyApps.h"

NSString * const LookUpURLFormat = @"https://itunes.apple.com/lookup?id=%@&entity=software&country=%@";

@implementation CompanyApps
{
    // receives
    NSArray *_devIds;
    CompletionBlock _block;
    
    // returns
    NSMutableArray *_appsArray;
    NSError *_error;
    
    // nothing to say...
    NSInteger index;
	
	// cache downloaded data
	NSString *cacheFileURL;
}

- (instancetype)init
{
    if(self = [super init])
    {        
        _appsArray = [[NSMutableArray alloc] init];
        _error = nil;
    }
    return self;
}

- (void)fetchAppForDeveloperIds:(NSArray *)devIds completionBlock:(CompletionBlock)block
{
    if(!devIds || devIds.count == 0)
    {
        NSLog(@"devIds nil/empty");
        return;
    }
    if(!block) {
        NSLog(@"completion block is nil");
        return;
    }
    _devIds = [[NSArray alloc] initWithArray:devIds];
    _block = block;
    
    index = 0;
	
	[self createCacheFileIfNotExists];
    [self fetchApps];
}

#pragma mark - Internal
- (void)fetchApps
{
    NSString *countryCode = (__bridge NSString *)CFLocaleGetValue(CFLocaleCopyCurrent(), kCFLocaleCountryCode);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:LookUpURLFormat, _devIds[index], countryCode]]];
    
    //NSLog(@"%@", request.URL.absoluteString);
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                               if(!connectionError) {
                                   NSError *error;
                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if(error) {
                                       NSLog(@"%@", error);
                                       _error = error;
                                       [self completed];
                                   }
                                   else if(json && json[@"resultCount"]>0) {
                                       if ([json[@"results"] count] > 1) {
                                           [_appsArray addObjectsFromArray:[json[@"results"] subarrayWithRange:NSMakeRange(1, [json[@"results"] count]-1)]];
                                           index++;
                                           if(index == _devIds.count) {
                                               [self completed];
                                           }
                                           else {
                                               [self fetchApps];
                                           }
                                       }
                                   }
                               }
                               else {
                                   NSLog(@"%@", connectionError);
                                   _error = connectionError;
                                   [self completed];
                               }
                           }
     ];
    [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}

- (void)completed
{
	if(!_error && _appsArray.count > 0)
		[self saveData];
	
    _block(_appsArray, _error);
}

- (void)createCacheFileIfNotExists
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	cacheFileURL = [paths firstObject];
	cacheFileURL = [NSString stringWithFormat:@"%@/more_apps.json", cacheFileURL];
	if(![[NSFileManager defaultManager] fileExistsAtPath:cacheFileURL])
	{
		if([[NSFileManager defaultManager] createFileAtPath:cacheFileURL contents:nil attributes:nil]){
			//NSLog(@"Apps cache file created");
		}
		else{
			NSLog(@"Apps cache file failed creation");
		}
		//[self readSavedData];
	}
	else {
		//[self readSavedData];
	}
}
- (void)saveData
{
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_appsArray options:NSJSONWritingPrettyPrinted error:&error];
	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	if(error) {
		NSLog(@"%@", error);
	}
	else {
		[jsonString writeToFile:cacheFileURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
		if(error){
			NSLog(@"%@", error);
		}
		else{
			//NSLog(@"Apps Cache Saved");
		}
	}
}
- (void)readSavedData
{
	NSData *cachedData = [[NSString stringWithContentsOfFile:cacheFileURL encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
	if(!cachedData) {
		//NSLog(@"No Cached Data");
		cachedData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"apps" ofType:@"json"]];
	}
	NSError *error;
	NSArray *json = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingAllowFragments error:&error];
	//_appsArray = [json mutableCopy];
	//_error = error;
	//NSLog(@"Read Cached Data");
	_block(json, error);
}
@end
