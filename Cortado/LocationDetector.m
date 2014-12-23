#import <CocoaPods-Keys/CortadoKeys.h>

#import "CoffeeShopNotification.h"
#import "FoursquareClient.h"
#import "FoursquareVenue.h"

#import "LocationDetector.h"

@implementation LocationDetector

- (id)initWithFoursquareClient:(FoursquareClient *)client {
    self = [super init];
    if (!self) return nil;

    _client = client;

    return self;
}

- (void)manuallyCheckForCoordinate:(CLLocationCoordinate2D)coordinate {
    NSString *coffeeShops = @"4bf58dd8d48988d1e0931735";
    [self.client fetchVenuesOfCategory:coffeeShops nearCoordinate:coordinate completion:^(NSArray *results, NSError *error) {
        FoursquareVenue *result = results.firstObject;

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        if (result == nil) {
            alert.message = @"You're not at a coffee shop.";

            [self.client fetchVenuesNearCoordinate:coordinate completion:^(NSArray *results2, NSError *error) {
                FoursquareVenue *result2 = results2.firstObject;
                if (result2 == nil) return;

                CoffeeShopNotification *notif = [[CoffeeShopNotification alloc] initWithName:result2.name
                                                 coordinate:coordinate];
                [notif schedule];
            }];
        } else {
            alert.message = [NSString stringWithFormat:@"You are at %@", result.name];
            CoffeeShopNotification *notif = [[CoffeeShopNotification alloc] initWithName:result.name
                                                                              coordinate:coordinate];
            [notif schedule];
        }

        [alert show];
    }];
}

- (void)checkForCoordinate:(CLLocationCoordinate2D)coordinate {
    NSString *coffeeShops = @"4bf58dd8d48988d1e0931735";
    [self.client fetchVenuesOfCategory:coffeeShops nearCoordinate:coordinate completion:^(NSArray *results, NSError *error) {
        FoursquareVenue *result = results.firstObject;
        if (result == nil) return;

        CoffeeShopNotification *notif = [[CoffeeShopNotification alloc] initWithName:result.name
                                                                          coordinate:coordinate];
        [notif schedule];
    }];
}
@end
