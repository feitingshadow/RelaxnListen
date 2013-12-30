//
//  ViewController.m
//  RelaxnListen
//
//  Created by Stephen on 12/26/13.
//  Copyright (c) 2013 Stephen. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Storage.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    self.musicPlayer =     [MPMusicPlayerController applicationMusicPlayer];
    [self.musicPlayer setShuffleMode:MPMusicShuffleModeOff];
    [self.musicPlayer setRepeatMode:MPMusicRepeatModeNone];
    
    //bare minimum song player code.
  //  [self.musicPlayer setQueueWithQuery:[MPMediaQuery songsQuery]];
    
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
    
  
    //See if something is already playing in the background
//    MPMusicPlayerController* iPodMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
//    //decide between iPod Music Player and application Music Player.
//    
//    if ([iPodMusicPlayer nowPlayingItem]) //something is already in the bg of the app
//    {
//        //This will be nil if it uses Home Sharing, but the PlayBackState on the notification will tell you if osmething is playing.
//      //  [iPodMusicPlayer stop]; //forced stop NOTE: move to another area.
//        // Update the UI (artwork, song name, volume indicator, etc.)
//        //        to reflect the iPod state
//    }
    
    [self.musicPlayer beginGeneratingPlaybackNotifications];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) newPlaylist;
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAudioBook];                   // 1
    [picker setDelegate: self];                                         // 2
    [picker setAllowsPickingMultipleItems: YES];                        // 3
    picker.prompt = NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
    
    [self presentViewController:picker animated:YES completion:^{ }];
}

- (void) viewDidDisappear:(BOOL)animated
{
    //standard codededed ifying stuff.
    //also called on the disappearing view for god knows why... (not a subclass)
  
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:self.musicPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerPlaybackStateDidChangeNotification object: self.musicPlayer];
    
    [self.musicPlayer endGeneratingPlaybackNotifications];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //BSOD!!!
    //since ARC is enabled, good luck!!
}

- (IBAction)button1:(id)sender;
{
//    [self.musicPlayer skipToPreviousItem];
}

- (IBAction)button2:(id)sender;
{
    [self newPlaylist];
//    [self.musicPlayer skipToNextItem];
}


#pragma mark - copied code
- (IBAction) setTimelinePosition: (UISlider*) sender {
    //Example of skipping. (The position in time is writable :D )
 //   [self.musicPlayer setCurrentPlaybackTime: [timelineSlider value]];
}

#pragma mark - UITableView datasource

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellIdentifier"];
    
    MPMediaItem * mediaItem = (MPMediaItem*)self.userMediaItemCollection.items[indexPath.row];
    
  //  title = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
    
    
    return cell;
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

//AddMusic sample
// A toggle control for playing or pausing iPod library music playback, invoked
//      when the user taps the 'playBarButton' in the Navigation bar.

- (IBAction) playOrPauseMusic: (id)sender {
    MPMusicPlaybackState playbackState = [self.musicPlayer playbackState];
    
    if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused)
    {
        [self.musicPlayer play];
    }
    else if (playbackState == MPMusicPlaybackStatePlaying)
    {
        [self.musicPlayer pause];
    }
    
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
            [self.musicPlayer play];
            
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
                [self.musicPlayer play];
            }
        }
        
        // Finally, because the music player now has a playback queue, ensure that 
        //      the music play/pause button in the Navigation bar is enabled.
      //  navigationBar.topItem.leftBarButtonItem.enabled = YES;
        

    }
    
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
        // [musicPlayer stop];
    
    }
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



@end
