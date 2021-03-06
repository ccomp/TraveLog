//
//  ViewController.m
//  TraveLog
//
//  Created by Cyron Completo on 4/22/15.
//  Copyright (c) 2015 Cyron Completo. All rights reserved.
//

#import "ViewController.h"
#import "AnnotationClass.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize locationManager;
@synthesize alertLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myMapView.delegate = self;
    [self.myMapView setShowsUserLocation:YES];
    [self.myMapView setZoomEnabled:YES];
    [self.myMapView setScrollEnabled:YES];
    
    locPath = [[NSBundle mainBundle] pathForResource:@"Locations" ofType:@"plist"];
    if (![fileManager fileExistsAtPath:locPath]) [fileManager createFileAtPath:locPath contents:nil attributes:nil];
    locDict = [NSMutableDictionary dictionaryWithContentsOfFile:locPath];
    
    if (locDict.count != 0)
        for (NSString *key in locDict)
            [locDict setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[locDict objectForKey:key]] forKey:key];
    
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

- (MKCoordinateRegion)createRegion
{
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;

    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for (id key in locDict)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, ((CLLocation *)[locDict objectForKey:key]).coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, ((CLLocation *)[locDict objectForKey:key]).coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, ((CLLocation *)[locDict objectForKey:key]).coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, ((CLLocation *)[locDict objectForKey:key]).coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    
    // Add a little extra space on the sides
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    return region;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2500, 2500);
    if (locDict.count == 0) [self.myMapView setRegion:region animated:YES];
    else [self.myMapView setRegion:[self createRegion] animated:YES];
}

- (void)didReceiveMemoryWarning
{
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

- (void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    BOOL sameLoc = false;
    int i = 0;
    NSDate *now = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"HH:mm"];
    now = [NSDate date];
    NSString *timestamp = [format stringFromDate:now];
    
    for (CLLocation * key in locDict)
    {
        if (currentLoc == [locDict objectForKey:key])
        {
            sameLoc = true;
            break;
        }
    }
    if (!sameLoc)
    {
        [locDict setObject:currentLoc forKey:timestamp];
        
        fileManager = [NSFileManager defaultManager];
        NSMutableDictionary *rootDict = [[NSMutableDictionary alloc]initWithContentsOfFile:locPath];
        NSData *objData = [NSKeyedArchiver archivedDataWithRootObject:currentLoc];
        [rootDict setObject:objData forKey:timestamp];
        [rootDict writeToURL:[NSURL fileURLWithPath:locPath] atomically:YES];
        
        for (NSString *key in [rootDict allKeys])
        {
            [rootDict setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[rootDict objectForKey:key]] forKey:key];
            NSLog(@"Time%i:%@", i, key);
            NSLog(@"Latitude%i:%f", i, ((CLLocation *)[rootDict objectForKey:key]).coordinate.latitude);
            NSLog(@"Longitude%i:%f", i, ((CLLocation *)[rootDict objectForKey:key]).coordinate.longitude);
            i++;
        }
        
        NSString *subtitle = [NSString stringWithFormat:@"%f, %f", latitude, longitude];
        AnnotationClass *newLoc = [[AnnotationClass alloc] init];
        [newLoc setPinTitle:timestamp];
        [newLoc setSubTitle:subtitle];
        newLoc.coordinate = currentLoc.coordinate;
        [self.myMapView addAnnotation:newLoc];
        completionHandler(UIBackgroundFetchResultNewData);
    } else
    {
        NSLog(@"User has not changed positions");
        for (id key in locDict)
        {
            NSLog(@"Time%i:%@", i, key);
            NSLog(@"Latitude%i:%f", i, ((CLLocation *)[locDict objectForKey:key]).coordinate.latitude);
            NSLog(@"Longitude%i:%f", i, ((CLLocation *)[locDict objectForKey:key]).coordinate.longitude);
            i++;
        }
        completionHandler(UIBackgroundFetchResultNoData);
    }

}


@end
