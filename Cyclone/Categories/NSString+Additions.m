//
//  NSString+Additions.m
//
//  Created by Torin Nguyen on 7/4/12.
//  Copyright (c) 2012 Kosagi. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (BOOL)contains:(NSString*)needle {
  NSRange range = [self rangeOfString:needle options: NSCaseInsensitiveSearch];
  return (range.length == needle.length && range.location != NSNotFound);
}

- (BOOL)startsWith:(NSString*)needle {
  NSRange range = [self rangeOfString:needle options: NSCaseInsensitiveSearch];
  return (range.length == needle.length && range.location == 0);
}

- (BOOL)endsWith:(NSString*)needle {
  NSRange range = [self rangeOfString:needle options: NSCaseInsensitiveSearch];
  return (range.length == needle.length && range.location == (self.length-range.length-1));
}

@end
