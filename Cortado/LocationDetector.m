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

- (void)checkForCoordinate:(CLLocationCoordinate2D)coordinate {
    NSString *coffeeShops = @"4bf58dd8d48988d1e0931735";
    [self.client fetchVenuesOfCategory:coffeeShops nearCoordinate:coordinate completion:^(NSArray *results, NSError *error) {
        FoursquareVenue *result = results.firstObject;
        if (result == nil) return;

        CoffeeShopNotification *notif = [[CoffeeShopNotification alloc] initWithName:result.name];
        [notif schedule];
    }];
}
@end
