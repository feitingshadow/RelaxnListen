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

@property (nonatomic, strong) IBOutlet UILabel * currentPlayingLabel;
@property (nonatomic, strong) IBOutlet UISegmentedControl * sectionSizeSegmentedBar;
@property (nonatomic, strong) IBOutlet UILabel * lastPlayedLabel;
@property (nonatomic, strong) IBOutlet UILabel * currentSectionLabel;
@property (nonatomic, strong) IBOutlet UILabel * numberSectionsLabel;

@property (nonatomic, strong) IBOutlet UISlider * slider;
@property (nonatomic, strong) IBOutlet UIButton * playButton;

- (IBAction)button1:(id)sender;
- (IBAction)button2:(id)sender;

- (IBAction) skipNextChunk:(UIButton*)sender;
- (IBAction) skipPrevChunk:(UIButton*)sender;
- (IBAction) playlistTapped:(UIButton*)sender;
- (IBAction) restoreLast:(UIButton*)sender;
- (IBAction) pauseButtonTapped:(UIButton*)sender;
- (IBAction) sectionBarSelectionChanged:(UISegmentedControl*)sender;

- (IBAction) chunkSliderChangedTo:(UISlider*)sender;

@end
