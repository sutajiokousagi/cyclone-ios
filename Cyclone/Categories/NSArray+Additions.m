//
//  NSArray+NSArray_Additions.m
//
//  Created by Torin Nguyen on 7/4/12.
//  Copyright (c) 2012 Kosagi. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)

- (NSArray*) deepCopy {
  unsigned int count = [self count];
  NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:count];
  
  for (unsigned int i = 0; i < count; ++i) {
    id obj = [self objectAtIndex:i];
    if ([obj respondsToSelector:@selector(deepCopy)])
      [newArray addObject:[obj deepCopy]];
    else
      [newArray addObject:[obj copy]];
  }
  
  NSArray *returnArray = [newArray copy];
  newArray = nil;
  return returnArray;
}

@end
