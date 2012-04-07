//
//  AppDelegate.h
//  Cyclone
//
//  Created by Torin Nguyen on 7/4/12.
//  Copyright (c) 2012 Kosagi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginController *viewController;
@property (strong, nonatomic) UINavigationController *navController;

@end
