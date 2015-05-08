//
//  AnnotationClass.h
//  TraveLog
//
//  Created by Cyron Completo on 5/7/15.
//  Copyright (c) 2015 Cyron Completo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface AnnotationClass : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *pinTitle, *subTitle;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *pinTitle;
@property (nonatomic, copy) NSString *subTitle;

@end
