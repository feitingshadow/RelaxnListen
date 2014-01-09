//
//  ViewController.h
//  RelaxnListen
//
//  Created by Stephen on 12/26/13.
//  Copyright (c) 2013 Stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController <MPMediaPickerControllerDelegate>
{
    NSTimer * runningTimer;
    NSTimeInterval currentTimePosition;
}

@property (nonatomic, retain)   MPMediaItemCollection   *userMediaItemCollection;
@property (nonatomic, strong) MPMusicPlayerController * musicPlayer;

@property (nonatomic) BOOL musicPlayedOnce; //added in

@property (nonatomic, strong) IBOutlet UILabel * currentPlayingLabel;
@property (nonatomic, strong) IBOutlet UILabel * sectionSizeLabel;
@property (nonatomic, strong) IBOutlet UIButton * restartButton;

@property (nonatomic, strong) IBOutlet UISlider * slider;
@property (nonatomic, strong) IBOutlet UIButton * playButton;

@property (nonatomic, strong) IBOutlet UIProgressView * progressView;
@property (nonatomic, strong) IBOutlet UIProgressView * totalProgressView;

- (IBAction) skipNextChunk:(UIButton*)sender;
- (IBAction) skipPrevChunk:(UIButton*)sender;
- (IBAction) playlistTapped:(UIButton*)sender;
- (IBAction) restoreLast:(UIButton*)sender;
- (IBAction) restartTapped:(UIButton*)sender;
- (IBAction) pauseButtonTapped:(UIButton*)sender;

- (IBAction) chunkSliderChangedTo:(UISlider*)sender;

@end
