/**
 *  Siphon SIP-VoIP for iPhone and iPod Touch
 *  Copyright (C) Christian Toepp <chris.touchmods@googlemail.com>
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
#import <UIKit/UIScroller.h>

@interface AccountView : UIView
{
  NSString *settingsPath;
  UIScroller *scrollView;
  UITextField *edUserName;
  UITextField *edPassword;
  UITextField *edServer;
  UITextField *edRegTimeout;
  UIPushButton *edNAT;
  UITextField *edStunDomain;
  UITextField *edStunServer;
  UIPushButton *btnSave;
  UIKeyboard *keyboard;
}
- (void)myinit;
- (void)checkEvent:(UIPushButton*)box;
- (void)saveEvent:(UIPushButton*)box;
- (void)keyboardInput:(id)k shouldInsertText:(id)i isMarkedText:(int)b;
- (void)view:(UIView *)view handleTapWithCount:(int)count event:(struct __GSEvent *)event;
- (void)loadData;
- (void)saveData;
- (void)loadDefaults;
- (NSString*)getUserName;
- (NSString*)getPassword;
- (NSString*)getServer;
- (NSString*)getRegTimeout;
- (BOOL)getNAT;
- (NSString*)getStunDomain;
- (NSString*)getStunServer;
@end
