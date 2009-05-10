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
#import "PhonePad.h"
#import "BottomButtonBar.h"
#import "BottomDualButtonBar.h"
#import "MenuCallView.h"
#import "LCDView.h"
#import "RecentCall.h"

#include <pjsua-lib/pjsua.h>

@interface CallViewController : UIViewController<PhonePad>
{
  LCDView             *_lcd;
  
  UIView		          *_containerView;
  PhonePad            *_phonePad;
  MenuCallView        *_menuView;

  BottomDualButtonBar *_defaultBottomBar;
  UIButton            *_menuButton;

  BottomDualButtonBar *_dualBottomBar;

  NSTimer *_timer;

  pjsua_call_id  _call_id;
  RecentCall    *_call[PJSUA_MAX_CALLS];
}

#if 0
- (void)setState:(int)state callId:(pjsua_call_id)call_id;
#else
- (void)processCall:(NSDictionary *)userinfo;
#endif
@end
