//
//  PlayedViewController.m
//  RelaxnListen
//
//  Created by Stephen on 1/8/14.
//  Copyright (c) 2014 Stephen. All rights reserved.
//

#import "PlayedViewController.h"
#import "PlayedItemCell.h"
#import "Settings.h"

@interface PlayedViewController ()

@property (nonatomic, strong) NSArray * lastItems;
@end

@implementation PlayedViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    self.lastItems =[[Settings sharedSettings] lastPlayedItems];
    return self.lastItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlayedCell";
    PlayedItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    PlayedItem * playedItem = self.lastItems[indexPath.row];
    cell.bookName.text = [MediaItemPropertyHelper nameForMedia:playedItem.mediaItem];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //todo, notify update
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
