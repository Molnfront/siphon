/**
 *  Siphon SIP-VoIP for iPhone and iPod Touch
 *  Copyright (C) 2008 Samuel <samuelv@users.sourceforge.org>
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
#import "CallView.h"
#import "call.h"
#import "dtmf.h"

@implementation CallView  : UIView

//****************************************************************************************
//                                GUI Control
//****************************************************************************************

- (void)phonePad:(TPPhonePad *)phonepad keyDown:(char)car
{
  NSLog(@"keyDown %@ %c", phonepad, car);
  // DTMF
  sip_call_play_digit(_call_id, car);
}

- (void)endCallUpInside:(id)fp8
{
  NSLog(@"endCallUpInside %@", fp8);
  // Hold
  sip_hangup(&_call_id);
}

- (void)answerCallDown:(id)fp8
{
  NSLog(@"answerCallDown %@", fp8);
  sip_answer(&_call_id);
}

- (void)declineCallDown:(id)fp8
{
  NSLog(@"declineCallDown %@", fp8);
  sip_hangup(&_call_id);
}

//** **
//- (id)init:(pjsua_call_id)call_id
- (id)init
{
  struct CGRect hwRect, appRect;
 
  _call_id = PJSUA_INVALID_ID;
 
  hwRect  = [UIHardware fullScreenApplicationContentRect];
  appRect = hwRect;
  appRect.origin.x = appRect.origin.y = 0.0f;
 
  if ((self = [super initWithFrame: appRect]) != nil)
  {
    /** Background **/
    UIImageView *background = [[UIImageView alloc]
     initWithFrame:CGRectMake(0.0f, (-hwRect.origin.y), hwRect.size.width, 
      hwRect.size.height + hwRect.origin.y)];
    [background setImage:[UIImage defaultDesktopImage]];
    [self addSubview:background];
    
    /** Phone Pad **/
    _phonePad = [[TPPhonePad alloc] initWithFrame: CGRectMake(0.0f, 70.0f, 320.0f, 320.0f)];
    [_phonePad setPlaysSounds: TRUE];
    [_phonePad setNeedsDisplayForKey: TRUE];
    [_phonePad setDelegate: self];
  
    [self addSubview: _phonePad];
    
    /** End call **/
    _bottomBar = [[TPBottomButtonBar alloc] initForEndCallWithFrame: 
      CGRectMake(0.0f, 460.0f - 96.0f, 320.0f, 96.0f)];
    [[_bottomBar button] addTarget:self action:@selector(endCallUpInside:) 
      forEvents:kUIControlEventMouseUpInside/*kUIControlEventMouseDown*/];

    [self addSubview: _bottomBar];
//  /** Decline or Answer **/
//  _bottomBar = [[TPBottomDualButtonBar alloc] initForIncomingCallWithFrame:
//      CGRectMake(0.0f, 460.0f - 96.0f, 320.0f, 96.0f)];
//
//  [[_bottomBar button] addTarget:self action:@selector(declineCallDown:) 
//    forEvents:kUIControlEventMouseUpInside/*kUIControlEventMouseDown*/];
//  [[_bottomBar button2] addTarget:self action:@selector(answerCallDown:) 
//    forEvents:kUIControlEventMouseUpInside/*kUIControlEventMouseDown*/];

    /** LCD **/
    _lcd = [[TPLCDView alloc] initWithDefaultSize];
    [_lcd setLabel:@"Label"]; // name of callee
    [_lcd setText:@"Text"];   // timer, call state for example
//    [_lcd setSubImage:];  // image/avatar
    [self addSubview: _lcd];
  }
  
  return self;
}

/*** ***/
- (id)delegate 
{
  return _delegate;
}

- (void)setDelegate:(id)newDelegate 
{
  _delegate = newDelegate;
}

- (void)timeout:(id)unused
{
  pjsua_call_info ci;
  
  pjsua_call_get_info(_call_id, &ci);
  
  if (ci.connect_duration.sec >= 3600)
  {
    long sec = ci.connect_duration.sec % 3600;
    [_lcd setLabel:[NSString stringWithFormat:@"%d:%02d:%02d", 
                     ci.connect_duration.sec / 3600,
                     sec/60, sec%60]];
  }
  else
  {
    [_lcd setLabel:[NSString stringWithFormat:@"%02d:%02d", 
                     (ci.connect_duration.sec)/60,
                     (ci.connect_duration.sec)%60]];
  }
}

/*** ***/
- (void)setCallId:(pjsua_call_id)call_id
{
  pjsua_call_info ci;
  
  NSLog(@"CallView %d", call_id);
  _call_id = call_id;
  if (_call_id != PJSUA_INVALID_ID)
  {
    // TODO diplay user name or number
    // TODO display call state (CALLING, INCOMING, EARLY...) 
    // TODO activate timer after Connected state
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
         target:self
         selector:@selector(timeout:)
         userInfo:nil
         repeats:YES];
    [_timer fire];
  }
  else
  {
    [_timer invalidate];
  }
}

@end
