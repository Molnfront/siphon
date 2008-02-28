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
#import <UIKit/UITextField-Internal.h>
#import <UIKit/UITextField-SyntheticEvents.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITextFieldBackground.h>
#import <UIKit/UITextFieldLabel.h>

#import <Foundation/NSBundle.h>

#import <CoreGraphics/CGGeometry.h>

#import <WebCore/WebFontCache.h>

#import "AccountView.h"

@implementation AccountView

- (void) myinit
{
  settingsPath = [[NSBundle mainBundle] pathForResource:@"accounts" 
    ofType:@"xml" 
    inDirectory:@""];
  [settingsPath retain];
  struct __GSFont *font = [NSClassFromString(@"WebFontCache") 
			  createFontWithFamily:@"Helvetica" 
			  traits:2 size:14];
//  float inp[] = {255, 0, 0, 1};
//  struct CGColor *inpColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), inp);
  /*
  float bg[] = {255, 255, 255, 1};
  struct CGColor *bgColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), bg);
  [self setBackgroundColor: bgColor];
  */
  UIImage *bgImage = [UIImage imageNamed:@"skins/SETTINGS-background.png"];

  keyboard = [[UIKeyboard alloc] initWithFrame: CGRectMake(0.0f, 200.0f, 320.0f, 220.0f)];

  scrollView = [[UIScroller alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 414.0f)];
//  [scrollView setScrollingEnabled: NO];
  [scrollView setScrollingEnabled: YES];
  struct CGSize cntSize;
  cntSize.width = 320.0f;
  cntSize.height = 414.0f;
  [scrollView setContentSize: cntSize];
  UIView *secView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 414.0f)];
  [secView _setContentImage:bgImage];

  edUserName = [[UITextField alloc] initWithFrame: CGRectMake(100.0f, 20.0f, 200.0f, 30.0f)];
  [edUserName setFont: font];
  [edUserName setTextCentersVertically: YES];
  [edUserName setTapDelegate: self];
  [[edUserName textTraits] setEditingDelegate:self];

  edPassword = [[UITextField alloc] initWithFrame: CGRectMake(100.0f, 70.0f, 200.0f, 30.0f)];
  [edPassword setFont: font];
  [edPassword setTextCentersVertically: YES];
  [edPassword setTapDelegate: self];
  [[edPassword textTraits] setEditingDelegate:self];
  [edPassword setSecure: YES];

  edServer = [[UITextField alloc] initWithFrame: CGRectMake(100.0f, 120.0f, 200.0f, 30.0f)];
  [edServer setFont: font];
  [edServer setTextCentersVertically: YES];
  [edServer setTapDelegate: self];
  [[edServer textTraits] setEditingDelegate:self];
 
  edRegTimeout = [[UITextField alloc] initWithFrame: CGRectMake(100.0f, 170.0f, 200.0f, 30.0f)];
  [edRegTimeout setFont: font];
  [edRegTimeout setTextCentersVertically: YES];
  [edRegTimeout setTapDelegate: self];
  [[edRegTimeout textTraits] setEditingDelegate:self];

  edNAT = [[UIPushButton alloc] initWithFrame: CGRectMake(100.0f, 220.0f, 200.0f, 30.0f)];
  [edNAT setTitle: @"YES"];
  [edNAT setAutosizesToFit: false];
  [edNAT addTarget:self action:@selector(checkEvent:) forEvents: 1];
  [edNAT setFrame: CGRectMake(100.0f, 220.0f, 200.0f, 30.0f)];
  [edNAT setDrawContentsCentered: YES];

  edStunDomain = [[UITextField alloc] initWithFrame: CGRectMake(100.0f, 270.0f, 200.0f, 30.0f)];
  [edStunDomain setFont: font];
  [edStunDomain setTextCentersVertically: YES];
  [edStunDomain setTapDelegate: self];
  [[edStunDomain textTraits] setEditingDelegate:self];

  edStunServer = [[UITextField alloc] initWithFrame: CGRectMake(100.0f, 320.0f, 200.0f, 30.0f)];
  [edStunServer setFont: font];
  [edStunServer setTextCentersVertically: YES];
  [edStunServer setTapDelegate: self];
  [[edStunServer textTraits] setEditingDelegate:self];

  btnSave = [[UIPushButton alloc] initWithTitle: @""];
  [btnSave setAutosizesToFit: NO];
  [btnSave setFrame: CGRectMake(50.0f, 370.0f, 220.0f, 30.0f)];
  [btnSave setDrawContentsCentered: YES];
  [btnSave addTarget:self action:@selector(saveEvent:) forEvents: 1];
  [btnSave setImage:nil forState:0];

  [secView addSubview: edUserName];
  [secView addSubview: edPassword];
  [secView addSubview: edServer];
  [secView addSubview: edRegTimeout];
  [secView addSubview: edNAT];
  [secView addSubview: edStunDomain];
  [secView addSubview: edStunServer];
  [secView addSubview: btnSave];
  [scrollView addSubview: secView];
  [self addSubview:scrollView];
  [self loadDefaults];
  [self loadData];
}

- (void)checkEvent:(UIPushButton*)box
{
  if([edNAT title] == @"YES"){
    [edNAT setTitle: @"NO"];
    [edStunDomain setEnabled: NO];
    [edStunServer setEnabled: NO];
  }else{
    [edNAT setTitle: @"YES"];
    [edStunDomain setEnabled: YES];
    [edStunServer setEnabled: YES];
  }
  [btnSave setTitle: @""];
  [btnSave setImage:nil forState:0];
}

- (void)saveEvent:(UIPushButton*)box
{
  [self saveData];
  [btnSave setTitle: @""];
  [btnSave setImage:[UIImage imageNamed:@"skins/SETTINGS-key-saved.png"] forState:0];
}

-(void)keyboardInput:(id)k shouldInsertText:(id)i isMarkedText:(int)b{
  if ([i characterAtIndex:0] == 0xA){
    [keyboard removeFromSuperview];
    [scrollView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 414.0f)];
    [scrollView scrollPointVisibleAtTopLeft: CGPointMake(0, 0) animated:YES];
    [btnSave setTitle: @""];
    [btnSave setImage:nil forState:0];
  }
}
- (void)view:(UIView *)view handleTapWithCount:(int)count 
    event:(struct __GSEvent *)event 
{

  struct CGPoint topLeft;
//  struct CGRect kbPos;
  float y = 0;

  if(view == edUserName){
    y = 0;
  }else if(view == edPassword){
    y = 60;
  }else if(view == edServer){
    y = 110;
  }else if(view == edRegTimeout){
    y = 160;  
  }else if(view == edStunDomain){
    y = 260;
  }else if(view == edStunServer){
    y = 310;
  }
  topLeft = CGPointMake(0, y);

  [scrollView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 200.0f)];
  [scrollView scrollPointVisibleAtTopLeft: topLeft animated:YES];
  // [keyboard setFrame: kbPos];
  [self addSubview: keyboard];
}


- (void)loadData
{
  NSData *xmlData;
  xmlData = [NSData dataWithContentsOfFile: settingsPath];
  NSDictionary *accountData;
  NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
  accountData = [NSPropertyListSerialization propertyListFromData:xmlData
					     mutabilityOption:NSPropertyListImmutable
					     format:&format
					     errorDescription:nil];
  if(accountData){
    NSArray *tmp = [NSArray arrayWithObject: @"username"];
    [edUserName setText: [[accountData objectsForKeys:tmp notFoundMarker:@""] lastObject]];
    tmp = [NSArray arrayWithObject: @"password"];
    [edPassword setText: [[accountData objectsForKeys:tmp notFoundMarker:@""] lastObject]];

    tmp = [NSArray arrayWithObject: @"server"];
    [edServer setText: [[accountData objectsForKeys:tmp notFoundMarker:@""] lastObject]];
    tmp = [NSArray arrayWithObject: @"timeout"];
    [edRegTimeout setText: [[accountData objectsForKeys:tmp notFoundMarker:@"1800"] lastObject]];

    tmp = [NSArray arrayWithObject: @"stundomain"];
    [edStunDomain setText: [[accountData objectsForKeys:tmp notFoundMarker:@""] lastObject]];
    tmp = [NSArray arrayWithObject: @"stunserver"];
    [edStunServer setText: [[accountData objectsForKeys:tmp notFoundMarker:@""] lastObject]];

    tmp = [NSArray arrayWithObject: @"nat"];
    [edNAT setTitle: [[accountData objectsForKeys:tmp notFoundMarker:@"NO"] lastObject]];
    if([edNAT title] == @"YES"){
      [edStunDomain setEnabled: YES];
      [edStunServer setEnabled: YES];
    }else{
      [edStunDomain setEnabled: NO];
      [edStunServer setEnabled: NO];
    }

  }
}

- (void)saveData
{
  NSDictionary *accountData = [NSDictionary dictionaryWithObjectsAndKeys:
					      [edUserName text], @"username",
					    [edPassword text], @"password",

					    [edServer text], @"server",
					    [edRegTimeout text], @"timeout",
                       
					    [edNAT title], @"nat",
					    [edStunDomain text], @"stundomain",
					    [edStunServer text], @"stunserver",
					    nil];
  NSData *xml = [NSPropertyListSerialization dataFromPropertyList: accountData
					     format:NSPropertyListXMLFormat_v1_0
					     errorDescription:nil];
  if(xml)
    [xml writeToFile: settingsPath atomically:YES];
}

- (void)loadDefaults
{
  [edUserName setText: @""];
  [edPassword setText: @""];

  [edServer setText: @""];
  [edRegTimeout setText: @""];

  [edNAT setTitle: @"NO"];
  [edStunDomain setText: @""];
  [edStunServer setText: @""];
}

- (NSString*)getUserName
{
  return [edUserName text];
}

- (NSString*)getPassword
{
  return [edPassword text];
}

- (NSString*)getServer
{
  return [edServer text];
}

- (NSString*)getRegTimeout
{
  return [edRegTimeout text];
}

- (BOOL)getNAT
{
  return ([edNAT title] == @"YES");
}

- (NSString*)getStunDomain
{
  return [edStunDomain text];
}

- (NSString*)getStunServer
{
  return [edStunServer text];
}

@end
