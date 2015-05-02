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
    self.myMapView.delegate = self;
    [self.myMapView setShowsUserLocation:YES];
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

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    int x = 2500, y = 2500;
    CLLocationCoordinate2D myLocation = [userLocation coordinate];
    if (locDict.count != 0)
    {
        
    }
    MKCoordinateRegion zoomRegion = MKCoordinateRegionMakeWithDistance(myLocation, x, y);
    [self.myMapView setRegion:zoomRegion animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    currentLoc = [locations lastObject];
    CLLocationCoordinate2D coords = currentLoc.coordinate;
    latitude = coords.latitude;
    longitude = coords.longitude;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Something went horribly wrong. Error:%@", [error description]);
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
    int i = 0;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMMM dd, yyyy (EEEE) HH:mm:ss z Z"];
    NSDate *now = [NSDate date];
    NSString *timestamp = [format stringFromDate:now];
    [locDict setObject:currentLoc forKey:timestamp];
    [locDict writeToFile:locPath atomically:YES];
    for (id key in locDict)
    {
        NSLog(@"Time%i:%@", i, key);
        NSLog(@"Latitude%i:%f", i, ((CLLocation *)[locDict objectForKey:key]).coordinate.latitude);
        NSLog(@"Longitude%i:%f", i, ((CLLocation *)[locDict objectForKey:key]).coordinate.longitude);
        i++;
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}


@end
