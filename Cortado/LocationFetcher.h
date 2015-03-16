@import Foundation;

@class FoursquareClient;

@interface LocationFetcher : NSObject

- (void)promptForPermissions;

- (void)manuallyCheckCurrentLocation;

- (id)initWithFoursquareClient:(FoursquareClient *)client NS_DESIGNATED_INITIALIZER;

@end
