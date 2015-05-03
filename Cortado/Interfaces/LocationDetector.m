@import UIKit;

#import <ARAnalytics/ARAnalytics.h>
#import <Keys/CortadoKeys.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "CoffeeShopNotification.h"
#import "FoursquareClient.h"
#import "FoursquareVenue.h"

#import "LocationDetector.h"

@implementation LocationDetector

- (id)initWithFoursquareClient:(FoursquareClient *)client
                     dataStore:(DataStore *)dataStore {
    self = [super init];
    if (!self) return nil;

    _client = client;
    _dataStore = dataStore;
    
    return self;
}

- (void)checkForCoordinate:(CLLocationCoordinate2D)coordinate {
    NSString *coffeeShops = @"4bf58dd8d48988d1e0931735";
    [[[self.client fetchVenuesOfCategory:coffeeShops nearCoordinate:coordinate]
        take:1]
        subscribeNext:^(FoursquareVenue *result) {
            [ARAnalytics event:@"At coffee shop"];

            CoffeeShopNotification *notif = [[CoffeeShopNotification alloc] initWithName:result.name
                                                                          coordinate:coordinate];
            [UIApplication.sharedApplication scheduleLocalNotification:notif.notif];
        }];
}

#pragma mark -
// THIS ONLY EXISTS FOR DEBUG PURPOSES
- (void)manuallyCheckForCoordinate:(CLLocationCoordinate2D)coordinate {
    NSString *coffeeShops = @"4bf58dd8d48988d1e0931735";

    RACSignal *signals = [RACSignal concat:@[
                                             [self.client fetchVenuesOfCategory:coffeeShops nearCoordinate:coordinate],
                                             [self.client fetchVenuesNearCoordinate:coordinate],
                                             [RACSignal return:[NSNull null]]
                                             ]];


    [[signals take:1]
     subscribeNext:^(FoursquareVenue *result) {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         NSString *name;
         if (result == (FoursquareVenue *)[NSNull null]) {
             alert.message = @"We don't know where you are.";
             name = @"no venue";
         } else {
             alert.message = [NSString stringWithFormat:@"You are at %@", result.name];
             name = result.name;
         }

         CoffeeShopNotification *notif = [[CoffeeShopNotification alloc] initWithName:name
                                                                           coordinate:coordinate];
         [UIApplication.sharedApplication scheduleLocalNotification:notif.notif];
         
         [alert show];
     }];
}

@end
