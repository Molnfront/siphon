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
#import <UIKit/UINavBarPrompt.h>
#import <UIKit/UIButtonBar.h>

#import <Message/NetworkController.h>
#import <iTunesStore/ISNetworkController.h>

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
        //[_transition transition:UITransitionFade toView:_radioListView];
        NSLog(@"Favorites");
        break;
      case 2:
        NSLog(@"Calls");
        //[_transition transition:UITransitionFade toView:_chartsView];
        break;
      case 3:
        [_transition transition:UITransitionShiftImmediate toView:_phoneView];
        break;
      case 4:
        NSLog(@"Contacts");       
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
  
  [ buttonBar showSelectionForButton: 3];
  
  return buttonBar;
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
  
  _buttonBar = [ self createButtonBar ];

  _currentView = 3;

  [_mainView addSubview: _buttonBar];

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
  NSLog(@"Resume");
  if (0)
  {
    // Settings are not defined !!!
  }
  else
  {
    [_transition transition:UITransitionShiftImmediate toView:_phoneView];
    [_buttonBar setAlpha: 1];
     _currentView = 3;
  }
}

- (void)applicationWillTerminate
{
  NSLog(@"Terminate");
//  [phoneView closeConn];
}

- (void)applicationSuspend:(struct __GSEvent *)event
{
  NSLog(@"Suspending\n");
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
  if(button == 1)
  {
    [self openURL:[NSURL URLWithString:@"http://code.google.com/p/siphon/"]];  
  }

  [help dismiss];
}

@end
