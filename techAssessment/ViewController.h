//
//  ViewController.h
//  techAssessment
//
//  Created by Lorenz Lomerio on 11/16/13.
//  Copyright (c) 2013 Lorenz Lomerio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    NSMutableDictionary *dict_data;
    
    IBOutlet MKMapView *mapView;
    CLLocationManager *locationManager;
    
    
    id annotationPopoverController;

}

@end
