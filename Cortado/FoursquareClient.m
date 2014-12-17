#import <Asterism/Asterism.h>

#import "FoursquareClient.h"
#import "FoursquareVenue.h"

static NSString * const BaseURL = @"https://api.foursquare.com/v2/venues/search";
static NSString * const APIDate = @"20141205";

@interface FoursquareClient ()<NSURLConnectionDelegate>

@property (readonly, nonatomic, strong) NSString *clientID;
@property (readonly, nonatomic, strong) NSString *clientSecret;

@end

@implementation FoursquareClient

- (id)initWithClientID:(NSString *)clientID
          clientSecret:(NSString *)clientSecret {
    self = [super init];
    if (!self) return nil;

    _clientID = clientID;
    _clientSecret = clientSecret;

    return self;
}

- (void)fetchVenuesNearCoordinate:(CLLocationCoordinate2D)coordinate
                       completion:(void(^)(NSArray *results, NSError *error))completion {
    [self makeRequest:[self searchURLForCoordinate:coordinate]
           completion:completion];
}

- (void)searchFor:(NSString *)query
   nearCoordinate:(CLLocationCoordinate2D)coordinate
       completion:(void(^)(NSArray *results, NSError *error))completion {
    [self makeRequest:[self searchURLForCoordinate:coordinate query:query]
           completion:completion];
}

- (void)fetchVenuesOfCategory:(NSString *)categoryId
               nearCoordinate:(CLLocationCoordinate2D)coordinate
                   completion:(void(^)(NSArray *results, NSError *error))completion {
    [self makeRequest:[self searchURLForCoordinate:coordinate categoryId:categoryId]
           completion:^(NSArray *results, NSError *error) {
               if (error) {
                   if (completion) {
                       completion(results, error);
                   }
               }

               UILocalNotification *notif = [[UILocalNotification alloc] init];
               notif.alertBody = [NSString stringWithFormat:@"Near venue: %@",[results.firstObject name]];
               [UIApplication.sharedApplication scheduleLocalNotification:notif];

//               NSArray *categoryVenues = ASTFilter(results, ^BOOL(FoursquareVenue *venue) {
//                   return [venue.categoryId containsObject:categoryId];
//               });
               NSArray *categoryVenues = results.copy;

               if (completion) {
                   completion(categoryVenues, error);
               }
           }];
}

#pragma mark - Private
- (NSURL *)searchURLForCoordinate:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [BaseURL stringByAppendingFormat:@"?client_id=%@&client_secret=%@&v=%@&ll=%f,%f",
                           self.clientID,
                           self.clientSecret,
                           APIDate,
                           coordinate.latitude,
                           coordinate.longitude];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)searchURLForCoordinate:(CLLocationCoordinate2D)coordinate categoryId:(NSString *)categoryId {
    NSString *urlString = [BaseURL stringByAppendingFormat:@"?client_id=%@&client_secret=%@&v=%@&intent=checkin&radius=40&limit=1&ll=%f,%f",
                           self.clientID,
                           self.clientSecret,
                           APIDate,
                           coordinate.latitude,
                           coordinate.longitude];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)searchURLForCoordinate:(CLLocationCoordinate2D)coordinate query:(NSString *)query {
    NSString *urlString = [BaseURL stringByAppendingFormat:@"?client_id=%@&client_secret=%@&v=%@&ll=%f,%f&query=%@",
                           self.clientID,
                           self.clientSecret,
                           APIDate,
                           coordinate.latitude,
                           coordinate.longitude,
                           query];
    return [NSURL URLWithString:urlString];
}

- (void)makeRequest:(NSURL *)url
            completion:(void (^)(NSArray *results, NSError *error))completion {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if (data) {
            NSError *jsonError;
            NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];

            if (jsonError && !error) {
                error = jsonError;
            }

            NSArray *venueJSON = jsonResults[@"response"][@"venues"];
            NSArray *results = ASTMap(venueJSON, ^id(id obj) {
                return [MTLJSONAdapter modelOfClass:FoursquareVenue.class fromJSONDictionary:obj error:nil];
            });

            if (completion) {
                completion(results, error);
            }
        }
    }];
}

@end
