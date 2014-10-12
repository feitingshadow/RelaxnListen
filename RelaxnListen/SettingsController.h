//
//  SettingsController.h
//  RelaxnListen
//
//  Created by Stephen on 1/30/14.
//  Copyright (c) 2014 Stephen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsController : UIViewController

@property (nonatomic, retain) IBOutlet UISwitch * darkSwitch;
@property (nonatomic, retain) IBOutlet UISwitch * idleSwitch;
@property (nonatomic, retain) IBOutlet UISegmentedControl * shakeBar;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray * titleCollection;

- (IBAction) idleSwitchChanged:(UISwitch*)sendingSwitch;
- (IBAction) darkThemeSwitchValueChanged:(UISwitch*)sendingSwitch;
- (IBAction) shakeBarChanged:(UISegmentedControl*)theBar;

@end
