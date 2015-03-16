@import CoreLocation;

#import "FoursquareClient.h"
#import "LocationDetector.h"
#import "LocationFetcher.h"

#import <ARAnalytics/ARAnalytics.h>

@interface LocationFetcher ()<CLLocationManagerDelegate>

@property (readonly, nonatomic, strong) LocationDetector *detector;
@property (readonly, nonatomic, strong) FoursquareClient *foursquareClient;
@property (readonly, nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation LocationFetcher

- (id)initWithFoursquareClient:(FoursquareClient *)client {
    self = [super init];
    if (!self) return nil;

    _foursquareClient = client;
    _detector = [[LocationDetector alloc] initWithFoursquareClient:self.foursquareClient];

    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    return self;
}

- (void)promptForPermissions {
    [self.locationManager requestAlwaysAuthorization];
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

    [ARAnalytics event:@"visited location" withProperties:@{
                                                            @"coords":[NSString stringWithFormat:@"%@,%@",@(visit.coordinate.latitude), @(visit.coordinate.longitude)]}];

    [self.detector checkForCoordinate:visit.coordinate];
}

#pragma mark -
// TODO: This shouldn't be the purview of the app delegate,
// but this will make debugging easy for now.
- (void)manuallyCheckCurrentLocation {
    [self.detector manuallyCheckForCoordinate:self.locationManager.location.coordinate];
}

@end
