//
//  ViewController.h
//  TraveLog
//
//  Created by Cyron Completo on 4/22/15.
//  Copyright (c) 2015 Cyron Completo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
{
    CLLocationManager *locationManager;
    IBOutlet UILabel *alertLabel;
    NSString *plistPath, *locPath;
    NSMutableDictionary *plistDict, *locDict;
    float latitude, longitude;
}
@property (strong, nonatomic) IBOutlet MKMapView *myMapView;
@property (weak, nonatomic) IBOutlet UILabel *Title;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet UILabel *alertLabel;
//- (IBAction)startTracking:(id)sender;
- (void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult)) completionHandler;

@end

