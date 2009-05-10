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

#import "CallViewController.h"
#import "SiphonApplication.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AddressBook/AddressBook.h>

#include "call.h";
#include "dtmf.h";

#define HOLD_ON 1

#define kTransitionDuration	0.5

@interface CallViewController (private)

- (void)setSpeakerPhoneEnabled:(BOOL)enable;
- (void)setMute:(BOOL)enable;

@end

@implementation CallViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
  int i;
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
  {
		// Initialization code
    for (i = 0; i < PJSUA_MAX_CALLS; ++i)
      _call[i] = nil;
	}
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
*/
 - (void)loadView
{
  UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
  [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
  
#if defined(CYDIA) && (CYDIA == 1)
  [view setBackgroundColor:[[[UIColor alloc] 
                             initWithPatternImage:[UIImage defaultDesktopImage]]
                            autorelease]];
#else
	[view setBackgroundColor:[UIColor blackColor]];
#endif                            

  // create the container view which we will use for transition animation (centered horizontally)
	CGRect frame = CGRectMake(0.0f, 70.0f, 320.0f, 320.0f);
	_containerView = [[UIView alloc] initWithFrame:frame];
	//[view addSubview:_containerView];
  
  /** Phone Pad **/
  //_phonePad = [[PhonePad alloc] initWithFrame: CGRectMake(0.0f, 70.0f, 320.0f, 320.0f)];
  _phonePad = [[PhonePad alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
  [_phonePad setPlaysSounds: TRUE];
  [_phonePad setDelegate: self];
  //[_containerView addSubview:_phonePad];
  
  /** Menu **/
  _menuView = [[MenuCallView alloc] initWithFrame: CGRectMake(18.0f, 52.0f, 285.0f, 216.0f)];
  [_menuView setDelegate:self];
  [_menuView setTitle:NSLocalizedString(@"mute", @"Call View")
                image:[UIImage imageNamed:@"mute.png"] forPosition:0];
  [_menuView setTitle:NSLocalizedString(@"keypad", @"Call View")
                image:[UIImage imageNamed:@"dialer.png"] forPosition:1];
  [_menuView setTitle:NSLocalizedString(@"speaker", @"Call View")
                image:[UIImage imageNamed:@"speaker.png"] forPosition:2];
  //[_menuView setTitle:NSLocalizedString(@"add call", @"Call View")
  //              image:[UIImage imageNamed:@"addcall.png"] forPosition:3];
#if HOLD_ON
  [_menuView setTitle:NSLocalizedString(@"hold", @"Call View")
                image:[UIImage imageNamed:@"hold.png"] forPosition:4];
#endif
  
  /** LCD **/
  _lcd = [[LCDView alloc] initWithDefaultSize];
  [_lcd setLabel:@""]; // name or number of callee
  [_lcd setText:@""];   // timer, call state for example
  [view addSubview: _lcd];
  

  _defaultBottomBar = [[BottomDualButtonBar alloc] initForEndCall];
  [[_defaultBottomBar button] addTarget:self action:@selector(endCallUpInside:)
                forControlEvents:UIControlEventTouchUpInside];
  UIImage *buttonBackground = [UIImage imageNamed:@"bottombarblue.png"];
  UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"bottombarblue_pressed.png"];
  _menuButton = [BottomButtonBar createButtonWithTitle:NSLocalizedString(@"Hide Keypad", @"Call View")
                                                          image:nil 
                                                          frame:CGRectZero 
                                                     background:buttonBackground
                                              backgroundPressed:buttonBackgroundPressed];
  [_menuButton addTarget:self action:@selector(flipKeypad) 
       forControlEvents:UIControlEventTouchUpInside];

  _dualBottomBar = [[BottomDualButtonBar alloc] initForIncomingCall];
  [[_dualBottomBar button] addTarget:self action:@selector(declineCallDown:)
                           forControlEvents:UIControlEventTouchUpInside];
  [[_dualBottomBar button2] addTarget:self action:@selector(answerCallDown:)
                            forControlEvents:UIControlEventTouchUpInside];

  self.view = view;
  [view release];
}

/*
 If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
}
 */


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc
{
	//[_defaultBottomBar release];
  [_menuButton release];
  [_defaultBottomBar release];
	[_dualBottomBar release];
  
  [_phonePad release];
  [_menuView release];
  [_containerView release];
  
  [_lcd release];
  
	[super dealloc];
}

- (void)showKeypad:(BOOL)display animated:(BOOL)animated
{
  if ([_defaultBottomBar superview]) 
    [_defaultBottomBar setButton2:(display ? _menuButton : nil)];
  if (animated)
  {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kTransitionDuration];
  
    [UIView setAnimationTransition:(display ?
                                    UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
                           forView:_containerView cache:YES];
  }
	if (display)
	{
		[_menuView removeFromSuperview];
		[_containerView addSubview:_phonePad];
	}
	else
	{
		[_phonePad removeFromSuperview];
		[_containerView addSubview:_menuView];
	}
	
  if (animated)
    [UIView commitAnimations];
}

- (void)flipKeypad
{
  //[self showKeypad:([_menuView superview] != nil) animated:YES];
  [self showKeypad:NO animated:YES];
}

- (void)endCallUpInside:(id)fp8
{
  //NSLog(@"endCallUpInside %@", fp8);
  sip_hangup(&_call_id);
}

- (void)answerCallDown:(id)fp8
{
  //NSLog(@"answerCallDown %@", fp8);
  sip_answer(&_call_id);
}

- (void)declineCallDown:(id)fp8
{
  //NSLog(@"declineCallDown %@", fp8);
  sip_hangup(&_call_id);
}

/*** ***/
- (void)timeout:(id)unused
{
  pjsua_call_info ci;

  // It's not logic, _call_id should be valid.
  if (_call_id == PJSUA_INVALID_ID)
    return;
  
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
- (ABRecordRef)findRecord:(NSString *)phoneNumber
{
  //ABCGetSharedAddressBook();
  ABAddressBookRef addressBook = ABAddressBookCreate();
  // ABAddressBookFindPersonMatchingPhoneNumber
  ABRecordRef record = ABCFindPersonMatchingPhoneNumber(addressBook,
      phoneNumber, 0, 0);

  //if (!record)
  //{
  //record = ABAddressBookFindPersonMatchingURL(addressBook, phoneNumber);
  //record = ABCFindPersonMatchingURL(addressBook, phoneNumber, 0, 0);
  //}

  //CFRelease(addressBook);
  
  return record;
}

- (UIImage *)findImageWithRecord:(ABRecordRef)record
{
  UIImage *image = nil;

  if (record && ABPersonHasImageData(record))
  {
    CFDataRef data;

    data = ABPersonCopyImageData(record);
    if (data)
      image = [[UIImage alloc] initWithData: (NSData *)data /*cache:YES*/];
  }
  return image;
}

- (UIImage *)findImageWithRecordID:(ABRecordID) uid
{
  if (uid == kABRecordInvalidID)
    return nil;
  ABAddressBookRef addressBook = ABAddressBookCreate();
  ABRecordRef record = ABAddressBookGetPersonWithRecordID(addressBook, uid);
  UIImage *image = [self findImageWithRecord:record];
  CFRelease(addressBook);
  return image;
}

#if 0
- (void)displayUserInfo:(pjsua_call_id)call_id
{
  pjsua_call_info ci;
  pjsip_name_addr *url;
  pjsip_sip_uri *sip_uri;
  pj_str_t tmp, dst;
  pj_pool_t     *pool;

  pool = pjsua_pool_create("call", 128, 128);

  if (pool)
  {
    pjsua_call_get_info(call_id, &ci);
    pj_strdup_with_null(pool, &tmp, &ci.remote_info);

    url = (pjsip_name_addr*)pjsip_parse_uri(pool, tmp.ptr, tmp.slen,
                  PJSIP_PARSE_URI_AS_NAMEADDR);
    if (url != NULL)
    {
      NSString *phoneNumber = NULL;
      sip_uri = (pjsip_sip_uri*) pjsip_uri_get_uri(url->uri);
      pj_strdup_with_null(pool, &dst, &sip_uri->user);

      ABRecordRef record = [self findRecord:[NSString stringWithUTF8String:
                                             pj_strbuf(&dst)]];
      if (record)
        phoneNumber = (NSString *)ABRecordCopyCompositeName(record);
      if (!phoneNumber)
      {
        if (url->display.slen)
        {
          pj_strdup_with_null(pool, &dst, &url->display);
        }
        phoneNumber = [NSString stringWithUTF8String: pj_strbuf(&dst)];
      }
      [_lcd setText: phoneNumber];
      UIImage *image = [self findImage: record];
      [_lcd setSubImage: image];
    }
    else
    {
      [_lcd setText: @""];
      [_lcd setSubImage: nil];
    }

    pj_pool_release(pool);
  }
}
#endif

- (void)phonePad:(id)phonepad keyDown:(char)car
{
  //NSLog(@"keyDown %@ %c", phonepad, car);
  // DTMF
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"dtmfWithInfo"])
    sip_call_play_info_digit(_call_id, car);
  else
    sip_call_play_digit(_call_id, car);
}

/*** ***/
- (RecentCall *)createCall:(NSDictionary *)userInfo
{
  RecentCall *call = nil;
  pjsip_name_addr *url;
  pjsip_sip_uri *sip_uri;
  pj_str_t tmp, dst;
  pj_pool_t     *pool;
  
  int role;
  NSString *remote_info;
  
  pool = pjsua_pool_create("recentCall", 128, 128);
  if (pool)
  {
    call = [[RecentCall alloc] init];
    role = [[ userInfo objectForKey: @"Role"] intValue];
    call.type = (role == PJSIP_ROLE_UAC ? Dialled : Received);
    remote_info = [userInfo objectForKey: @"RemoteInfo"];
    pj_strdup2_with_null(pool, &tmp, [remote_info UTF8String]);
    
    url = (pjsip_name_addr*)pjsip_parse_uri(pool, tmp.ptr, tmp.slen,
                                            PJSIP_PARSE_URI_AS_NAMEADDR);
    if (url != NULL)
    {
      ABRecordRef record;
      sip_uri = (pjsip_sip_uri*) pjsip_uri_get_uri(url->uri);
      pj_strdup_with_null(pool, &dst, &sip_uri->user);
      
      call.number = [NSString stringWithUTF8String: pj_strbuf(&dst)];
      record = [self findRecord:call.number];
      if (record)
      {
        // FIXME: duplicate code in RecentsViewController:unknownPersonViewController
        CFTypeRef multiValue;
        CFIndex index;
        
        call.compositeName = (NSString *)ABRecordCopyCompositeName(record);
        call.uid = ABRecordGetRecordID(record);
        
        multiValue = ABRecordCopyValue(record, kABPersonPhoneProperty);
        index = ABMultiValueGetFirstIndexOfValue (multiValue, call.number);
        call.identifier = ABMultiValueGetIdentifierAtIndex(multiValue, index);
        CFRelease(multiValue);
      }
      else if (url->display.slen)
      {
        pj_strdup_with_null(pool, &dst, &url->display);
        call.compositeName = [NSString stringWithUTF8String: pj_strbuf(&dst)];
      }
    }
    //    else 
    //    {
    //      // Bizarre, Weird
    //    }
    pj_pool_release(pool);
  }

  return call;
}

- (void)processCall:(NSDictionary *)userInfo
{
  int state, call_id;
  int account_id;
  SiphonApplication *app = (SiphonApplication*)[SiphonApplication sharedApplication];
  
  account_id = [[userInfo objectForKey: @"AccountID"] intValue];
  
  _call_id = call_id = [[userInfo objectForKey: @"CallID"] intValue];
  state = [[userInfo objectForKey: @"State"] intValue];
  switch(state)
  {
    case PJSIP_INV_STATE_CALLING: // After INVITE is sent.
      [_defaultBottomBar setButton2:nil];
      [self.view addSubview: _defaultBottomBar];
      [self showKeypad:NO animated:NO];
      [self.view addSubview:_containerView];
      //[self displayUserInfo: call_id];
      
      if (_call[call_id] == nil)
      {
        _call[call_id] = [self createCall: userInfo];
        [_lcd setText: [_call[call_id] displayName]];
        [_lcd setSubImage:[self findImageWithRecordID:_call[call_id].uid]];
      }
      
      [_lcd setLabel: NSLocalizedString(@"calling...", @"Call view")];
      break;
    case PJSIP_INV_STATE_INCOMING: // After INVITE is received.
      [self.view addSubview: _dualBottomBar];
      [self showKeypad:NO animated:NO];
      //[_containerView removeFromSuperview];
      
      if (_call[call_id] == nil)
      {
        _call[call_id] = [self createCall: userInfo];
        [_lcd setText: [_call[call_id] displayName]];
        [_lcd setSubImage:[self findImageWithRecordID:_call[call_id].uid]];
      }
      
      [_lcd setLabel: @""];
      break;
    case PJSIP_INV_STATE_EARLY: // After response with To tag.
      //[self.view addSubview: _phonePad];
      //[self showKeypad:YES animated:NO];
      //[self.view addSubview:_containerView];
    case PJSIP_INV_STATE_CONNECTING: // After 2xx is sent/received.
      break;
    case PJSIP_INV_STATE_CONFIRMED: // After ACK is sent/received.
      [_dualBottomBar removeFromSuperview];
      [self.view addSubview:_defaultBottomBar];
      [self.view addSubview:_containerView];
      _timer = [[NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(timeout:)
                                               userInfo:nil
                                                repeats:YES] retain];
      [_timer fire];
      break;
    case PJSIP_INV_STATE_DISCONNECTED:
      [self setSpeakerPhoneEnabled:NO];
      [self setMute:NO];

      if (_timer)
      {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
      }
      [_lcd setLabel: NSLocalizedString(@"call ended", @"Call view")];
      //[_lcd setText:@""];
      if (_call[call_id])
        [[app recentsViewController] addCall:_call[call_id]];
      _call[call_id] = nil;
      _call_id = PJSUA_INVALID_ID;
      [_dualBottomBar removeFromSuperview];
      [_defaultBottomBar removeFromSuperview];
      [_containerView removeFromSuperview];
      
      // FIXME not here
      [[_menuView buttonAtPosition:0] setSelected:NO];
      [[_menuView buttonAtPosition:2] setSelected:NO];
#if HOLD_ON
      [[_menuView buttonAtPosition:4] setSelected:NO];
#endif
      break;
  }  
}

- (void)setSpeakerPhoneEnabled:(BOOL)enable
{
  UInt32 route;
  route = enable ? kAudioSessionOverrideAudioRoute_Speaker : 
                   kAudioSessionOverrideAudioRoute_None;
  AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, 
                           sizeof(route), &route);
}

- (void)setMute:(BOOL)enable
{
  /* FIXME maybe I must look for conf_port */
  if (enable)
    pjsua_conf_adjust_rx_level(0 /* pjsua_conf_port_id slot*/, 0.0f);
  else
    pjsua_conf_adjust_rx_level(0 /* pjsua_conf_port_id slot*/, 1.0f);
}

- (void)setHoldEnabled: (BOOL)enable
{
  if (enable)
  {
    if (_call_id != PJSUA_INVALID_ID)
      pjsua_call_set_hold(_call_id, NULL);
  }
  else
  {
    if (_call_id != PJSUA_INVALID_ID)
      pjsua_call_reinvite(_call_id, PJ_TRUE, NULL);
  }
}

- (void)menuButtonClicked:(NSInteger)num
{
  UIButton *button;
  
  button = [_menuView buttonAtPosition:num];
  switch (num)
  {
    case 0: // Mute 
      //button = [_menuView buttonAtPosition:num];
      [self setMute:!button.selected];
      [button setSelected:!button.selected];
      break;
    case 1: // Keypad
      [self showKeypad:YES animated:YES];
      break;
    case 2: // Speaker
      //button = [_menuView buttonAtPosition:num];
      [self setSpeakerPhoneEnabled:!button.selected];
      [button setSelected:!button.selected];
      break;
    case 3: // Add call
      break;
    case 4: // Hold
#if HOLD_ON
      //button = [_menuView buttonAtPosition:num];
      [self setHoldEnabled:!button.selected];
      [button setSelected:!button.selected];
#endif
      break;
    case 5: // Contacts
      break;
    default:
      break;
  }
}

#if 0
void audioSessionPropertyListener(void *inClientData, AudioSessionPropertyID inID,
                                  UInt32  inDataSize, const void  *inData)
{
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		/* A CFDictionaryRef object containing the reason the audio route
		 * changed and the name of the old route. This object is available
		 * to your application only by way of a property listener callback
		 * function. See AudioSessionAddPropertyListener. The CFDictionary
		 * object contains two keys and values.
		 * The kAudioSession_AudioRouteChangeKey_Reason key has a CFNumberRef
		 * value that identifies the reason for the route change. See “Audio
		 * Session Route Change Reasons.”
		 * The kAudioSession_AudioRouteChangeKey_OldRoute key has a CFStringRef
		 * value that names the old audio route.
		 */
		CFDictionaryRef dictionary = (CFDictionaryRef)inData;
		CFNumberRef reason = CFDictionaryGetValue (dictionary,kAudioSession_AudioRouteChangeKey_Reason);
    
		CFStringRef oldRoute = CFDictionaryGetValue (dictionary,kAudioSession_AudioRouteChangeKey_OldRoute);
	}
}

AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange,
                                audioSessionPropertyListener, NULL);
#endif

@end
