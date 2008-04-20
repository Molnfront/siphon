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

#import "Siphon.h"
#import "PhoneView.h"

#include "call.h"
#include "dtmf.h"

@implementation PhoneView

- (BOOL)hasWiFiConnection 
{
    return ([[ISNetworkController sharedInstance] networkType] == 2);
}

-(id)initWithFrame:(struct CGRect)frame
{
  
  if ((self = [super initWithFrame:frame]) != nil)
  {
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

//  struct __GSFont *btnFont = [NSClassFromString(@"WebFontCache") 
//                 createFontWithFamily:@"Helvetica" 
//                 traits:2 size:16];

  float fnt[] = {255, 255, 255, 1};
  struct CGColor *fntColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(),fnt);
  float bg[] = {0, 0, 0, 0};
  struct CGColor *bgColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(),bg);
//  float bg2[] = {255, 255, 255, 1};
//  struct CGColor *bg2Color = CGColorCreate(CGColorSpaceCreateDeviceRGB(),bg2);
  
  lbNumber = [[UITextLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 65.0f)];
  [lbNumber setCentersHorizontally:TRUE];
  [lbNumber setFont: font];
  [lbNumber setAlignment: 1]; // Center
  [lbNumber setColor: fntColor];
  [lbNumber setBackgroundColor: bgColor];
  [lbNumber setTextAutoresizesToFit:YES];
  [lbNumber setText: @""];
//  [lbNumber setText: NSLocalizedString(@"Please connect to SIP-Server", 
//    @"PhoneView")];

  _pad = [[DialerPhonePad alloc] initWithFrame:
        CGRectMake(0.0f, 74.0f, 320.0f, 273.0f)];
  [_pad setPlaysSounds:TRUE];
  [_pad setDelegate:self];

  // UIImage* btnAddImage = [UIImage imageNamed:@"skins/TEL-key-Lb.png"];
 
  btnCallHangup = [[UIPushButton alloc] init];
  [btnCallHangup setAutosizesToFit: NO];
  [btnCallHangup setFrame: CGRectMake(107.0f, 346.0f, 105.0f, 68.0f)];
  [btnCallHangup addTarget:self action:@selector(btnCallHangupPress:) forEvents:1];
  [btnCallHangup setImage:nil forState:0];
  // [btnCallHangup setTitle: @"Dial"];
//  [btnCallHangup setTitleColor: bg2Color forState:0];
//  [btnCallHangup setTitleColor: bg2Color forState:1];
//  [btnCallHangup setTitleFont: btnFont];
  [btnCallHangup setDrawContentsCentered: YES];

  UIImage* btnDelImage = [UIImage imageNamed:@"skins/TEL-key-Rb.png"];
  btnDel = [[UIPushButton alloc] init];
  [btnDel setAutosizesToFit: NO];
  [btnDel setFrame: CGRectMake(213.0f, 346.0f, 105.0f, 68.0f)];
  [btnDel addTarget:self action:@selector(btnDelPress:) forEvents:1];
  [btnDel setImage:btnDelImage forState:1];
//  [btnDel setEnabled: NO];


  [self addSubview: lbNumber];

  [self addSubview: _pad];

//  [self addSubview: btnAdd];
  [self addSubview: btnCallHangup];
  [self addSubview: btnDel];
  }
  return self;
}

/*** Buttons callback ***/
- (void)phonePad:(TPPhonePad *)phonepad appendString:(NSString *)string
{
  NSString *curText = [lbNumber text];
  [lbNumber setText: [curText stringByAppendingString: string]];
}

- (void)btnAddPress:(UIPushButton*)btn
{

}

- (void)btnCallHangupPress:(UIPushButton*)btn
{
  if (([[lbNumber text] length] > 1) && 
      ([_delegate respondsToSelector:@selector(dialup:)])) 
    {
      [_delegate dialup: [lbNumber text]];
      [lbNumber setText:@""];
    }
}

- (void)btnDelPress:(UIPushButton*)btn
{
  NSString *curText = [lbNumber text];
  if([curText length] > 0)
  {
    [lbNumber setText: [curText substringToIndex:([curText length]-1)]];
  }
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


@end

