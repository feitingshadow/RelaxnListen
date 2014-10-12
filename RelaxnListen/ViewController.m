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

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    [self hideDarkCoverView:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideDarkCoverView:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillSleep) name:@"Will_Sleep" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillWakeup) name:@"Will_Wakeup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickedPreviouslyPlayedItem:) name:@"PickedPreviousItem" object:nil];
    
    [self setupMusicPlayer];
    [self restorePreviousItemFromIndex:0];
    [self displayTheUI];
    
    self.testSwitch.hidden = YES;
}

- (BOOL) canBecomeFirstResponder
{
    return YES;
}

- (void) setupMusicPlayer;
{
    
    self.musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
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
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
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
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.musicPlayer endGeneratingPlaybackNotifications];
    [self stopTimer];
    self.titleCollection = nil;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (motion == UIEventSubtypeMotionShake)
    {
        enum shakepurpose purpose = [[Settings sharedSettings] getCurrentShakePurpose];
        switch (purpose)
        {
            case shakePurposeResetChunk:
            {
                [self resetTimeFromCurrentPosition];
            }
                break;
            case shakePurposePauseAudioTrack:
            {
                [self pause];
            }
                break;
            default:
                break;
        }
    }
    
    [self resetIdleScreenTimeout];
}

#pragma mark - IBActions

- (IBAction) skipNextChunkTapped:(UIButton*)sender;
{
    [self skipNextChunk];
    [self setStartTimeTo:currentTimePosition];
    [self pause];
}

- (IBAction) skipPrevChunkTapped:(UIButton*)sender;
{
    [self skipPreviousChunk];
}

- (IBAction) playlistTapped:(UIButton*)sender;
{
//    if ([self hasTracks]) //No longer limiting to just books.
//    {
        [self newPlaylist];
//    }
//    else
//    {
//        [[[UIAlertView alloc] initWithTitle:@"No books found!" message:@"No audiobooks are in your library!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
//    }
}

- (IBAction) restoreLast:(UIButton*)sender;
{
    [self restorePreviousItemFromIndex:0];
}

- (IBAction) websiteTapped:(UIButton*)sender;
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.theplaceforforgiving.com"]];
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
    [self skipBy:-SKIP_SEC];
}

#pragma mark - Media Playback Time Control Functions

- (void) skipNextChunk;
{
    [self skipBy: SECS_PER_MIN * self.slider.value];
}

- (void) skipPreviousChunk;
{
    [self skipBy: -(SECS_PER_MIN * self.slider.value)];
}

- (IBAction) hideDarkCoverView:(UIButton*)sender;
{
    self.darkCoverView.hidden = YES;
}

- (IBAction) resetIdleScreenTimeout;
{
    [self hideDarkCoverView:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(makeScreenIdle) object:nil];
    
    if ([[Settings sharedSettings] getGoesBlackWhenInactive])
    {
        [self performSelector:@selector(makeScreenIdle) withObject:nil afterDelay:30.0];
    }
}

- (void) makeScreenIdle;
{
    if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
    {
        self.darkCoverView.hidden = NO;
    }
}

- (void) play;
{
    if (self.currentMediaItem)
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        if ([[Settings sharedSettings] getGoesBlackWhenInactive])
        {
            [self resetIdleScreenTimeout];
        }
        
        if (currentTimePosition == NAN)
        {
            
        }
        self.musicPlayer.currentPlaybackTime = currentTimePosition;
        [self.musicPlayer play];
        [self startRunTimer];
        [self storeLastPlayed];
    }
}

- (void) pause;
{
    if (self.currentMediaItem && self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
    {
        if (self.musicPlayer.currentPlaybackTime != NAN && self.musicPlayer.currentPlaybackTime < HUGE_VALF)
        {
       //     currentTimePosition = self.musicPlayer.currentPlaybackTime;
        }
        else
        {
            
        }
        [self storeLastPlayed];
        [self.musicPlayer pause];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [self stopTimer];
        [self displayTheUI];
    }
}

- (void) stop;
{
    [self setStartTimeTo:0];
    [self pause];
    [self.musicPlayer stop];
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
    [self displayTheUI];
}

- (void) storeLastPlayed;
{
    MPMediaItem * item = [self currentMediaItem];
    if (item)
    {
//        if (self.currentPlayedItem.lastInterval <= 0.5) {
//            
//            
//        }
        //gate playback time on playing/pause?
        self.currentPlayedItem.lastDate = [NSDate date];
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
    Settings * settings = [Settings sharedSettings];

    UIColor * chromeColor = [settings getDarkTheme] ? [UIColor whiteColor] : [UIColor blackColor];
    
    for (UILabel * titleLabel in self.titleCollection)
    {
        titleLabel.textColor = chromeColor;
    }
    
    self.view.backgroundColor = [settings getDarkTheme] ? [UIColor blackColor] : [UIColor whiteColor];
    
    
    MPMusicPlaybackState playbackState = [self.musicPlayer playbackState];
    self.currentPlayingLabel.text = self.currentPlayedItem.title;
    //Todo: Adjust label height?
    
    NSString * overallDispString = @"Overall";
    NSString * chunkDispString = @"Chunk";
    
    if ([self currentPlayedItem])
    {
        
        self.imageView.image = [[MediaItemPropertyHelper artForMediaItem:[self currentMediaItem]] imageWithSize:self.imageView.frame.size];
        
        self.playButton.enabled = YES;
        self.skipChunkButton.enabled = YES;
        self.skipPrevChunkButton.enabled = YES;
        self.skipNextSecondsBtn.enabled = YES;
        self.skipPrevSecondsBtn.enabled = YES;
        
        //Play Button
        if (playbackState == MPMusicPlaybackStatePlaying)
        {
            [self.playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            //        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
        }
        else
        {
            [self.playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
            //        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        }
    }
    else
    {
        self.playButton.enabled = NO;
        self.skipChunkButton.enabled = NO;
        self.skipPrevChunkButton.enabled = NO;
        self.skipNextSecondsBtn.enabled = NO;
        self.skipPrevSecondsBtn.enabled = NO;
        self.currentPlayingLabel.text = @"Tap above to pick new.";
    }

    //update the chunks
    self.slider.value = [settings getLastChunkSizeInMinutes];
    self.sectionSizeLabel.text = [NSString stringWithFormat:@"%i Min", (int)self.slider.value];
    
    if (self.currentPlayedItem)
    {
        float chunkTotalSec = self.slider.value * SECS_PER_MIN;
        float tempStartTime = (currentTimePosition > startTimeInterval) ? (currentTimePosition - startTimeInterval): 0;

        //DEBUG code, for testing
        //        if (self.testSwitch.on) {
//            self.smallerProgressView.progress = tempStartTime / (self.slider.value/2.0f);// * SECS_PER_MIN; DEBUG CODE< UNCOMMENT BEFORE RELEASE
//        }
//        else
        
        {
            self.smallerProgressView.progress = tempStartTime / chunkTotalSec;

        }
        float totalTime = [MediaItemPropertyHelper lengthOfMedia:self.currentPlayedItem.mediaItem];
        self.totalProgressView.progress = currentTimePosition/totalTime;
        
        tempStartTime = currentTimePosition - startTimeInterval;
        chunkDispString = [NSString stringWithFormat:@"%@ %@/%@", chunkDispString, [self displayStringForSeconds:tempStartTime], [self displayStringForSeconds: chunkTotalSec] ];
        
        overallDispString = [NSString stringWithFormat:@"%@ %@/%@", overallDispString, [self displayStringForSeconds:currentTimePosition], [self displayStringForSeconds: totalTime] ];

        self.overallProgress.text = overallDispString;
        self.chunkProgress.text = chunkDispString;
    }
    else
    {
        self.smallerProgressView.progress = 0;
        self.totalProgressView.progress = 0;
        self.overallProgress.text = overallDispString;
        self.chunkProgress.text = chunkDispString;
    }
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
        [self displayTheUI];
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
        [self.musicPlayer stop];
    }
    
    [self displayTheUI];
}

//Just pauses if > chunkTime
- (void) tick:(NSTimer*)t
{
    NSTimeInterval secondsPlayed = self.musicPlayer.currentPlaybackTime - startTimeInterval;
    NSTimeInterval chunkInSeconds;
    if (self.musicPlayer.currentPlaybackTime != NAN) {
        currentTimePosition = self.musicPlayer.currentPlaybackTime;
        self.currentPlayedItem.lastInterval = currentTimePosition;
    }
//    if (self.testSwitch.on)
//    {
//        chunkInSeconds = self.slider.value /2.0f;
//    }
//    else
    {
        chunkInSeconds = self.slider.value * SECS_PER_MIN;
    }
    
    [self storeLastPlayed];
    if (secondsPlayed > chunkInSeconds)
    {
        [self resetTimeFromCurrentPosition];
        [self pause];
    }
    
    [self displayTheUI];
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
        else if(currentSec > totalSec || currentSec == NAN)
        {
            [self stop];
            currentSec = 0;
        }

        currentTimePosition = currentSec;
        self.currentPlayedItem.lastInterval = currentTimePosition;
        self.musicPlayer.currentPlaybackTime = currentSec; //update progress bar
        [self storeLastPlayed];
        [self displayTheUI];
    }
}

//Note, this is very unsafe. Make sure the item is still in the ipod device.
- (void) restorePreviousItemFromIndex:(int)i;
{
    NSArray * lastItems = [[Settings sharedSettings] lastPlayedItems];
    if (lastItems && ( ( (signed)[lastItems count] - 1) >= i)) //ensure it exists within the bounds
    {
        [self pause];
        PlayedItem * previousItem = lastItems[i];
        self.currentPlayedItem = previousItem;
        if (previousItem.mediaItem)
        {
            [self updatePlayerQueueWithMediaCollection:[MPMediaItemCollection collectionWithItems:@[previousItem.mediaItem]]];
        }
        else
        {
            //breakpoint, should never hit unless not saving.
        }
        if (self.currentPlayedItem.lastInterval == NAN || self.currentPlayedItem.lastInterval >= [MediaItemPropertyHelper lengthOfMedia:self.currentPlayedItem.mediaItem])
        {
            [self setStartTimeTo:0];
        }
        else
        {
            [self setStartTimeTo:previousItem.lastInterval];
        }
//        [self resetTimeFromCurrentPosition];
        [self displayTheUI];
    }
}

- (void) setStartTimeTo:(NSTimeInterval) time;
{
    currentTimePosition = time;
    startTimeInterval = time;
}

#pragma mark - Navigation callback
- (void)viewWillAppear:(BOOL)animated
{
    [self hideDarkCoverView:nil];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self displayTheUI];
    [super viewWillAppear:animated];
    
    if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
    {
        [self resetIdleScreenTimeout]; //re-hide the player if returning to screen while playing.
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
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
    [self hideDarkCoverView:nil];
    [self displayTheUI];
}

#pragma  mark - Media Picker Callbacks
//Note: (docs say must be a controller object to be this delegate..., good luck implementing Singleton)
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self updatePlayerQueueWithMediaCollection:mediaItemCollection];
    self.currentPlayedItem = [PlayedItem itemWithMediaItem:[self currentMediaItem]];
    PlayedItem * played = [[Settings sharedSettings] lastPlayedItemWithKey:self.currentPlayedItem.title];
    [self pause];
    if (played) {
        [self setStartTimeTo:played.lastInterval];
    }
    else
    {
        [self setStartTimeTo:0];
    }
    [self displayTheUI];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (NSString*) displayStringForSeconds:(NSTimeInterval)sec;
{
    BOOL negative = NO;
    if (sec < 0) {
        negative = YES;
        sec *= -1;
    }
    int hr = sec/(SEC_PER_HOUR);
    sec = sec - hr * SEC_PER_HOUR;
    int min = sec/SECS_PER_MIN;
    int secondsLeft = sec - min * SECS_PER_MIN;
    
    if (hr < 1)
    {
        if (negative)
        {
            return [NSString stringWithFormat:@"-%02i:%02i", min, secondsLeft];
        }
        return [NSString stringWithFormat:@"%02i:%02i", min, secondsLeft];
    }
    if (negative)
    {
        return [NSString stringWithFormat:@"-%02i:%02i", min, secondsLeft];
    }
    return [NSString stringWithFormat:@"%02i:%02i:%02i", hr, min, secondsLeft];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (BOOL) hasTracks;
{
    return YES; //No longer using just audiobooks, obsolete function.
    NSArray * collections = [[MPMediaQuery audiobooksQuery] collections];

    if ( [collections count] > 0) {
        //Has audiobooks
        MPMediaItemCollection * collection = collections[0];
        if ([collection.items count] > 0) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
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
