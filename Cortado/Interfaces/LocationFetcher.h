@import Foundation;

@class FoursquareClient;

@interface LocationFetcher : NSObject

@property (readonly) CLLocation *currentLocation;

- (void)promptForPermissions;

- (void)manuallyCheckCurrentLocation;

- (id)initWithFoursquareClient:(FoursquareClient *)client
                     dataStore:(DataStore *)dataStore NS_DESIGNATED_INITIALIZER;

@end
