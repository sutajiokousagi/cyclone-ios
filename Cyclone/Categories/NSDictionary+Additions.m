//
//  NSDictionary+Additions.m
//
//  Created by Torin Nguyen on 7/4/12.
//  Copyright (c) 2012 Kosagi. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)

- (NSDictionary*) deepCopy {
  unsigned int count = [self count];
  NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] initWithCapacity:count];
  
  NSEnumerator *e = [self keyEnumerator];
    
  id thisKey;
  while ((thisKey = [e nextObject]) != nil) {
    id obj = [self objectForKey:thisKey];
    if (obj == nil)
      continue;

    id key = nil;
    if ([thisKey respondsToSelector:@selector(deepCopy)])
      key = [thisKey deepCopy];
    else
      key = [thisKey copy];

    if ([obj respondsToSelector:@selector(deepCopy)])
      [newDictionary setObject:[obj deepCopy] forKey:key];
    else
      [newDictionary setObject:[obj copy] forKey:key];
  }
    
  NSDictionary *returnDictionary = [newDictionary copy];
  newDictionary = nil;
  return returnDictionary;
}

@end
