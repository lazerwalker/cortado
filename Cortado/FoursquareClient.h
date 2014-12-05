@import MapKit;

@interface FoursquareClient : NSObject

- (id)initWithClientID:(NSString *)clientID
          clientSecret:(NSString *)clientSecret;

- (void)fetchVenuesNearCoordinate:(CLLocationCoordinate2D)coordinate
                       completion:(void(^)(NSArray *results, NSError *error))completion;

- (void)searchFor:(NSString *)query
   nearCoordinate:(CLLocationCoordinate2D)coordinate
       completion:(void(^)(NSArray *results, NSError *error))completion;

- (void)fetchVenuesOfCategory:(NSString *)categoryId
   nearCoordinate:(CLLocationCoordinate2D)coordinate
       completion:(void(^)(NSArray *results, NSError *error))completion;

@end
