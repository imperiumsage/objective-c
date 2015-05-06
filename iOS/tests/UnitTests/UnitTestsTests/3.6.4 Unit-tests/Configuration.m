//
//  Configuration.m
//  pubnub
//
//  Created by Sergey on 12/25/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"

@interface Configuration : XCTestCase <PNDelegate> {
     GCDGroup *_resGroup;
     GCDGroup *_resGroupNegative;
}
@end

@implementation Configuration

- (void)tearDown {
    [PubNub disconnect];
    
	[super tearDown];
}

- (void)setUp {
    [super setUp];
    
    [PubNub disconnect];
}

#pragma mark - Scenario

- (void)testScenario {
    
//  Client1 - min information for connection
    PNConfiguration *configuration1 = [PNConfiguration configurationForOrigin:@" .pubnub.co"
                                                                   publishKey:@" "
                                                                 subscribeKey:nil
                                                                    secretKey:nil
                                                                    cipherKey:nil];

    PubNub *client1 = [self connectClientWithConfiguration:configuration1];
    
    [client1 setClientIdentifier:@"pubnub-user"];

    [GCDWrapper sleepForSeconds:1];
    XCTAssertEqualObjects([client1 clientIdentifier], @"pubnub-user", @"Client identifiers inconsistent.");
    
    XCTAssertTrue(([client1 isConnected]));
    XCTAssertEqualObjects(client1.configuration.origin, configuration1.origin, @"Origins are not equial");
    XCTAssertEqualObjects(client1.configuration.publishKey, configuration1.publishKey, @"PublishKeys are not equial");
    XCTAssertEqualObjects(client1.configuration.subscriptionKey, configuration1.subscriptionKey, @"SubscriptionKeys are not equial");
    XCTAssertEqualObjects(client1.configuration.cipherKey, configuration1.cipherKey, @"CipherKey are not equial");

   
//  Client2 - max mix information for connection (keys can hold any information, why?)
    PNConfiguration *configuration2 = [PNConfiguration configurationForOrigin:@" wrewrewrerewrweterqtwewerweerwrhgfhdfgfggdfgdfgdfgdfgdfewqrewr.pubnub.co"
                                                                   publishKey:@"wrewrewrerewrweterqtwewerweerwrhgfhdfgfggdfgdfgdfgdfgdfewqrewrwrewrewrerewrweterqtwewerweerwrhgfhdfgfggdffgdfgdfgdfewqrewrewrwrew"
                                                                    subscribeKey:@"wrewrewrerewrweterqtwewerweerwrhgfhdfgfggdfgdfgdfgdfgdfewqrewrwwrewrerewrweterqtwewerweerwrhgfhdfgfggdfgdfgdfgdfgdfewqrewrewrr"
                                                                    secretKey:@"wrewrewrerewrweterqtwewerweerwrhgfhdfgfggdfgdfgdfgdfgdfewqrewrwrrewrerewrweterqtwewerweerwrhgfhdfgfggdfgdfgdfgdfgdfewqrewrewrwrer"
                                                                    cipherKey:@"wrewrewrerewrweterqtwewerweerwrhgfhdfgfggdfgdfgdfgdfgdfewqrewrwrewrerewrweterqtwewerweerwrhgfhdfgfggdfgdfgdfgdfgdfewqrewrewrwre"];
    
    PubNub *client2 = [self connectClientWithConfiguration:configuration2];
    
    XCTAssertTrue(([client2 isConnected]));
    XCTAssertEqualObjects(client2.configuration.origin, configuration2.origin, @"Origins are not equial");
    XCTAssertEqualObjects(client2.configuration.publishKey, configuration2.publishKey, @"PublishKeys are not equial");
    XCTAssertEqualObjects(client2.configuration.subscriptionKey, configuration2.subscriptionKey, @"SubscriptionKeys are not equial");
    XCTAssertEqualObjects(client2.configuration.cipherKey, configuration2.cipherKey, @"CipherKey are not equial");

//  Client3 - incorrect Origin
    PNConfiguration *configuration3 = [PNConfiguration configurationForOrigin:@" .pub.co"
                                                                   publishKey:@" "                                                                 subscribeKey:nil
                                                                    secretKey:nil
                                                                    cipherKey:nil];
    
    PubNub *client3 = [self connectClientWithConfiguration:configuration3];
    XCTAssertFalse(([client3 isConnected])); // False test
    
//  Client4 - incorrect publishKey
    PNConfiguration *configuration4 = [PNConfiguration configurationForOrigin:@" .pubnub.co"
                                                                   publishKey:nil
                                                                 subscribeKey:nil
                                                                    secretKey:nil
                                                                    cipherKey:nil];
    
    _resGroup = nil;
    _resGroupNegative = [GCDGroup group];
    
    [_resGroupNegative enterTimes:2];
    
    __block PubNub *client4 = [PubNub connectingClientWithConfiguration:configuration4 delegate:self andSuccessBlock:^(NSString *res) {
        [_resGroupNegative leave];
    } errorBlock:^(PNError *error) {
        NSLog(@"Error occurs during connection: %@", error);
        [_resGroupNegative leave];
    }];
    
#warning - Failed right now, it seems delegate wasn't set before we notify about error. That is why we don't receive connectionDidFailWithError during this test.
    if ([GCDWrapper isGCDGroup:_resGroupNegative timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout is fired. Didn't connect client to PubNub");
    }
    _resGroupNegative = nil;
    
    XCTAssertFalse(([client4 isConnected])); // False test
}


#pragma mark - Private method

- (id)connectClientWithConfiguration:(PNConfiguration *)configuration {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    __block PubNub *client = [PubNub connectingClientWithConfiguration:configuration delegate:self andSuccessBlock:^(NSString *res) {
        [_resGroup leave];
    } errorBlock:^(PNError *error) {
        NSLog(@"Error occurs during connection: %@", error);
        [_resGroup leave];
        client = nil;
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout is fired. Didn't connect client to PubNub");
    }
    
    _resGroup = nil;
    return client;
}


#pragma mark - PubNub Delegate

// Connect did
- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Connect fail
- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    NSLog(@"Did fail connection: %@", error);
    
    if (_resGroupNegative) {
        [_resGroupNegative leave];
    }
}

@end
