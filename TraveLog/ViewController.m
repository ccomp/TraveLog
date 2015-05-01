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
    plistPath = [[NSBundle mainBundle] pathForResource:@"buttonPressed" ofType:@"plist"];
    plistDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    locPath = [[NSBundle mainBundle] pathForResource:@"Locations" ofType:@"plist"];
    locDict = [NSMutableDictionary dictionaryWithContentsOfFile:locPath];
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    latitude = locationManager.location.coordinate.latitude;
    longitude = locationManager.location.coordinate.longitude;
    NSLog(@"Latitude:%f", latitude);
    NSLog(@"Longitude:%f", longitude);
    completionHandler(UIBackgroundFetchResultNewData);
    //display mean time in plist as to not populate list with too many entries
    //simulate background fetch
    
    //start doing stuff with completionhandler
}

- (IBAction)startTracking:(id)sender {
    NSMutableDictionary *subDict = [[plistDict objectForKey:@"ENABLED"] mutableCopy];
    if ([[subDict objectForKey:@"ENABLED"] boolValue]) {
        [subDict setObject:[NSNumber numberWithBool:0] forKey:@"ENABLED"];
    } else {
        [subDict setObject:[NSNumber numberWithBool:1] forKey:@"ENABLED"];
        [locationManager startUpdatingLocation];
    }
}
@end
