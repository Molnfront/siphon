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

#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>
#import <UIKit/UIAlertSheet.h>

#import <pjsua-lib/pjsua.h>

#import "DialerPhonePad.h"

@interface PhoneView : UIView
{
  UITextLabel *lbNumber;

  DialerPhonePad *_pad;

  UIPushButton *btnAdd;
  UIImage *imgConnect;
  UIImage *imgConnecting;
  UIImage *imgConnected;
  UIPushButton *btnCallHangup;
  UIImage *imgAnswer;
  UIImage *imgHangup;
  UIPushButton *btnDel;


  UIAlertSheet *incomming;

  BOOL connected;
  BOOL dialed;

  struct __GSFont *font;
  struct __GSFont *font2;

  pjsua_acc_id  _sip_acc_id;
  pjsua_call_id _sip_call_id;
}

-(id)initWithFrame:(struct CGRect)rect;

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button;

- (void)closeConn;

- (void)btnAddPress:(UIPushButton*)btn;
- (void)btnCallHangupPress:(UIPushButton*)btn;
- (void)btnDelPress:(UIPushButton*)btn;
@end
