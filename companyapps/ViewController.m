//
//  ViewController.m
//  companyapps
//
//  Created by Mehul Bhavani on 30/11/17.
//  Copyright © 2017 AppYogi Software. All rights reserved.
//

#import "ViewController.h"
#import "CompanyApps.h"

@interface ViewController () <NSTableViewDataSource, NSTableViewDelegate>
@end

static NSString *kColumnIdentifierImage         = @"col_image";
static NSString *kColumnIdentifierVersion       = @"col_version";
static NSString *kColumnIdentifierName          = @"col_name";
static NSString *kColumnIdentifierAppID         = @"col_appid";
static NSString *kColumnIdentifierBundleID      = @"col_bundleid";
static NSString *kColumnIdentifierLastUpdate    = @"col_lastupdate";
static NSString *kRowIdentifierDefault          = @"row_default";

@implementation ViewController
{
    IBOutlet NSTableView *_tableView;
    IBOutlet NSTextField *statusTextField;
    IBOutlet NSButton *refreshButton;
    IBOutlet NSProgressIndicator *activityIndicator;
    
    NSArray *appsArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    appsArray = [[NSArray alloc] init];
    
    [self fetchApps];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"open_window" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.view.window makeKeyAndOrderFront:nil];
    }];
}

- (void)fetchApps {
    [activityIndicator startAnimation:nil];
    CompanyApps *apps = [[CompanyApps alloc] init];
    [apps fetchAppForDeveloperIds:@[@"1039633008", @"834979139"] completionBlock:^(NSArray *appsList, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if(error) {
                 NSLog(@"%@", error);
             }
             else {
                 NSLog(@"%@", appsList[0]);
                 appsArray = appsList;
             }
             [activityIndicator stopAnimation:nil];
             [_tableView reloadData];
             statusTextField.stringValue = [NSString stringWithFormat:@"%zd apps", appsArray.count];
         });
     }];
}

- (IBAction)refreshButton_Clicked:(id)sender {
    [self fetchApps];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return appsArray.count;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if(!cell) {
        cell = [[NSTableCellView alloc] init];
    }
    
    NSDictionary *app = appsArray[row];
    if([tableColumn.identifier isEqualToString:kColumnIdentifierImage]) {
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.appyogi.calendar.img", 0);
        dispatch_async(backgroundQueue, ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:appsArray[row][@"artworkUrl100"]]];
            NSImage *image = [[NSImage alloc] initWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = image;
            });
        });
    }
    else if([tableColumn.identifier isEqualToString:kColumnIdentifierVersion]) {
        cell.textField.stringValue = app[@"version"];
    }
    else if([tableColumn.identifier isEqualToString:kColumnIdentifierName]) {
        cell.textField.stringValue = app[@"trackName"];
    }
    else if([tableColumn.identifier isEqualToString:kColumnIdentifierAppID]) {
        cell.textField.stringValue = [NSString stringWithFormat:@"%@", app[@"trackId"]];
    }
    else if([tableColumn.identifier isEqualToString:kColumnIdentifierBundleID]) {
        cell.textField.stringValue = app[@"bundleId"];
    }
    else if([tableColumn.identifier isEqualToString:kColumnIdentifierLastUpdate]) {
        cell.textField.stringValue = app[@"currentVersionReleaseDate"];
    }
    
    return cell;
}
- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray<NSSortDescriptor *> *)oldDescriptors {
    appsArray = [appsArray sortedArrayUsingDescriptors:tableView.sortDescriptors];
    [tableView reloadData];
}

@end
