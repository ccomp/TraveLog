//
//  ViewController.m
//  TraveLog
//
//  Created by Cyron Completo on 4/22/15.
//  Copyright (c) 2015 Cyron Completo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize locationManager;
@synthesize alertLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    //plistPath = [[NSBundle mainBundle] pathForResource:@"buttonPressed" ofType:@"plist"];
    //plistDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    locPath = [[NSBundle mainBundle] pathForResource:@"Locations" ofType:@"plist"];
    locDict = [NSMutableDictionary dictionaryWithContentsOfFile:locPath];
    NSLog(@"locationServicesEnabled: %@", [CLLocationManager locationServicesEnabled] ? @"YES":@"NO");
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [self.locationManager requestAlwaysAuthorization];
        NSLog(@"Requested authorization");
    }
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager startUpdatingLocation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLoc = [locations lastObject];
    CLLocationCoordinate2D coords = currentLoc.coordinate;
    NSLog(@"Called update");
    latitude = coords.latitude;
    longitude = coords.longitude;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Unable to start location manager. Error:%@", [error description]);
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"Paused updates for some reason");
}

-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"If this is called something fixed itself");
}

- (void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    latitude = locationManager.location.coordinate.latitude;
    longitude = locationManager.location.coordinate.longitude;
    NSLog(@"Latitude:%f", latitude);
    NSLog(@"Longitude:%f", longitude);
    NSLog(@"Time:%@", timestamp);
    completionHandler(UIBackgroundFetchResultNewData);
    //display mean time in plist as to not populate list with too many entries
    //simulate background fetch
    
    //start doing stuff with completionhandler
}

/*
- (IBAction)startTracking:(id)sender {
    NSMutableDictionary *subDict = [[plistDict objectForKey:@"ENABLED"] mutableCopy];
    if ([[subDict objectForKey:@"ENABLED"] boolValue]) {
        [subDict setObject:[NSNumber numberWithBool:0] forKey:@"ENABLED"];
    } else {
        [subDict setObject:[NSNumber numberWithBool:1] forKey:@"ENABLED"];
        [locationManager startUpdatingLocation];
    }
    NSLog(@"Button Pressed");
}
*/

@end
