//
//  LoginController.m
//  Cyclone
//
//  Created by Torin Nguyen on 7/4/12.
//  Copyright (c) 2012 Kosagi. All rights reserved.
//

#import "LoginController.h"
#import "TrackingController.h"

@interface LoginController()

@property (nonatomic, strong) IBOutlet UITextField *txtUsername;
@property (nonatomic, strong) IBOutlet UITextField *txtPassword;
@property (nonatomic, strong) IBOutlet UIButton *btnLogin;

- (IBAction)onBtnLogin:(id)sender;

@end

@implementation LoginController

@synthesize txtUsername, txtPassword, btnLogin;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Download some constants from server
    [[AFCycloneAPIClient sharedClient] networkInit:^(BOOL success) {
        
    }];
}


#pragma mark - UI events

- (IBAction)onBtnLogin:(id)sender
{
    TrackingController *vc = [[TrackingController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
