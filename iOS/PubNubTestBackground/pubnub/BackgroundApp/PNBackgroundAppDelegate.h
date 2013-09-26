//
//  PNBackgroundAppDelegate.h
//  pubnub
//
//  Created by Valentin Tuller on 9/24/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface PNBackgroundAppDelegate : UIResponder <UIApplicationDelegate, PNDelegate, CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
}



#pragma mark Properties

@property (nonatomic, strong) UIWindow *window;

#pragma mark -


@end
