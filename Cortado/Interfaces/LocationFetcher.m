@import CoreLocation;

#import "DataStore.h"
#import "FoursquareClient.h"
#import "LocationDetector.h"
#import "LocationFetcher.h"

@interface LocationFetcher ()<CLLocationManagerDelegate>

@property (readonly, nonatomic, strong) LocationDetector *detector;
@property (readonly, nonatomic, strong) FoursquareClient *foursquareClient;
@property (readonly, nonatomic, strong) CLLocationManager *locationManager;
@property (readonly, nonatomic, strong) DataStore *dataStore;

@end

@implementation LocationFetcher

- (id)initWithFoursquareClient:(FoursquareClient *)client
dataStore:(DataStore *)dataStore {
    self = [super init];
    if (!self) return nil;

    _dataStore = dataStore;
    _foursquareClient = client;
    _detector = [[LocationDetector alloc] initWithFoursquareClient:self.foursquareClient
                                                          dataStore:dataStore];

    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    return self;
}

- (void)promptForPermissions {
    [self.locationManager requestAlwaysAuthorization];
}

- (CLLocation *)currentLocation {
    return self.locationManager.location;
}

#pragma mark - CLLocationDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [manager startMonitoringVisits];
    }
}

- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit {
    BOOL isStart = [visit.departureDate isEqualToDate:NSDate.distantFuture];
    if (!isStart) return;

    [self.detector checkForCoordinate:visit.coordinate];
}

#pragma mark -
// TODO: This shouldn't be the purview of the app delegate,
// but this will make debugging easy for now.
- (void)manuallyCheckCurrentLocation {
    [self.detector manuallyCheckForCoordinate:self.locationManager.location.coordinate];
}

@end
