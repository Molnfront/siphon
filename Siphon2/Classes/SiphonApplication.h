/**
 *  Siphon SIP-VoIP for iPhone and iPod Touch
 *  Copyright (C) 2008-2009 Samuel <samuelv0304@gmail.com>
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

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "CallViewController.h"
#import "RecentsViewController.h"
#import "PhoneViewController.h"

#include "call.h"

@class SiphonApplication;

@interface SiphonApplication : UIApplication <UIActionSheetDelegate, UIApplicationDelegate
#if defined(CYDIA) && (CYDIA == 1)
  , UIAlertViewDelegate
#endif
>
{
  UIWindow *window;
 // UINavigationController *navController;
  UITabBarController *tabBarController;

  PhoneViewController   *phoneViewController;
  RecentsViewController *recentsViewController;
  CallViewController    *callViewController;

  app_config_t _app_config; // pointer ???
  BOOL isConnected;
  BOOL isIpod;

  pjsua_acc_id  _sip_acc_id;

@private
  NSString *_phoneNumber;
  BOOL launchDefault;
}

@property (nonatomic, retain) UIWindow *window;
//@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, assign, readonly) RecentsViewController *recentsViewController;
@property (nonatomic, readonly) BOOL isIpod;

@property BOOL launchDefault;
@property BOOL isConnected;

-(void)displayError:(NSString *)error withTitle:(NSString *)title;
-(void)displayParameterError:(NSString *)error;

-(void)disconnected:(id)fp8;

//-(RecentsViewController *)recentsViewController;
- (app_config_t *)pjsipConfig;

@end
