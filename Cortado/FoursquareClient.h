@import MapKit;

@class RACSignal;

@interface FoursquareClient : NSObject

- (id)initWithClientID:(NSString *)clientID
          clientSecret:(NSString *)clientSecret;

- (RACSignal *)fetchVenuesNearCoordinate:(CLLocationCoordinate2D)coordinate;

- (RACSignal *)fetchVenuesOfCategory:(NSString *)categoryId
               nearCoordinate:(CLLocationCoordinate2D)coordinate;

@end
