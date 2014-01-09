//
//  ViewController.m
//  RelaxnListen
//
//  Created by Stephen on 12/26/13.
//  Copyright (c) 2013 Stephen. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Settings.h"

@interface ViewController ()
{
    NSTimeInterval startTimeInterval;
    BOOL loadedNewTrack; //YES means reset the start point
}
@end

@implementation ViewController

//Labels
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupMusicPlayer];
    [self displayTheUI];
}

- (void) setupMusicPlayer;
{
    
    self.musicPlayer =    [MPMusicPlayerController applicationMusicPlayer];
    self.musicPlayer.shuffleMode = MPMusicShuffleModeOff;
    self.musicPlayer.repeatMode = MPMusicRepeatModeNone;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_NowPlayingItemChanged:)
     name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:      self.musicPlayer];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_PlaybackStateChanged:)
     name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:      self.musicPlayer];
    
    [self.musicPlayer beginGeneratingPlaybackNotifications];


    
}

- (void) newPlaylist;
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAudioBook];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = NO; //NO!!! for audiobook
    picker.prompt = NSLocalizedString (@"Choose an audio", "Prompt in media item picker");
    [self presentViewController:picker animated:YES completion:^{ }];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:self.musicPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerPlaybackStateDidChangeNotification object: self.musicPlayer];
    
    [self.musicPlayer endGeneratingPlaybackNotifications];
    [self stopTimer];
}


#pragma mark - IBAction

- (IBAction) skipNextChunk:(UIButton*)sender;
{
    //   [self.musicPlayer setCurrentPlaybackTime: [timelineSlider value]]; //from old code
}

- (IBAction) skipPrevChunk:(UIButton*)sender;
{
    
}

- (IBAction) playlistTapped:(UIButton*)sender;
{
    [self newPlaylist];
}

- (IBAction) restoreLast:(UIButton*)sender;
{
    Settings * settings = [Settings sharedSettings];
    MPMediaItemCollection * previousCollection = [settings getLastCollection];
    if (previousCollection)
    {
        MPMediaItem * previousItem = [settings getLastPlayedMediaItem];
        
        if (previousItem)
        { //test for previously played position.
            NSTimeInterval previousTime = [settings getLastPositionInMediaTime];
            
            NSTimeInterval totalLength = [MediaItemPropertyHelper lengthOfMedia:previousItem];
           
            if (previousTime <= totalLength)
            {
                self.userMediaItemCollection = previousCollection;
               
//                currentChunk = [self chunkForTimeInterval:previousTime forMedia:previousItem chunkSize:self.slider.value];
                currentTimePosition = previousTime;
                
                [self displayTheUI];
            }
        }
    }
}


- (IBAction) pauseButtonTapped:(UIButton*)sender;
{
    if (self.userMediaItemCollection)
    {
        MPMusicPlaybackState playbackState = [self.musicPlayer playbackState];
        
        if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused)
        {
            if (self.musicPlayer == nil)
            {
                [self setupMusicPlayer];
            }
            
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            [self startRunTimer];
            if (loadedNewTrack)
            {
                startTimeInterval = 0.0;
                loadedNewTrack = NO;
            }
            
            [self.musicPlayer play];

            [[Settings sharedSettings] addItemToPlayed:[PlayedItem itemWithMediaItem:self.musicPlayer.nowPlayingItem]];
        }
        else if (playbackState == MPMusicPlaybackStatePlaying)
        {
            [self.musicPlayer pause];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            [self stopTimer];
        }
    }
    else
    {
        //Alert
    }
    
    [self displayTheUI];
}

- (IBAction) restartTapped:(UIButton*)sender;
{
    //todo. Get current time playing and set startTime to that.
}

- (IBAction) chunkSliderChangedTo:(UISlider*)sender;
{
    [[Settings sharedSettings] setLastChunkSizeMinutes:sender.value];
    self.sectionSizeLabel.text = [NSString stringWithFormat:@"%i Minutes", (int)sender.value];
}

- (void) storeLastPlayed;
{
    if (self.userMediaItemCollection && self.userMediaItemCollection.items.count > 0)
    {
        [[Settings sharedSettings] setLastCollection: self.userMediaItemCollection];
        [[Settings sharedSettings] setLastPlayedMediaItem:(MPMediaItem*) self.userMediaItemCollection.items[0] ];
    }
}

//Not for static displays like last played, but higher frequency changes like the slider and play/pause
- (void) displayTheUI;
{
    //Play Button
    MPMusicPlaybackState playbackState = [self.musicPlayer playbackState];
    
    if (playbackState == MPMusicPlaybackStatePlaying)
    {
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else
    {
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    }

    //update the chunks
    
    Settings * settings = [Settings sharedSettings];
    self.slider.value = [settings getLastChunkSizeInMinutes];
    
}

#pragma  mark - Media Picker Callbacks
//Note: (docs say must be a controller object to be this delegate..., good luck implementing Singleton)

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self updatePlayerQueueWithMediaCollection:mediaItemCollection];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
//    [self.musicPlayer play];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

// Invoked by the delegate of the media item picker when the user is finished picking music.
//      The delegate is either this class or the table view controller, depending on the
//      state of the application.

- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {
    // Configure the music player, but only if the user chose at least one song to play
    if (mediaItemCollection) {
        // If there's no playback queue yet...
//        if (self.userMediaItemCollection == nil) {
        if (YES) {
            // apply the new media item collection as a playback queue for the music player
            self.userMediaItemCollection = mediaItemCollection;
            [self.musicPlayer setQueueWithItemCollection: self.userMediaItemCollection];
            self.musicPlayedOnce = YES;

            // Obtain the music player's state so it can then be
            //      restored after updating the playback queue.
        }
        if(NO)
        {
            // Take note of whether or not the music player is playing. If it is
            //      it needs to be started again at the end of this method.
            
            BOOL wasPlaying = NO;
            if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
                wasPlaying = YES;
            }
            
            // Save the now-playing item and its current playback time.
            MPMediaItem *nowPlayingItem         = self.musicPlayer.nowPlayingItem;
            NSTimeInterval currentPlaybackTime  = self.musicPlayer.currentPlaybackTime;

            // Combine the previously-existing media item collection with the new one
            NSMutableArray *combinedMediaItems  = [[self.userMediaItemCollection items] mutableCopy];
            NSArray *newMediaItems              = [mediaItemCollection items];
            
            [combinedMediaItems addObjectsFromArray: newMediaItems];

            [self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: (NSArray *) combinedMediaItems]];
            
            // Apply the new media item collection as a playback queue for the music player.
            [self.musicPlayer setQueueWithItemCollection: self.userMediaItemCollection];

            // Restore the now-playing item and its current playback time.
            self.musicPlayer.nowPlayingItem          = nowPlayingItem;
            self.musicPlayer.currentPlaybackTime     = currentPlaybackTime;
            
            // If the music player was playing, get it playing again.
            
            if (wasPlaying) {
           //     [self.musicPlayer play];
            }
        }
        
        // Finally, because the music player now has a playback queue, ensure that 
        //      the music play/pause button in the Navigation bar is enabled.
      //  navigationBar.topItem.leftBarButtonItem.enabled = YES;
        

    }
    
    loadedNewTrack = YES;
}

// If the music player was paused, leave it paused. If it was playing, it will continue to
//      play on its own. The music player state is "stopped" only if the previous list of songs
//      had finished or if this is the first time the user has chosen songs after app
//      launch--in which case, invoke play.

- (void) restorePlaybackState {
    
    if (self.musicPlayer.playbackState == MPMusicPlaybackStateStopped && self.userMediaItemCollection) {
        
        if ( self.musicPlayedOnce == NO) {
            self.musicPlayedOnce = YES;
            [self.musicPlayer play];
        }
    }
    
}

// When the now-playing item changes, update the media item artwork and the now-playing label.

- (void) handle_NowPlayingItemChanged: (id) notification {
    
//    MPMediaItem *currentItem = [self.musicPlayer nowPlayingItem];

//    MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
    
    if (self.musicPlayer.nowPlayingItem && self.musicPlayer.indexOfNowPlayingItem > 5) {
//        [self.musicPlayer stop];
//        exit(1);
    }
    if (self.musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
        // Provide a suitable prompt to the user now that their chosen music has
        //      finished playing.
        
    }
    else if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
    {
        
    }
    
}



// When the playback state changes, set the play/pause button in the Navigation bar
//      appropriately.

- (void) handle_PlaybackStateChanged: (id) notification {
    
    MPMusicPlaybackState playbackState = [self.musicPlayer playbackState];
    
    if (playbackState == MPMusicPlaybackStatePaused) {
        
    } else if (playbackState == MPMusicPlaybackStatePlaying) {
        
        
    } else if (playbackState == MPMusicPlaybackStateStopped) {
        
        // Even though stopped, invoking 'stop' ensures that the music player will play
        //      its queue from the start.
        [self.musicPlayer stop];
    
    }
    
    [self displayTheUI];
}

- (void) tick:(NSTimer*)t
{
    NSTimeInterval secondsPlayed = self.musicPlayer.currentPlaybackTime - startTimeInterval;
    
    NSTimeInterval chunkInSeconds = self.slider.value * SECS_PER_MIN;
    
    if (secondsPlayed > chunkInSeconds)
    {
        [self.musicPlayer pause];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [self stopTimer];
        //todo, above to convenience function
    }
}

- (void) stopTimer;
{
    [runningTimer invalidate];
    runningTimer = nil;
}

- (void) startRunTimer;
{
    if (runningTimer)
    {
        [self stopTimer];
    }
    
    runningTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

#pragma mark - Currently stored
- (MPMediaItem*) getCurrentMediaItem;
{
    if (self.userMediaItemCollection && self.userMediaItemCollection.items && self.userMediaItemCollection.items.count > 0) {
        return (MPMediaItem*)self.userMediaItemCollection.items[0];
    }
    return nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

// from sample

//- (void) handle_iPodLibraryChanged: (id) notification {
//    //Or use the persistendMediaID for the mpmediaquery...???
//    
//    
//    // Implement this method to update cached collections of media items when the
//    
//    // user performs a sync while your application is running. This sample performs
//    
//    // no explicit media queries, so there is nothing to update.
//    
//}

//
//- (IBAction) sectionBarSelectionChanged:(UISegmentedControl*)sender;
//{
//    //Change number of sections to play before sleep
//}

// In setup music player

/*
 //See if something is already playing in the background
 //    MPMusicPlayerController* iPodMusicPlayer = [MPMusicPlayerController ipodMusicPlayer];
 //    if ([iPodMusicPlayer nowPlayingItem]) //something is already in the bg of the app
 //    {
 //
 //  This will be nil if it uses Home Sharing, but the PlayBackState on the notification will tell you if
 //  something is playing.
 //      //  [iPodMusicPlayer stop]; //forced stop
 //    }
 */

@end
