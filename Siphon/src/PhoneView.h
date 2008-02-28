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

@interface PhoneView : UIView
{
  UITextLabel *lbNumber;
  UIPushButton *btn1;
  UIPushButton *btn2;
  UIPushButton *btn3;
  UIPushButton *btn4;
  UIPushButton *btn5;
  UIPushButton *btn6;
  UIPushButton *btn7;
  UIPushButton *btn8;
  UIPushButton *btn9;
  UIPushButton *btnStar;
  UIPushButton *btn0;
  UIPushButton *btnHash;
  UIPushButton *btnAdd;
  UIImage *imgConnect;
  UIImage *imgConnecting;
  UIImage *imgConnected;
  UIPushButton *btnCallHangup;
  UIImage *imgAnswer;
  UIImage *imgHangup;
  UIPushButton *btnDel;
  AccountView *accountView;

  UIAlertSheet *incomming;

  BOOL connected;
  BOOL dialed;

  struct __GSFont *font;
  struct __GSFont *font2;

  pjsua_acc_id  _sip_acc_id;
  pjsua_call_id _sip_call_id;
}

-(id)initWithFrame:(struct CGRect)frame account:(AccountView*)account;

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button;

- (void)closeConn;

- (void)btn1Press:(UIPushButton*)btn;
- (void)btn2Press:(UIPushButton*)btn;
- (void)btn3Press:(UIPushButton*)btn;
- (void)btn4Press:(UIPushButton*)btn;
- (void)btn5Press:(UIPushButton*)btn;
- (void)btn6Press:(UIPushButton*)btn;
- (void)btn7Press:(UIPushButton*)btn;
- (void)btn8Press:(UIPushButton*)btn;
- (void)btn9Press:(UIPushButton*)btn;
- (void)btn0Press:(UIPushButton*)btn;
- (void)btnAddPress:(UIPushButton*)btn;
- (void)btnCallHangupPress:(UIPushButton*)btn;
- (void)btnDelPress:(UIPushButton*)btn;
@end
