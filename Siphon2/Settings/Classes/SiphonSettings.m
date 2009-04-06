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
 *
 * Inspired by MobileScrobbler
 */

#import "SiphonSettings.h"

@implementation CodecSettings
- (NSArray *)specifiers 
{
  NSArray *s = [self loadSpecifiersFromPlistName:@"Codec" target: self];
  return s;
}
@end

@implementation AdvancedSettings
- (NSArray *)specifiers 
{
  NSArray *s = [self loadSpecifiersFromPlistName:@"Advanced" target: self];
  return s;
}
@end

@implementation PhoneSettings
- (NSArray *)specifiers 
{
  NSArray *s = [self loadSpecifiersFromPlistName:@"Phone" target: self];
  return s;
}
@end

@implementation NetworkSettings
- (NSArray *)specifiers 
{
  NSArray *s = [self loadSpecifiersFromPlistName:@"Network" target: self];
  return s;
}
@end

@implementation SiphonSettings
- (NSArray *)specifiers 
{
  NSArray *s = [self loadSpecifiersFromPlistName:@"Siphon" target: self];
  return s;
}

-(void)donate:(id)param 
{
	/*Add code to be executed here.  Anything goes, so don’t feel limited by simply being in Settings */
  NSURL *url = [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=samuelv0304%40gmail%2ecom&item_name=Siphon&no_shipping=0&no_note=1&tax=0&currency_code=EUR&lc=EN&bn=PP%2dDonationsBF&charset=UTF%2d8"];
  [[UIApplication sharedApplication] openURL:url];
}
@end


