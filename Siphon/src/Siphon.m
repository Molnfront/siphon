/**
 *  Siphon SIP-VoIP for iPhone and iPod Touch
 *  Copyright (C) 2008 Samuel <samuelv@users.sourceforge.org>
 *  Copyright (C) 2008 Christian Toepp <chris.touchmods@googlemail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#import "Siphon.h"
#import "version.h"
#import "call.h"

#import <UIKit/UINavBarPrompt.h>
#import <UIKit/UIButtonBar.h>

#import <Message/NetworkController.h>
#import <iTunesStore/ISNetworkController.h>

#import <GraphicsServices/GraphicsServices.h>

#include <unistd.h>

typedef enum
{
  UITransitionShiftImmediate = 0, // actually, zero or anything > 9
  UITransitionShiftLeft = 1,
  UITransitionShiftRight = 2,
  UITransitionShiftUp = 3,
  UITransitionFade = 6,
  UITransitionShiftDown = 7
} UITransitionStyle;


@implementation Siphon

/***** NETWORK : WIFI, EDGE ********/

- (BOOL)hasWiFiConnection 
{
    return ([[ISNetworkController sharedInstance] networkType] == 2);
}

- (BOOL) hasTelephony 
{
    return [[ISNetworkController sharedInstance] hasTelephony];
}

- (BOOL)hasNetworkConnection 
{
    if([self hasWiFiConnection]) 
    {
        return YES;
    }
    else if([[NSUserDefaults standardUserDefaults] integerForKey: @"siphonOverEDGE"] && [self hasTelephony]) 
    {
        if(![[NetworkController sharedInstance] isNetworkUp]) 
        {
            [[NetworkController sharedInstance] bringUpEdge];
            sleep(1);
        }
        return [[NetworkController sharedInstance] isNetworkUp];
    }
    else
    {
        return NO;
    }
}


/***** BUTTONBAR ********/
- (NSArray *)buttonBarItems 
{
  NSLog(@"buttonBarItems");
  return [ NSArray arrayWithObjects:
    [ NSDictionary dictionaryWithObjectsAndKeys:
           @"buttonBarItemTapped:", kUIButtonBarButtonAction,
           @"TopRated.png", kUIButtonBarButtonInfo,
           @"TopRatedSelected.png", kUIButtonBarButtonSelectedInfo,
           [ NSNumber numberWithInt: 1], kUIButtonBarButtonTag,
           self, kUIButtonBarButtonTarget,
           NSLocalizedString(@"Favorites", @"Siphon view"), kUIButtonBarButtonTitle,
           @"0", kUIButtonBarButtonType,
           nil 
           ],
    [ NSDictionary dictionaryWithObjectsAndKeys:
           @"buttonBarItemTapped:", kUIButtonBarButtonAction,
           @"History.png", kUIButtonBarButtonInfo,
           @"HistorySelected.png", kUIButtonBarButtonSelectedInfo,
           [ NSNumber numberWithInt: 2], kUIButtonBarButtonTag,
           self, kUIButtonBarButtonTarget,
           NSLocalizedString(@"Calls", @"Siphon view"), kUIButtonBarButtonTitle,
           @"0", kUIButtonBarButtonType,
           nil 
           ],
    [ NSDictionary dictionaryWithObjectsAndKeys:
           @"buttonBarItemTapped:", kUIButtonBarButtonAction,
           @"Dial.png", kUIButtonBarButtonInfo,
           @"DialSelected.png", kUIButtonBarButtonSelectedInfo,
           [ NSNumber numberWithInt: 3], kUIButtonBarButtonTag,
           self, kUIButtonBarButtonTarget,
           NSLocalizedString(@"Dialpad", @"Siphon view"), kUIButtonBarButtonTitle,
           @"0", kUIButtonBarButtonType,
           nil 
           ],
    [ NSDictionary dictionaryWithObjectsAndKeys:
           @"buttonBarItemTapped:", kUIButtonBarButtonAction,
           @"MostViewed.png", kUIButtonBarButtonInfo,
           @"MostViewedSelected.png", kUIButtonBarButtonSelectedInfo,
           [ NSNumber numberWithInt: 4], kUIButtonBarButtonTag,
           self, kUIButtonBarButtonTarget,
           NSLocalizedString(@"Contacts", @"Siphon view"), kUIButtonBarButtonTitle,
           @"0", kUIButtonBarButtonType,
           nil 
           ],         
    nil
  ];
}

- (void)buttonBarItemTapped:(id) sender 
{
  NSLog(@"buttonBarItemTapped");
  int button = [ sender tag ];
  if(button != _currentView) 
  {
    _currentView = button;    
    switch (button) 
    {
      case 1:
        NSLog(@"Favorites");
        break;
      case 2:
        NSLog(@"Calls");
        break;
      case 3:
        [_transition transition:UITransitionShiftImmediate toView:_phoneView];
        break;
      case 4:
        [_transition transition:UITransitionShiftImmediate toView:_contactView];
        break;        
    }
  }
}

- (UIButtonBar *)createButtonBar 
{
  NSLog(@"createButtonBar");
  UIButtonBar *buttonBar;
  buttonBar = [ [ UIButtonBar alloc ] 
          initInView: _mainView
          withFrame: CGRectMake(0.0f, 410.0f, 320.0f, 50.0f)
          withItemList: [ self buttonBarItems ] ];
  [buttonBar setDelegate:self];
  [buttonBar setBarStyle:1];
  [buttonBar setButtonBarTrackingMode: 2];

  int buttons[4] = { 1, 2, 3, 4};
  [buttonBar registerButtonGroup:0 withButtons:buttons withCount: 4];
 
  [buttonBar showButtonGroup: 0 withDuration: 0.0f];

  return buttonBar;
}

/************ **************/
- (void)volumeChange:(NSNotification *)notification 
{
  float     volume;
  NSString *audioDeviceName;
  AVSystemController *newav = [ notification object ];
  
  [newav getActiveCategoryVolume:&volume andName:&audioDeviceName];
  pjsua_conf_adjust_tx_level(0, volume * VOLUME_MULT);
  
  //  NSLog(@"Category %@ volume %f\n", audioDeviceName, volume);
}

/************ **************/
- (void) applicationDidFinishLaunching: (id) unused
{
  NSLog(@"Waking up on an %s (%@)...\n", [self hasTelephony] ? "iPhone" : "iPod Touch", 
        [[[NSUserDefaults standardUserDefaults] objectForKey: @"AppleLanguages"] objectAtIndex:0]);
  NSLog(@"Network connection is %s...\n", [self hasNetworkConnection] ? "up" : "down");
  NSLog(@"Edge connection is %s...\n", ([[NetworkController sharedInstance] isEdgeUp] ? "up" : "down"));
        
  CGRect windowRect = [ UIHardware fullScreenApplicationContentRect ];
  windowRect.origin.x = windowRect.origin.y = 0.0f;
  
  _window = [[UIWindow alloc] initWithContentRect: windowRect];
  [_window orderFront: self];
  [_window makeKey: self];
  [_window _setHidden: NO];
 
  _mainView = [[UIView alloc] initWithFrame: windowRect];
  [_window setContentView: _mainView];

  _transition = [[UITransitionView alloc] initWithFrame: windowRect];
  [_mainView addSubview: _transition];

  _phoneView = [[PhoneView alloc] initWithFrame: windowRect]; 
  
  _contactView = [[ContactView alloc] initWithFrame: /*windowRect*/
    CGRectMake(windowRect.origin.x, windowRect.origin.y, 
      windowRect.size.width, windowRect.size.height - 49.0f)];
  [_contactView setDelegate: self];

  _buttonBar = [ self createButtonBar ];
  [_mainView addSubview: _buttonBar];

  _avs = [AVSystemController sharedAVSystemController];
  [[NSNotificationCenter defaultCenter] addObserver: self 
    selector:@selector(volumeChange:) 
    name: @"AVSystemController_SystemVolumeDidChangeNotification"
    object: _avs ];

  help = [[UIAlertSheet alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 280.0f, 300.0f)];
  [help setTitle: @"About Siphon"];

  [help setBodyText:@"Siphon Version 2.0\n"
    "Samuel, Metabaron\n"
    "Help, FAQ and more at\n"
    "http://code.google.com/p/siphon/"];
    [help addButtonWithTitle:@"Visit Site"];

  [help addButtonWithTitle:@"OK"];
  [help setDelegate:self];

  [self addStatusBarImageNamed: @"Siphon" removeOnAbnormalExit: YES];

  [self applicationResume:nil settings:nil];
}

- (void)applicationResume:(struct __GSEvent *)event settings:(id)settings
{
  NSUserDefaults *userDef;
  NSLog(@"Resume");
  userDef = [NSUserDefaults standardUserDefaults];
  if (![[userDef objectForKey: @"sip_user"] length])
  {
    // TODO: go to settings immediately
    
    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    [navBar setFrame:CGRectMake(0, 0, 320,45)];
    [navBar pushNavigationItem: [[UINavigationItem alloc] initWithTitle:VERSION_STRING]];
    [navBar setBarStyle: 0];
    [_mainView addSubview:navBar];

    float bg[] = {255., 255., 255., 1.};
    struct CGColor *bgColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(),bg);
    [_mainView setBackgroundColor: bgColor];

    UIImageView *background = [[UIImageView alloc] 
      initWithFrame:CGRectMake(0.0f, 45.0f, 320.0f, 185.0f)];
    [background setImage:[[UIImage alloc] 
      initWithContentsOfFile:[[NSBundle mainBundle] pathForResource :@"settings" ofType:@"png"]]];
    [_mainView addSubview:background];
    float transparentComponents[4] = {0, 0, 0, 0};
    UITextLabel *text = [[UITextLabel alloc] 
      initWithFrame: CGRectMake(0, 220, 320, 200.0f)];
    [text setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), 
      transparentComponents)];
    [text setCentersHorizontally: YES];
    [text setWrapsText: YES];
    [text setFont:GSFontCreateWithName("Helvetica", 0, 18.0f)];
    [text setText:NSLocalizedString(@"Siphon requires a valid\nSIP account.\n\nTo enter this information, select \"Settings\" from your Home screen, and then tap the \"Siphon\" entry.", @"Intro page greeting")];
    [_mainView addSubview:text];

    text = [[UITextLabel alloc] initWithFrame: CGRectMake(0, 420, 320, 40.0f)];
    [text setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), transparentComponents)];
    [text setCentersHorizontally: YES];
    [text setFont:GSFontCreateWithName("Helvetica", 0, 16.0f)];
    [text setText:NSLocalizedString(@"Press the Home button", @"Intro page greeting")];
    [_mainView addSubview:text];

    [_buttonBar setAlpha: 0];
    _currentView = 0;
  }
  else
  {
    [_transition transition:UITransitionShiftImmediate toView:_phoneView];
    [_buttonBar showSelectionForButton: 3];
    [_buttonBar setAlpha: 1];
     _currentView = 3;
  }
}

- (void)applicationWillTerminate
{
  NSLog(@"Terminate");
//  [phoneView closeConn];
  exit(0);
}

- (void)applicationSuspend:(struct __GSEvent *)event
{
  if(_currentView) 
  {
    NSLog(@"Suspending\n");
  } 
  else 
  {
    [self applicationWillTerminate];
  }
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
  if(button == 1)
  {
    [self openURL:[NSURL URLWithString:@"http://code.google.com/p/siphon/"]];  
  }

  [help dismiss];
}

/** FIXME plutot à mettre dans l'objet qui gère les appels **/
- (void)contactSelected:(NSString *)phoneNumber
{
  // Check selected value
  NSString* selectedName = [_contactView getSelectedContactName];
  NSString* selectedPhone = [_contactView getSelectedPropertyValue];
  NSLog(@"Contact %@, number %@ is selected",selectedName,selectedPhone);
//  NSLog(@"OK. Phonenumber: %s",[[_contactsView getSelectedPropertyValue] UTF8String]);
  NSLog(@"OK. Phonenumber: %@",phoneNumber);
}

@end
