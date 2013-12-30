//
//  ViewController.h
//  RelaxnListen
//
//  Created by Stephen on 12/26/13.
//  Copyright (c) 2013 Stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MPMediaPickerControllerDelegate>
{
    
}
@property (nonatomic, retain)   MPMediaItemCollection   *userMediaItemCollection;
@property (nonatomic, strong) IBOutlet UITableView * table;
@property (nonatomic, strong) MPMusicPlayerController * musicPlayer;

@property (nonatomic) BOOL musicPlayedOnce; //added in

- (IBAction)button1:(id)sender;
- (IBAction)button2:(id)sender;

@end
