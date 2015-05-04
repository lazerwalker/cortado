@import CoreLocation;
@import Foundation;

@class DataStore;
@class FoursquareClient;

@interface LocationDetector : NSObject

- (id)initWithFoursquareClient:(FoursquareClient *)client
                     dataStore:(DataStore *)dataStore
NS_DESIGNATED_INITIALIZER;

- (void)checkForCoordinate:(CLLocationCoordinate2D)coordinate;

// Temporary, for debug purposes
- (void)manuallyCheckForCoordinate:(CLLocationCoordinate2D)coordinate;

@property (readonly) FoursquareClient *client;
@property (readonly) DataStore *dataStore;

// Exposed for tests
@property (readwrite, nonatomic, weak) UIApplication *application;

@end
