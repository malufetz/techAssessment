//
//  ViewController.m
//  techAssessment
//
//  Created by Lorenz Lomerio on 11/16/13.
//  Copyright (c) 2013 Lorenz Lomerio. All rights reserved.
//

#import "ViewController.h"

#import "TouchXML.h"

#import <QuartzCore/QuartzCore.h>


//#define METERS_PER_MILE 1609.344

#define METERS_PER_MILE 2000.0

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    dict_data = [[NSMutableDictionary alloc] init];
    
    NSURL *URL = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/101222705/business.xml"];
    NSData *XMLdata   = [NSData dataWithContentsOfURL:URL];
    CXMLDocument *XMLdoc = [[CXMLDocument alloc] initWithData:XMLdata options:0 error:nil];
    
    NSArray *items = NULL;
    //  searching for piglet nodes
    items = [XMLdoc nodesForXPath:@"//business" error:nil];
    
    for (CXMLNode *itemNode in items)
    {
        for (CXMLNode *childNode in [itemNode children])
        {
            NSString *nodeName = [childNode name];
            if ([nodeName isEqualToString:@"location"]) {
                for (CXMLNode *locationNode in [childNode children]) {
                    
                    NSString *locationNodeName = [locationNode name];
                    
                    NSString *locationNodeValue = [locationNode stringValue];
                    if ([locationNodeName isEqualToString:@"address"]) {
                        [dict_data setValue:locationNodeValue forKey:@"address"];
                    }else if ([locationNodeName isEqualToString:@"city"]) {
                        [dict_data setValue:locationNodeValue forKey:@"city"];
                    }else if ([locationNodeName isEqualToString:@"state"]) {
                        [dict_data setValue:locationNodeValue forKey:@"state"];
                    }else if ([locationNodeName isEqualToString:@"zip"]) {
                        [dict_data setValue:locationNodeValue forKey:@"zip"];
                    }else if ([locationNodeName isEqualToString:@"latitude"]) {
                        [dict_data setValue:locationNodeValue forKey:@"latitude"];
                    }else if ([locationNodeName isEqualToString:@"longitude"]) {
                        [dict_data setValue:locationNodeValue forKey:@"longitude"];
                    }
                }
            }else{
                NSString *nodeValue = [childNode stringValue];
                if ([nodeName isEqualToString:@"name"]) {
                    [dict_data setValue:nodeValue forKey:@"name"];
                }else if ([nodeName isEqualToString:@"category"]) {
                    [dict_data setValue:nodeValue forKey:@"category"];
                }else if ([nodeName isEqualToString:@"rating"]) {
                    [dict_data setValue:nodeValue forKey:@"rating"];
                }else if ([nodeName isEqualToString:@"phone"]) {
                    [dict_data setValue:nodeValue forKey:@"phone"];
                }
            }
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [[dict_data objectForKey:@"latitude"] floatValue];
    zoomLocation.longitude= [[dict_data objectForKey:@"longitude"] floatValue];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.2*METERS_PER_MILE, 0.2*METERS_PER_MILE);
    [mapView setRegion:viewRegion animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    mapView.delegate = self;
    
    // Create your coordinate
    CLLocationCoordinate2D myCoordinate = {[[dict_data objectForKey:@"latitude"] floatValue], [[dict_data objectForKey:@"longitude"] floatValue]};
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = myCoordinate;

    [mapView addAnnotation:point];
    [mapView selectAnnotation:point animated:YES];
    
    
}

- (void) showPinOnMap
{
    mapView.delegate = self;
    
    CLLocationCoordinate2D myCoordinate = {[[dict_data objectForKey:@"longitude"] floatValue], [[dict_data objectForKey:@"latitude"] floatValue]};
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = myCoordinate;
    [mapView addAnnotation:point];
    [mapView selectAnnotation:point animated:YES];
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{

    CGSize  calloutSize = CGSizeMake(300.0, 200.0);
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake((view.frame.origin.x-140), view.frame.origin.y-calloutSize.height, calloutSize.width, calloutSize.height)];
    blackView.layer.cornerRadius = 10.0f;
    blackView.backgroundColor = [UIColor blackColor];
    blackView.alpha = 0.5;
    [view.superview addSubview:blackView];
    
    UIView *calloutView = [[UIView alloc] initWithFrame:CGRectMake((view.frame.origin.x-140), view.frame.origin.y-calloutSize.height, calloutSize.width, calloutSize.height)];
    calloutView.backgroundColor = [UIColor clearColor];

    //
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, calloutSize.width-20, 30)];
    lblTitle.font = [UIFont boldSystemFontOfSize:20];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = [dict_data objectForKey:@"name"];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.backgroundColor = [UIColor clearColor];
    [calloutView addSubview:lblTitle];
    
    for (int star = 1; star < 6; star++) {
        UIImageView *starImage = [[UIImageView alloc] init];
        NSString *strImage = @"";
        if ([[dict_data objectForKey:@"rating"] intValue] < star) {
            strImage = @"star_unfill.png";
        }else{
            strImage = @"star_fill.png";
        }
        starImage.frame = CGRectMake(80 +(19 * star), 50, 20, 19);
        starImage.image = [UIImage imageNamed:strImage];
        [calloutView addSubview:starImage];
    }
    
    UILabel *lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, 85, calloutSize.width-20, 20)];
    lblAddress.font = [UIFont systemFontOfSize:14];
    lblAddress.text = [NSString stringWithFormat:@"Address : %@",[dict_data objectForKey:@"address"]];
    lblAddress.textColor = [UIColor whiteColor];
    lblAddress.backgroundColor = [UIColor clearColor];
    [calloutView addSubview:lblAddress];
    
    UILabel *lblcity = [[UILabel alloc] initWithFrame:CGRectMake(10, 105, calloutSize.width-20, 20)];
    lblcity.font = [UIFont systemFontOfSize:14];
    lblcity.text = [NSString stringWithFormat:@"City : %@",[dict_data objectForKey:@"city"]];
    lblcity.textColor = [UIColor whiteColor];
    lblcity.backgroundColor = [UIColor clearColor];
    [calloutView addSubview:lblcity];
    
    UILabel *lblState = [[UILabel alloc] initWithFrame:CGRectMake(10, 125, calloutSize.width-20, 20)];
    lblState.font = [UIFont systemFontOfSize:14];
    lblState.text = [NSString stringWithFormat:@"State : %@",[dict_data objectForKey:@"state"]];
    lblState.textColor = [UIColor whiteColor];
    lblState.backgroundColor = [UIColor clearColor];
    [calloutView addSubview:lblState];
    
    UILabel *lblZip = [[UILabel alloc] initWithFrame:CGRectMake(10, 145, calloutSize.width-20, 20)];
    lblZip.font = [UIFont systemFontOfSize:14];
    lblZip.text = [NSString stringWithFormat:@"Zip Code : %@",[dict_data objectForKey:@"zip"]];
    lblZip.textColor = [UIColor whiteColor];
    lblZip.backgroundColor = [UIColor clearColor];
    [calloutView addSubview:lblZip];
    
    UILabel *lblPhone = [[UILabel alloc] initWithFrame:CGRectMake(10, 165, calloutSize.width-20, 20)];
    lblPhone.font = [UIFont systemFontOfSize:14];
    lblPhone.text = [NSString stringWithFormat:@"Phone # : %@",[dict_data objectForKey:@"phone"]];
    lblPhone.textColor = [UIColor whiteColor];
    lblPhone.backgroundColor = [UIColor clearColor];
    [calloutView addSubview:lblPhone];
    
    //
    
    [view.superview addSubview:calloutView];
}

@end
