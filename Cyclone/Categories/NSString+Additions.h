//
//  NSString+Additions.h
//
//  Created by Torin Nguyen on 7/4/12.
//  Copyright (c) 2012 Kosagi. All rights reserved.
//

@interface NSString (Additions)
- (BOOL)contains:(NSString*)needle;
- (BOOL)startsWith:(NSString*)needle;
- (BOOL)endsWith:(NSString*)needle;
@end
