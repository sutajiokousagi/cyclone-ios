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
@property(nonatomic, strong) IBOutlet UIButton *btnTracking;
@property(nonatomic, strong) IBOutlet UILabel  *lblStatus;
@property(nonatomic, strong) IBOutlet UISwitch *swtHighAccuracy;
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *indicator;
@property(nonatomic, assign) BOOL wasHighAccuracy;
@property(nonatomic, assign) BOOL startedTracking;

- (void)switchTrackingMode:(BOOL)highAccuracy;
- (void)startTracking;
- (void)stopTracking;

- (void)updateUI;

- (IBAction)onSwitchChange:(id)sender;
- (IBAction)onBtnTracking:(id)sender;
- (void)onWillResignActiveNotification:(NSNotification*)notification;
- (void)onDidBecomeActiveNotification:(NSNotification*)notification;

- (void)updateLocationToServer:(CLLocation *)newLocation;
@end



@implementation TrackingController

@synthesize locationManager;
@synthesize btnTracking;
@synthesize lblStatus;
@synthesize swtHighAccuracy;
@synthesize indicator;

@synthesize wasHighAccuracy;
@synthesize startedTracking;



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.startedTracking = NO;
    [self updateUI];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
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
        
        //Set reasonble accuracy for our application (high accuracy mode only)
        [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [locationManager startUpdatingLocation];        
    }
    else 
    {
        NSLog(@"Switch to low accuracy mode");
        [locationManager stopUpdatingLocation];
        [locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void)startTracking
{
    if (self.startedTracking)
        return;
    
    BOOL isReachable = [[Reachability reachabilityForInternetConnection] isReachable] || [[Reachability reachabilityWithHostName:@"google.com"] isReachable];
    
    if (isReachable) {
        self.startedTracking = YES;
        [self updateUI];
        [self switchTrackingMode:self.swtHighAccuracy.on];
        return;
    }
    
    self.lblStatus.text = @"No Internet Connection";   
    self.startedTracking = NO;
    [self updateUI];
    
    //Retry after 20 seconds if no internet
    //[self performSelector:@selector(startTracking) withObject:nil afterDelay:20];
}

- (void)stopTracking
{
    if (!self.startedTracking)
        return;
    
    if (self.swtHighAccuracy.on)    [locationManager stopUpdatingHeading];
    else                            [locationManager stopMonitoringSignificantLocationChanges];
    
    self.startedTracking = NO;
    [self updateUI];
}


#pragma mark - UI helpers

- (void)updateUI
{
    if (self.startedTracking)
    {
        [self.btnTracking setImage:[UIImage imageNamed:@"stop_tracking_btn"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnTracking setImage:[UIImage imageNamed:@"tracking_btn"] forState:UIControlStateNormal];
    }
}

#pragma mark - UI events

- (IBAction)onSwitchChange:(id)sender
{
    if (!self.startedTracking)
        return;
    [self switchTrackingMode:self.swtHighAccuracy.on];
}

- (IBAction)onBtnTracking:(id)sender
{
    if (!self.startedTracking)      [self startTracking];
    else                            [self stopTracking];
}

- (void)onWillResignActiveNotification:(NSNotification*)notification 
{
    self.wasHighAccuracy = self.swtHighAccuracy.on;
    if (!self.startedTracking)
        return;
    
    //Going to background mode, switch to low power tracking
    if (self.wasHighAccuracy) {
        [self.swtHighAccuracy setOn:NO animated:NO];
        [self switchTrackingMode:self.swtHighAccuracy.on];
    }
}

- (void)onDidBecomeActiveNotification:(NSNotification*)notification
{
    [self updateUI];
    
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
    if (!self.startedTracking)
        return;
    
    CLLocationCoordinate2D currentCoordinates = newLocation.coordinate;
    NSString *locationString = [NSString stringWithFormat:@"Latitude: %.4f\nLongitude: %.4f", currentCoordinates.latitude, currentCoordinates.longitude];
    self.lblStatus.text = locationString;
    NSLog(@"Latitude: %.4f  Longitude: %.4f", currentCoordinates.latitude, currentCoordinates.longitude);
    
    [self updateLocationToServer:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (!self.startedTracking)
        return;

    self.lblStatus.text = @"Unable to obtain current location";
    NSLog(@"Unable to start location manager. Error:%@", [error description]);
}


#pragma mark - Webservice

- (void)updateLocationToServer:(CLLocation *)newLocation
{
    if (!self.startedTracking)
        return;
    [self.indicator startAnimating];
    
    [[AFCycloneAPIClient sharedClient] updateLocation:newLocation
                                           completion:^(BOOL success, NSString *statusMessage, NSNumber *queue_id)
    {
        if (success)
            NSLog(@"Location updated");
        
        [self.indicator stopAnimating];
    }];
}

@end
