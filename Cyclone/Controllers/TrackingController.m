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
@property(nonatomic, strong) IBOutlet UIButton *startTrackingButton;
@property(nonatomic, strong) IBOutlet UILabel  *alertLabel;

- (IBAction)startTracking:(id)sender;
- (void)startLoading;

- (void)updateLocationToServer:(CLLocation *)newLocation;
@end



@implementation TrackingController

@synthesize locationManager;
@synthesize startTrackingButton;
@synthesize alertLabel;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //Only applies when in foreground otherwise it is very significant changes
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - UI events

- (IBAction)startTracking:(id)sender
{
    [self startLoading];
}

- (void)startLoading {
    
    BOOL isReachable = [[Reachability reachabilityForInternetConnection] isReachable] || [[Reachability reachabilityWithHostName:@"google.com"] isReachable];
    
    if (isReachable) {
        //[locationManager startUpdatingLocation];
        [locationManager startMonitoringSignificantLocationChanges];
        return;
    }
    
    NSString *noInternetConnectionString = @"No Internet Connection";
    if (![self.alertLabel.text isEqualToString:noInternetConnectionString])
        self.alertLabel.text = noInternetConnectionString;
    
    [self performSelector:@selector(startLoading) withObject:nil afterDelay:10];
}


#pragma mark - CCLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{    
    CLLocationCoordinate2D currentCoordinates = newLocation.coordinate;
    NSString *locationString = [NSString stringWithFormat:@"Latitude: %.4f\nLongitude: %.4f", currentCoordinates.latitude, currentCoordinates.longitude];
    self.alertLabel.text = locationString;
    NSLog(@"Latitude: %.4f  Longitude: %.4f", currentCoordinates.latitude, currentCoordinates.longitude);
    
    [self updateLocationToServer:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.alertLabel.text = @"Unable to start location manager";
    NSLog(@"Unable to start location manager. Error:%@", [error description]);
}


#pragma mark - Webservice

- (void)updateLocationToServer:(CLLocation *)newLocation
{
    [[AFCycloneAPIClient sharedClient] updateLocation:newLocation
                                           completion:^(BOOL success, NSString *statusMessage, NSNumber *queue_id)
    {
        if (success)
            NSLog(@"New event/queue Id: %d", queue_id.intValue);
    }];
}

@end
