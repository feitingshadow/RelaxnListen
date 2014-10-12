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
    if (self.lastItems && self.lastItems.count > 0) {
        return self.lastItems.count;
    }
    return 1; //Informative
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlayedCell";
    PlayedItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
    if (self.lastItems && self.lastItems.count > 0) {
        PlayedItem * playedItem = self.lastItems[indexPath.row];
        cell.bookName.text = playedItem.title;
        //Todo: See if mediaItem is stored, otherwise add length to the Played.
        float totalItemSeconds = [MediaItemPropertyHelper lengthOfMedia:playedItem.mediaItem];
        cell.lastAtLbl.text = [NSString stringWithFormat:@"%@ / %@",[self displayStringForSec:playedItem.lastInterval], [self displayStringForSec:totalItemSeconds]];
        
        cell.progressBar.hidden = NO;
        
        //Safety
        if (totalItemSeconds > 0)
        {
            cell.progressBar.progress = playedItem.lastInterval / totalItemSeconds;
        }
        else //unknown!
        {
            cell.progressBar.progress = 0;
        }
        
        cell.image.image = [[MediaItemPropertyHelper artForMediaItem:playedItem.mediaItem] imageWithSize:cell.image.frame.size];
    }
    else //Info
    {
        cell.bookName.text = @"As you read, your books will show here!";
        cell.lastAtLbl.text = @"00:00 / 00:00";
        cell.progressBar.hidden = YES;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.lastItems && self.lastItems.count > 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PickedPreviousItem" object:nil userInfo:@{@"Item" : @(indexPath.row)}];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString*) displayStringForSec:(NSTimeInterval)sec;
{
    int hr = sec/(SEC_PER_HOUR);
    sec = sec - hr * SEC_PER_HOUR;
    int min = sec/SECS_PER_MIN;
    int secondsLeft = sec - min * SECS_PER_MIN;
    
    if (hr < 1)
    {
        return [NSString stringWithFormat:@"%02i:%02i", min, secondsLeft];
    }
    
    return [NSString stringWithFormat:@"%02i:%02i:%02i", hr, min, secondsLeft];
}

@end
