//
//  UIAlertView+Additions.m
//
//  Created by Jesper Särnesjö on 2010-05-31.
//  Copyright 2010 Cartomapic. All rights reserved.
//

#import "UIAlertView+Additions.h"
#import <stdarg.h>

@implementation UIAlertView (Additions)

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                             otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
  [alertView show];
}

@end
