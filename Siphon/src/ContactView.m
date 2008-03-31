/**
 *  Siphon SIP-VoIP for iPhone and iPod Touch
 *  Copyright (C) 2008 Mathieu Feulvarc'h <metabaron@metabaron.net>
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

#import "ContactView.h"

@implementation ContactView

- (id) initWithFrame:(struct CGRect)rect
{
  self = [super initWithFrame:rect];
  if(self != nil) 
  {
    _contactName = nil;
    _contactPropertyValue = nil;
    
    _peoplepicker =[[ABPeoplePicker alloc] initWithFrame: rect];
    [_peoplepicker setDelegate: self];

  
    CFMutableArrayRef _props = CFArrayCreateMutable( NULL, 1, NULL );
    CFArrayAppendValue(_props, kABCPhoneProperty);
    //CFArrayAppendValue(_props, kABCEmailProperty);
    
    [_peoplepicker setAllowsCancel: NO];
    [_peoplepicker setAllowsActions: NO];
    [_peoplepicker setAllowsOtherValue: YES];
    //Do you allow to edit contact (not wroking right now)
    [_peoplepicker setAllowsCardEditing: NO];
//    [_peoplepicker setAllowsCardEditing: YES];
    [_peoplepicker setDisplayedProperties:_props];
//    CFRelease(_props);
    
    [self addSubview:_peoplepicker];
  }

  return self;
}

-  (void) dealloc
{
//NEED FIX ArrayRef release
  //[_props release];
  [_peoplepicker release];
  [super dealloc];
}

-(void)copyPropertyValue:(struct CPRecord*)cpRecord 
      multiValue:(int)multiValue 
      valueIdx:(int) valueIdx 
      withLabel:(BOOL)withLabel
{
  if(_contactPropertyValue)
  {
    [_contactPropertyValue release];
//    contactPropertyValue = nil;
  }
  
  _contactPropertyValue = ABCMultiValueCopyValueAtIndex(multiValue,valueIdx);
  if(_contactName)
  {
    [_contactName release];
//    contactName = nil;
  }
  
  NSString* compositeName = (NSString*)ABCRecordCopyCompositeName(cpRecord);
  if(withLabel)
  {
    // Append phone label if contact has 2+ phone numbers
    NSString *label = ABCMultiValueGetLabelAtIndex(multiValue,valueIdx);
    NSString *localizedLabel = ABCCopyLocalizedPropertyOrLabel(label);    
    _contactName = [[NSString alloc] initWithFormat:@"%@(%@)",compositeName,localizedLabel];
    [compositeName release];
    [localizedLabel release];
  }
  else
  {
    _contactName = compositeName;
  }
}

/***************************************************************
 * 
 * cpRecord - the high-level ContactPerson record object
 * propertyId - value of "property" field in table ABMultiValue
 * identifier - value of "identifier" field in table ABMultiValue
 *  
 ***************************************************************/
- (void)peoplePicker:(id)fp8 selectedPerson:(struct CPRecord *)cpRecord 
      property:(int)propertyId 
      identifier:(int)propertyIdentifier 
{
  int multiValue,valueIdx;
  // Get the propert values
  multiValue=ABCRecordCopyValue(cpRecord,propertyId);

  // Get the property value id in the values
  valueIdx=ABCMultiValueIndexForIdentifier(multiValue,propertyIdentifier);
  
  [self copyPropertyValue:cpRecord multiValue:multiValue valueIdx:valueIdx withLabel:YES];
}

- (void)peoplePickerDidEndPicking:(id)iself 
{
  //[_peoplepicker saveState];
  [_peoplepicker resume];
  if(_delegate == nil) {
    NSLog(@"ERROR: delegate is nil!");
    //TODO throw exception!!
    return;
  }
  if ( [_delegate respondsToSelector:@selector(contactSelected:)]) 
  {
    [_delegate contactSelected:_contactName];
  }
  else 
  {
    NSLog(@"WARN delegate would not respond to message @selector(contactSelected:phoneNumber:)");
  }
  //TODO send out notification ?
}

- (void)setDelegate:(id)delegate 
{
  _delegate = delegate;
}

- (NSString *)getSelectedPropertyName
{
  return _contactPropertyName;
}

- (NSString *)getSelectedPropertyValue
{
  return _contactPropertyValue;
}

-(NSString *)getSelectedContactName
{
  return _contactName;
}

@end