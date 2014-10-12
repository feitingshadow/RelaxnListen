//
//  SettingsController.m
//  RelaxnListen
//
//  Created by Stephen on 1/30/14.
//  Copyright (c) 2014 Stephen. All rights reserved.
//

#import "SettingsController.h"
#import "Settings.h"

@interface SettingsController ()

@end

@implementation SettingsController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) idleSwitchChanged:(UISwitch*)sendingSwitch;
{
    [[Settings sharedSettings] setGoesBlackWhenInactive:sendingSwitch.on];
    [self updateDisplay];
}

- (IBAction) darkThemeSwitchValueChanged:(UISwitch*)sendingSwitch;
{
    [[Settings sharedSettings] setDarkTheme:sendingSwitch.on];
    [self updateDisplay];
}

- (IBAction) shakeBarChanged:(UISegmentedControl*)theBar;
{
    [[Settings sharedSettings] setShakePurpose:(enum shakepurpose)theBar.selectedSegmentIndex];
    [self updateDisplay];
}

- (void) updateDisplay
{
    Settings * settings = [Settings sharedSettings];
    self.idleSwitch.on = [settings getGoesBlackWhenInactive];
    self.darkSwitch.on = [settings getDarkTheme];
    self.shakeBar.selectedSegmentIndex = (uint)[settings getCurrentShakePurpose];
   
    UIColor * chromeColor = self.darkSwitch.on ? [UIColor whiteColor] : [UIColor blackColor];
    
    UIColor * topBarColor = self.darkSwitch.on ? [UIColor blackColor] : [UIColor whiteColor];
    
    for (UILabel * titleLabel in self.titleCollection)
    {
        titleLabel.textColor = chromeColor;
    }
    
    self.view.backgroundColor = [settings getDarkTheme] ? [UIColor blackColor] : [UIColor whiteColor];
    self.navigationController.navigationBar.backgroundColor = topBarColor;

}

- (void) dealloc
{
    self.titleCollection = nil;
}

@end
