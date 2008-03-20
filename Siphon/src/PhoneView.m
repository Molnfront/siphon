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
#import <UIKit/UITextField-Internal.h>
#import <UIKit/UITextField-SyntheticEvents.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITextFieldBackground.h>
#import <UIKit/UITextFieldLabel.h>

#import <CoreGraphics/CGGeometry.h>
#import <OSServices/SystemSound.h>

#import <Message/NetworkController.h>
#import <iTunesStore/ISNetworkController.h>
#import <WebCore/WebFontCache.h>

#import "AccountView.h"
#import "PhoneView.h"

#include "call.h"
#include "dtmf.h"

@implementation PhoneView

- (BOOL)hasWiFiConnection 
{
    return ([[ISNetworkController sharedInstance] networkType] == 2);
}

-(id)initWithFrame:(struct CGRect)frame account:(AccountView*)account
{
  self = [super initWithFrame:frame];
  
  _sip_acc_id = PJSUA_INVALID_ID;
  _sip_call_id = PJSUA_INVALID_ID;

  accountView = account;
  
  UIImageView *background = [[[UIImageView alloc] 
      initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 
      frame.size.width,frame.size.height-66.0f)] autorelease];
  [background setImage:[[UIImage alloc] 
      initWithContentsOfFile:[[NSBundle mainBundle] 
      pathForResource :@"TEL-background-top" ofType:@"png"
      inDirectory:@"skins"]]];
  [self addSubview:background];

  font = [NSClassFromString(@"WebFontCache") 
         createFontWithFamily:@"Helvetica" 
         traits:2 size:35];
  font2 = [NSClassFromString(@"WebFontCache") 
         createFontWithFamily:@"Helvetica" 
         traits:2 size:20];

  struct __GSFont *btnFont = [NSClassFromString(@"WebFontCache") 
                 createFontWithFamily:@"Helvetica" 
                 traits:2 size:16];

  float fnt[] = {255, 255, 255, 1};
  struct CGColor *fntColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(),fnt);
  float bg[] = {0, 0, 0, 0};
  struct CGColor *bgColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(),bg);
  float bg2[] = {255, 255, 255, 1};
  struct CGColor *bg2Color = CGColorCreate(CGColorSpaceCreateDeviceRGB(),bg2);
  
  lbNumber = [[UITextLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 65.0f)];
  [lbNumber setCentersHorizontally:TRUE];
  [lbNumber setFont: font2];

  [lbNumber setText: @"   Please connect to SIP-Server"];
 
  [lbNumber setColor: fntColor];
  [lbNumber setBackgroundColor: bgColor];

  UIImage* btn1Image = [UIImage imageNamed:@"skins/TEL-key-1.png"];
  btn1 = [[UIPushButton alloc] init];
  [btn1 setAutosizesToFit: NO];
  [btn1 setFrame: CGRectMake(1.0f, 74.0f, 105.0f, 68.0f)];
  [btn1 addTarget:self action:@selector(btn1Press:) forEvents:1];
  [btn1 setImage:btn1Image forState:1];
  [btn1 setEnabled: NO];

  UIImage* btn2Image = [UIImage imageNamed:@"skins/TEL-key-2.png"];
  btn2 = [[UIPushButton alloc] init];
  [btn2 setAutosizesToFit: NO];
  [btn2 setFrame: CGRectMake(107.0f, 74.0f, 105.0f, 68.0f)];
  [btn2 addTarget:self action:@selector(btn2Press:) forEvents:1];
  [btn2 setImage:btn2Image forState:1];
  [btn2 setEnabled: NO];

  UIImage* btn3Image = [UIImage imageNamed:@"skins/TEL-key-3.png"];
  btn3 = [[UIPushButton alloc] init];
  [btn3 setAutosizesToFit: NO];
  [btn3 setFrame: CGRectMake(213.0f, 74.0f, 105.0f, 68.0f)];
  [btn3 addTarget:self action:@selector(btn3Press:) forEvents:1];
  [btn3 setImage:btn3Image forState:1];
  [btn3 setEnabled: NO];

  UIImage* btn4Image = [UIImage imageNamed:@"skins/TEL-key-4.png"];
  btn4 = [[UIPushButton alloc] init];
  [btn4 setAutosizesToFit: NO];
  [btn4 setFrame: CGRectMake(1.0f, 142.0f, 105.0f, 68.0f)];
  [btn4 addTarget:self action:@selector(btn4Press:) forEvents:1];
  [btn4 setImage:btn4Image forState:1];
  [btn4 setEnabled: NO];

  UIImage* btn5Image = [UIImage imageNamed:@"skins/TEL-key-5.png"];
  btn5 = [[UIPushButton alloc] init];
  [btn5 setAutosizesToFit: NO];
  [btn5 setFrame: CGRectMake(107.0f, 142.0f, 105.0f, 68.0f)];
  [btn5 addTarget:self action:@selector(btn5Press:) forEvents:1];
  [btn5 setImage:btn5Image forState:1];
  [btn5 setEnabled: NO];

  UIImage* btn6Image = [UIImage imageNamed:@"skins/TEL-key-6.png"];
  btn6 = [[UIPushButton alloc] init];
  [btn6 setAutosizesToFit: NO];
  [btn6 setFrame: CGRectMake(213.0f, 142.0f, 105.0f, 68.0f)];
  [btn6 addTarget:self action:@selector(btn6Press:) forEvents:1];
  [btn6 setImage:btn6Image forState:1];
  [btn6 setEnabled: NO];

  UIImage* btn7Image = [UIImage imageNamed:@"skins/TEL-key-7.png"];
  btn7 = [[UIPushButton alloc] init];
  [btn7 setAutosizesToFit: NO];
  [btn7 setFrame: CGRectMake(1.0f, 210.0f, 105.0f, 68.0f)];
  [btn7 addTarget:self action:@selector(btn7Press:) forEvents:1];
  [btn7 setImage:btn7Image forState:1];
  [btn7 setEnabled: NO];

  UIImage* btn8Image = [UIImage imageNamed:@"skins/TEL-key-8.png"];
  btn8 = [[UIPushButton alloc] init];
  [btn8 setAutosizesToFit: NO];
  [btn8 setFrame: CGRectMake(107.0f, 210.0f, 105.0f, 68.0f)];
  [btn8 addTarget:self action:@selector(btn8Press:) forEvents:1];
  [btn8 setImage:btn8Image forState:1];
  [btn8 setEnabled: NO];

  UIImage* btn9Image = [UIImage imageNamed:@"skins/TEL-key-9.png"];
  btn9 = [[UIPushButton alloc] init];
  [btn9 setAutosizesToFit: NO];
  [btn9 setFrame: CGRectMake(213.0f, 210.0f, 105.0f, 68.0f)];
  [btn9 addTarget:self action:@selector(btn9Press:) forEvents:1];
  [btn9 setImage:btn9Image forState:1];
  [btn9 setEnabled: NO];

  UIImage* btnStarImage = [UIImage imageNamed:@"skins/TEL-key-La.png"];
  btnStar = [[UIPushButton alloc] init];
  [btnStar setAutosizesToFit: NO];
  [btnStar setFrame: CGRectMake(1.0f, 278.0f, 105.0f, 68.0f)];
  [btnStar addTarget:self action:@selector(btnStarPress:) forEvents:1];
  [btnStar setImage:btnStarImage forState:1];
  [btnStar setEnabled: NO];

  UIImage* btn0Image = [UIImage imageNamed:@"skins/TEL-key-0.png"];
  btn0 = [[UIPushButton alloc] init];
  [btn0 setAutosizesToFit: NO];
  [btn0 setFrame: CGRectMake(107.0f, 278.0f, 105.0f, 68.0f)];
  [btn0 addTarget:self action:@selector(btn0Press:) forEvents:1];
  [btn0 setImage:btn0Image forState:1];
  [btn0 setEnabled: NO];

  UIImage* btnHashImage = [UIImage imageNamed:@"skins/TEL-key-Ra.png"];
  btnHash = [[UIPushButton alloc] init];
  [btnHash setAutosizesToFit: NO];
  [btnHash setFrame: CGRectMake(213.0f, 278.0f, 105.0f, 68.0f)];
  [btnHash setImage:btnHashImage forState:1];

  // UIImage* btnAddImage = [UIImage imageNamed:@"skins/TEL-key-Lb.png"];
  imgConnecting = [UIImage imageNamed:@"skins/TEL-key-sip-connecting.png"];
  imgConnected = [UIImage imageNamed:@"skins/TEL-key-sip-connected.png"];
  btnAdd = [[UIPushButton alloc] init];
  [btnAdd setAutosizesToFit: NO];
  [btnAdd setFrame: CGRectMake(1.0f, 346.0f, 105.0f, 68.0f)];
  [btnAdd addTarget:self action:@selector(btnAddPress:) forEvents:1];
  // [btnAdd setTitle: @"Connect"];
  [btnAdd setTitleColor: bg2Color forState:0];
  [btnAdd setTitleColor: bg2Color forState:1];
  [btnAdd setTitleFont: btnFont];
  [btnAdd setDrawContentsCentered: YES];
  [btnAdd setImage:nil forState:0];


  // UIImage* btnCallImage = [UIImage imageNamed:@"skins/TEL-key-CALL.png"];
  imgAnswer = [UIImage imageNamed:@"skins/TEL-key-tel-answer.png"];
  imgHangup = [UIImage imageNamed:@"skins/TEL-key-tel-hangup.png"];
  btnCallHangup = [[UIPushButton alloc] init];
  [btnCallHangup setAutosizesToFit: NO];
  [btnCallHangup setFrame: CGRectMake(107.0f, 346.0f, 105.0f, 68.0f)];
  [btnCallHangup addTarget:self action:@selector(btnCallHangupPress:) forEvents:1];
  [btnCallHangup setImage:nil forState:0];
  // [btnCallHangup setTitle: @"Dial"];
  [btnCallHangup setTitleColor: bg2Color forState:0];
  [btnCallHangup setTitleColor: bg2Color forState:1];
  [btnCallHangup setTitleFont: btnFont];
  [btnCallHangup setDrawContentsCentered: YES];

  UIImage* btnDelImage = [UIImage imageNamed:@"skins/TEL-key-Rb.png"];
  btnDel = [[UIPushButton alloc] init];
  [btnDel setAutosizesToFit: NO];
  [btnDel setFrame: CGRectMake(213.0f, 346.0f, 105.0f, 68.0f)];
  [btnDel addTarget:self action:@selector(btnDelPress:) forEvents:1];
  [btnDel setImage:btnDelImage forState:1];
  [btnDel setEnabled: NO];

  incomming = [[UIAlertSheet alloc] initWithFrame:CGRectMake(20.0f, 50.0f, 280.0f, 200.0f)];
  [incomming setTitle:@"Incomming Call"];
  [incomming addButtonWithTitle:@"Answer"];
  [incomming addButtonWithTitle:@"Reject"];
  [incomming setDelegate:self];

  [self addSubview: lbNumber];
  [self addSubview: btn1];
  [self addSubview: btn2];
  [self addSubview: btn3];
  [self addSubview: btn4];
  [self addSubview: btn5];
  [self addSubview: btn6];
  [self addSubview: btn7];
  [self addSubview: btn8];
  [self addSubview: btn9];
  [self addSubview: btnStar];
  [self addSubview: btn0];
  [self addSubview: btnHash];
  [self addSubview: btnAdd];
  [self addSubview: btnCallHangup];
  [self addSubview: btnDel];
  connected = NO;
  [btnCallHangup setEnabled: NO];
  
  return self;
}

- (void)closeConn
{
  if (_sip_acc_id != PJSUA_INVALID_ID)
  {
    sip_disconnect(&_sip_acc_id);
  }
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
  if(button == 1)
  {
    sip_answer(&_sip_call_id);
    [btnCallHangup setImage:imgHangup forState:0];
  }
  else
  {
    sip_hangup(&_sip_call_id);
    [lbNumber setText:@""];
    [lbNumber setFont:font];
    [btnCallHangup setImage:nil forState:0];
  }
  [sheet dismiss];
}

-(void)appendChar:(NSString *)car
{
  NSString *curText = [lbNumber text];
  if([lbNumber font] == font && [[lbNumber text] length] == 15)
  {
    [lbNumber setFont:font2];
  }
  [lbNumber setText: [curText stringByAppendingString: car]];
  if (_sip_call_id != PJSUA_INVALID_ID)
  {
    const char *sd = [car UTF8String];
    if (sd && strlen(sd) > 0)
    {
      sip_call_play_digit(_sip_call_id, sd[0]);
    }
  }
}

- (void)btnStarPress:(UIPushButton*)btn
{
  [self appendChar:@"*"];
}

- (void)btn1Press:(UIPushButton*)btn
{
  [self appendChar:@"1"];
}

- (void)btn2Press:(UIPushButton*)btn
{
  [self appendChar:@"2"];
}

- (void)btn3Press:(UIPushButton*)btn
{
  [self appendChar:@"3"];
}

- (void)btn4Press:(UIPushButton*)btn
{
  [self appendChar:@"4"];
}

- (void)btn5Press:(UIPushButton*)btn
{
  [self appendChar:@"5"];
}

- (void)btn6Press:(UIPushButton*)btn
{
  [self appendChar:@"6"];
}

- (void)btn7Press:(UIPushButton*)btn
{
  [self appendChar:@"7"];
}

- (void)btn8Press:(UIPushButton*)btn
{
  [self appendChar:@"8"];
}

- (void)btn9Press:(UIPushButton*)btn
{
  [self appendChar:@"9"];
}

- (void)btn0Press:(UIPushButton*)btn
{
  [self appendChar:@"0"];
}

- (void)btnAddPress:(UIPushButton*)btn
{
  // if([btnAdd title] == @"Connect"){
  if([btnAdd currentImage] == nil){
#if 0 // Manage edge    
    if ([self hasWiFiConnection] == FALSE)
    {
        UIAlertSheet * zSheet;
    
    zSheet = [[UIAlertSheet alloc] initWithFrame:CGRectMake(0,240,320,240)];
    [zSheet setTitle:@"Infomation"];
    [zSheet setBodyText: @"\nWi-Fi unavailable\n\n"];
    [zSheet setRunsModal: true]; 
    [zSheet popupAlertAnimated:YES]; //Displays
              //Pauses here until user taps the sheet closed
        return;
    }
#endif    
    if (sip_startup())
    {
      return;
    }
    if (sip_connect([[accountView getServer] UTF8String],
      [[accountView getUserName] UTF8String],
      [[accountView getPassword] UTF8String], &_sip_acc_id))
    { 
      UIAlertSheet * zSheet;
    
    zSheet = [[UIAlertSheet alloc] initWithFrame:CGRectMake(0,240,320,240)];
    [zSheet setTitle:@"Error"];
    [zSheet setBodyText: @"\nConnection error\nVerify your account parameters\n\n"];
    [zSheet setRunsModal: true]; //I'm a big fan of running sheet modally
    [zSheet popupAlertAnimated:YES];
      
      return ;
    }
    
    [btnAdd setImage:imgConnecting forState:0];
   
    [btnAdd setImage:imgConnected forState:0];
    [btn1 setEnabled: YES];
    [btn2 setEnabled: YES];
    [btn3 setEnabled: YES];
    [btn4 setEnabled: YES];
    [btn5 setEnabled: YES];
    [btn6 setEnabled: YES];
    [btn7 setEnabled: YES];
    [btn8 setEnabled: YES];
    [btn9 setEnabled: YES];
    [btn0 setEnabled: YES];
    [btnStar setEnabled: YES];
    [btnDel setEnabled: YES];
    [btnCallHangup setEnabled: YES];
    [lbNumber setText:@""];
    [lbNumber setFont:font];
  }
  else
  {  
    if (_sip_acc_id != PJSUA_INVALID_ID)
    {
      sip_disconnect(&_sip_acc_id);
      sip_cleanup();
    }

    [btnAdd setImage:nil forState:0];
    [btn1 setEnabled: NO];
    [btn2 setEnabled: NO];
    [btn3 setEnabled: NO];
    [btn4 setEnabled: NO];
    [btn5 setEnabled: NO];
    [btn6 setEnabled: NO];
    [btn7 setEnabled: NO];
    [btn8 setEnabled: NO];
    [btn9 setEnabled: NO];
    [btn0 setEnabled: NO];
    [btnStar setEnabled: NO];
    [btnDel setEnabled: NO];
    [btnCallHangup setEnabled: NO];
    [lbNumber setFont:font2];
    [lbNumber setText:@"   Please connect to SIP-Server"];
  }
}

- (void)btnCallHangupPress:(UIPushButton*)btn
{
  if([btnCallHangup currentImage] == nil && [[lbNumber text] length] > 1)
  {
    [btnCallHangup setImage:imgHangup forState:0];
    if (sip_dial(_sip_acc_id,
      [[lbNumber text] UTF8String],
      [[accountView getServer] UTF8String], &_sip_call_id))
      {
        [btnCallHangup setImage:nil forState:0];
        [lbNumber setText:@""];
      }
  }
  else if([btnCallHangup currentImage] == imgAnswer)
  {
    sip_answer(&_sip_call_id);
  }
  else
  {
    sip_hangup(&_sip_call_id);
    [btnCallHangup setImage:nil forState:0];
    [lbNumber setText:@""];
    [lbNumber setFont: font];
  }
}

- (void)btnDelPress:(UIPushButton*)btn
{
  NSString *curText = [lbNumber text];
  if([curText length] > 0){
    [lbNumber setText: [curText substringToIndex:([curText length]-1)]];
  }
  if([lbNumber font] == font2 && [[lbNumber text] length] == 15){
    [lbNumber setFont:font];
  }
}

@end

