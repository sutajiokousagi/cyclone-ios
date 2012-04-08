//
//  ViewController.m
//  Cyclone
//
//  Created by Torin Nguyen on 7/4/12.
//  Copyright (c) 2012 Kosagi. All rights reserved.
//

#import "TrackingController.h"
#import "Reachability.h"
#import "AFCycloneAPIClient.h"

@interface TrackingController() <CLLocationManagerDelegate>
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) IBOutlet UIButton *btnStartTracking;
@property(nonatomic, strong) IBOutlet UILabel  *lblStatus;
@property(nonatomic, strong) IBOutlet UISwitch *swtHighAccuracy;
@property(nonatomic, assign) BOOL wasHighAccuracy;
@property(nonatomic, assign) BOOL startedTracking;

- (void)switchTrackingMode:(BOOL)highAccuracy;

- (IBAction)onSwitchChange:(id)sender;
- (IBAction)startTracking:(id)sender;
- (void)startLoading;
- (void)onWillResignActiveNotification:(NSNotification*)notification;
- (void)onDidBecomeActiveNotification:(NSNotification*)notification;

- (void)updateLocationToServer:(CLLocation *)newLocation;
@end



@implementation TrackingController

@synthesize locationManager;
@synthesize btnStartTracking;
@synthesize lblStatus;
@synthesize swtHighAccuracy;
@synthesize wasHighAccuracy;
@synthesize startedTracking;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.startedTracking = NO;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //Set reasonble accuracy for our application (high accuracy mode only)
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(onWillResignActiveNotification:) name:WILL_RESIGN_ACTIVE_NOTIFICATION object:nil];
    [defaultCenter addObserver:self selector:@selector(onDidBecomeActiveNotification:) name:DID_BECOME_ACTIVE_NOTIFICATION object:nil];

}


#pragma mark - Tracking

- (void)switchTrackingMode:(BOOL)highAccuracy
{
    if (!self.startedTracking)
        return;
    if (highAccuracy)
    {
        NSLog(@"Switch to high accuracy mode");
        [locationManager stopMonitoringSignificantLocationChanges];
        [locationManager startUpdatingLocation];        
    }
    else 
    {
        NSLog(@"Switch to low accuracy mode");
        [locationManager stopUpdatingLocation];
        [locationManager startMonitoringSignificantLocationChanges];
    }
}


#pragma mark - UI events

- (IBAction)onSwitchChange:(id)sender
{
    if (!self.startedTracking)
        return;
    [self switchTrackingMode:self.swtHighAccuracy.on];
}

- (IBAction)startTracking:(id)sender
{
    self.startedTracking = YES;
    self.btnStartTracking.enabled = NO;
    [self startLoading];
}

- (void)startLoading
{
    BOOL isReachable = [[Reachability reachabilityForInternetConnection] isReachable] || [[Reachability reachabilityWithHostName:@"google.com"] isReachable];
    
    if (isReachable) {
        [self switchTrackingMode:self.swtHighAccuracy.on];
        return;
    }
    
    NSString *noInternetConnectionString = @"No Internet Connection";
    if (![self.lblStatus.text isEqualToString:noInternetConnectionString])
        self.lblStatus.text = noInternetConnectionString;

    //Retry after 20 seconds if no internet
    [self performSelector:@selector(startLoading) withObject:nil afterDelay:20];
}

- (void)onWillResignActiveNotification:(NSNotification*)notification 
{
    self.wasHighAccuracy = self.swtHighAccuracy.on;
    if (!self.startedTracking)
        return;
    
    //Going to background mode, switch to low power tracking
    [self.swtHighAccuracy setOn:NO animated:NO];
    [self switchTrackingMode:self.swtHighAccuracy.on];
}

- (void)onDidBecomeActiveNotification:(NSNotification*)notification
{
    if (!self.startedTracking)
        return;
    
    //Switch back to high accuracy mode if before going background we were using that mode
    if (self.wasHighAccuracy) {
        [self.swtHighAccuracy setOn:YES animated:NO];
        [self switchTrackingMode:YES];
    }
}

#pragma mark - CCLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{    
    CLLocationCoordinate2D currentCoordinates = newLocation.coordinate;
    NSString *locationString = [NSString stringWithFormat:@"Latitude: %.4f\nLongitude: %.4f", currentCoordinates.latitude, currentCoordinates.longitude];
    self.lblStatus.text = locationString;
    NSLog(@"Latitude: %.4f  Longitude: %.4f", currentCoordinates.latitude, currentCoordinates.longitude);
    
    [self updateLocationToServer:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.lblStatus.text = @"Unable to start location manager";
    NSLog(@"Unable to start location manager. Error:%@", [error description]);
}


#pragma mark - Webservice

- (void)updateLocationToServer:(CLLocation *)newLocation
{
    [[AFCycloneAPIClient sharedClient] updateLocation:newLocation
                                           completion:^(BOOL success, NSString *statusMessage, NSNumber *queue_id)
    {
        if (success)
            NSLog(@"Location updated");
    }];
}

@end
