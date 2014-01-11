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

#define SKIP_SEC 25

//TODO: Get artwork for media in image on table/main

@interface ViewController ()
{
    NSTimeInterval startTimeInterval;
}
@end

@implementation ViewController

//Labels
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillSleep) name:@"Will_Sleep" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillWakeup) name:@"Will_Wakeup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickedPreviouslyPlayedItem:) name:@"PickedPreviousItem" object:nil];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"Will_Sleep" object:self];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"Will_Wakeup" object:self];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:self.musicPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerPlaybackStateDidChangeNotification object: self.musicPlayer];
    
    [self.musicPlayer endGeneratingPlaybackNotifications];
    [self stopTimer];
}


#pragma mark - IBActions

- (IBAction) skipNextChunkTapped:(UIButton*)sender;
{
    [self skipNextChunk];
}

- (IBAction) skipPrevChunkTapped:(UIButton*)sender;
{
    [self skipPreviousChunk];
}

- (IBAction) playlistTapped:(UIButton*)sender;
{
    [self newPlaylist];
}

- (IBAction) restoreLast:(UIButton*)sender;
{
    [self restorePreviousItemFromIndex:0];
}


- (IBAction) pauseButtonTapped:(UIButton*)sender;
{
    if ([self currentMediaItem])
    {
        MPMusicPlaybackState playbackState = [self.musicPlayer playbackState];
        if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused)
        {
            [self play];
        }
        else if (playbackState == MPMusicPlaybackStatePlaying)
        {
            [self pause];
        }
    }
    else
    {
        //Alert or nothing?
    }
    [self displayTheUI];
}

//Turn next functions into IBActions by the sec-skip buttons
- (IBAction)skipNextSeconds;
{
    [self skipBy:SKIP_SEC];
}

- (IBAction) skipPrevSeconds;
{
    [self skipBy: SKIP_SEC];
}

#pragma mark - Media Playback Time Control Functions

- (void) skipNextChunk;
{
    [self skipBy: SECS_PER_MIN * self.slider.value];
}

- (void) skipPreviousChunk;
{
    [self skipBy: -SECS_PER_MIN * self.slider.value];
}

- (void) play;
{
    if (self.currentPlayedItem)
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        [self.musicPlayer play];
        [self startRunTimer];
        [self storeLastPlayed];
    }
}

- (void) pause;
{
    [self.musicPlayer pause];
    [self storeLastPlayed];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self stopTimer];
    [self displayTheUI];
}

- (void) stop;
{
    [self pause];
    [self.musicPlayer stop];
    currentTimePosition = 0;
    [self displayTheUI];
}

//Starts the timer from current position
- (IBAction) restartTapped:(UIButton*)sender;
{
    [self resetTimeFromCurrentPosition];
}

- (IBAction) chunkSliderChangedTo:(UISlider*)sender;
{
    [[Settings sharedSettings] setLastChunkSizeMinutes:sender.value];
    self.sectionSizeLabel.text = [NSString stringWithFormat:@"%i Min", (int)sender.value];
}

- (void) storeLastPlayed;
{
    MPMediaItem * item = [self currentMediaItem];
    if (item)
    {
        self.currentPlayedItem = [PlayedItem itemWithMediaItem:item]; //creates a new one from the playing one to avoid issues with not changing. Name, date, everything done, minus the current playback time.
        //gate playback time on playing/pause?
        self.currentPlayedItem.lastInterval = self.musicPlayer.currentPlaybackTime;
        [[Settings sharedSettings] setLastCollection: self.userMediaItemCollection];
        [[Settings sharedSettings] setLastPlayedItem:self.currentPlayedItem];
    }
}

- (void) resetTimeFromCurrentPosition;
{
    if ([self currentMediaItem])
    {
        startTimeInterval = self.musicPlayer.currentPlaybackTime;
        [self displayTheUI];
    }
}

//Not for static displays like last played, but higher frequency changes like the slider and play/pause
- (void) displayTheUI;
{
    MPMusicPlaybackState playbackState = [self.musicPlayer playbackState];
    self.currentPlayingLabel.text = self.currentPlayedItem.title;
    //Todo: Adjust label height?
    
    //Play Button
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
    
    if (self.currentPlayedItem)
    {
        self.smallerProgressView.progress = (startTimeInterval - currentTimePosition) / self.slider.value * SECS_PER_MIN;
        self.totalProgressView.progress = currentTimePosition/[MediaItemPropertyHelper lengthOfMedia:self.currentPlayedItem.mediaItem];
    }
    else
    {
        self.smallerProgressView.progress = 0;
        self.totalProgressView.progress = 0;
    }
    
    //Button enabling?
}

// Invoked by the delegate of the media item picker when the user is finished picking music.
//      The delegate is either this class or the table view controller, depending on the
//      state of the application.
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {
    if (mediaItemCollection)
    {
        // apply the new media item collection as a playback queue for the music player
        self.userMediaItemCollection = mediaItemCollection;
        [self.musicPlayer setQueueWithItemCollection: self.userMediaItemCollection];
        currentTimePosition = 0; //make sure all time sets are after updatePlayerQueue
    }
}

- (MPMediaItem *) currentMediaItem
{
    if (self.userMediaItemCollection && self.userMediaItemCollection.items.count > 0) {
        return (MPMediaItem *) self.userMediaItemCollection.items.firstObject;
    }
    return nil;
}

// When the now-playing item changes, update the media item artwork and the now-playing label.
- (void) handle_NowPlayingItemChanged: (id) notification {
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
    [self displayTheUI];
}

// When the playback state changes, set the play/pause button in the Navigation bar
//      appropriately.
//Unused...
- (void) handle_PlaybackStateChanged: (id) notification {
    
    MPMusicPlaybackState playbackState = [self.musicPlayer playbackState];
    
    if (playbackState == MPMusicPlaybackStatePaused)
    {
    }
    else if (playbackState == MPMusicPlaybackStatePlaying)
    {
    }
    else if (playbackState == MPMusicPlaybackStateStopped)
    {
        [self stop];
    }
    
    [self displayTheUI];
}

//Just pauses if > chunkTime
- (void) tick:(NSTimer*)t
{
    NSTimeInterval secondsPlayed = self.musicPlayer.currentPlaybackTime - startTimeInterval;
    NSTimeInterval chunkInSeconds = self.slider.value * SECS_PER_MIN;
    
    if (secondsPlayed > chunkInSeconds)
    {
        [self pause];
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

- (void) skipBy:(int)seconds
{
    MPMediaItem * item = [self currentMediaItem];
    if (item)
    {
        NSTimeInterval totalSec = [MediaItemPropertyHelper lengthOfMedia:item];
        NSTimeInterval currentSec = self.musicPlayer.currentPlaybackTime;
        currentSec += seconds;
        if (currentSec < 0)
        {
            currentSec = 0;
        }
        else if(currentSec > totalSec)
        {
            currentSec = totalSec - 0.1;
        }
        
        self.musicPlayer.currentPlaybackTime = currentSec; //update progress bar
        [self displayTheUI];
    }
}

//Note, this is very unsafe. Make sure the item is still in the ipod device.
- (void) restorePreviousItemFromIndex:(int)i;
{
    NSArray * lastItems = [[Settings sharedSettings] lastPlayedItems];
    if (lastItems && lastItems.count - 1 >= i) //ensure it exists within the bounds
    {
        PlayedItem * previousItem = lastItems[0];
        self.currentPlayedItem = previousItem;
        if (previousItem.mediaItem)
        {
            [self updatePlayerQueueWithMediaCollection:[MPMediaItemCollection collectionWithItems:@[previousItem.mediaItem]]];
        }
        else
        {
            //breakpoint, should never hit unless not saving.
        }
        currentTimePosition = self.currentPlayedItem.lastInterval;
        [self displayTheUI];
    }
}

#pragma mark - Navigation callback
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

#pragma mark - Notification

- (void) pickedPreviouslyPlayedItem:(NSNotification*)notify;
{
    NSDictionary * info = notify.userInfo;
    if ([[info allKeys] count] > 0 && [info valueForKey:@"Item"])
    {
        [self restorePreviousItemFromIndex:((NSNumber*)[info valueForKey:@"Item"]).intValue];
    }
}

#pragma  mark - Application Sleep Callbacks
- (void) appWillSleep;
{
    [self pause];
}

- (void) appWillWakeup;
{
    [self displayTheUI];
}

#pragma  mark - Media Picker Callbacks
//Note: (docs say must be a controller object to be this delegate..., good luck implementing Singleton)
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self updatePlayerQueueWithMediaCollection:mediaItemCollection];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

/*
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
