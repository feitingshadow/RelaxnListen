//
//  ViewController.h
//  RelaxnListen
//
//  Created by Stephen on 12/26/13.
//  Copyright (c) 2013 Stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PlayedItem.h"

@interface ViewController : UIViewController <MPMediaPickerControllerDelegate>
{
    NSTimer * runningTimer;
    NSTimeInterval currentTimePosition;
}

@property (nonatomic, retain) MPMediaItemCollection   *userMediaItemCollection;
@property (nonatomic, strong) MPMusicPlayerController * musicPlayer;

//@property (nonatomic) BOOL musicPlayedOnce; //added in

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray * titleCollection;
@property (nonatomic, strong) IBOutlet UILabel * currentPlayingLabel;
@property (nonatomic, strong) IBOutlet UILabel * sectionSizeLabel;

@property (nonatomic, strong) IBOutlet UISlider * slider;
@property (nonatomic, strong) IBOutlet UIButton * playButton;
@property (nonatomic, strong) IBOutlet UIButton * skipChunkButton;
@property (nonatomic, strong) IBOutlet UIButton * skipPrevChunkButton;
@property (nonatomic, strong) IBOutlet UIButton * skipNextSecondsBtn;
@property (nonatomic, strong) IBOutlet UIButton * skipPrevSecondsBtn;

@property (nonatomic, strong) IBOutlet UIProgressView * smallerProgressView;
@property (nonatomic, strong) IBOutlet UIProgressView * totalProgressView;
@property (nonatomic, strong) IBOutlet UISwitch * testSwitch;
@property (nonatomic, strong) IBOutlet UIImageView * imageView;
@property (nonatomic, strong) IBOutlet UILabel * chunkProgress;
@property (nonatomic, strong) IBOutlet UILabel * overallProgress;
@property (nonatomic, strong) IBOutlet UIView * darkCoverView;

@property (nonatomic, strong) PlayedItem * currentPlayedItem;

- (IBAction) skipNextChunkTapped:(UIButton*)sender;
- (IBAction) skipPrevChunkTapped:(UIButton*)sender;
- (IBAction) playlistTapped:(UIButton*)sender;
- (IBAction) pauseButtonTapped:(UIButton*)sender;

- (IBAction) restoreLast:(UIButton*)sender;
- (IBAction) websiteTapped:(UIButton*)sender;
- (IBAction) restartTapped:(UIButton*)sender;
- (IBAction) chunkSliderChangedTo:(UISlider*)sender;
- (IBAction) resetIdleScreenTimeout; //tells the screen to go dark after 30.0s
- (IBAction) hideDarkCoverView:(UIButton*)sender;

- (void) play;
- (void) pause;
- (void) stop;
- (void) skipNextChunk;
- (void) skipPreviousChunk;

@end
