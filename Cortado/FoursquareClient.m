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
           completion:completion];
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
    NSString *urlString = [BaseURL stringByAppendingFormat:@"?client_id=%@&client_secret=%@&v=%@&ll=%f,%f&radius=100&categoryId=%@",
                           self.clientID,
                           self.clientSecret,
                           APIDate,
                           coordinate.latitude,
                           coordinate.longitude,
                           categoryId];
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

            NSMutableArray *mutableResults = [NSMutableArray new];
            for (NSDictionary *result in jsonResults[@"response"][@"venues"]) {
                FoursquareVenue *venue = [MTLJSONAdapter modelOfClass:FoursquareVenue.class fromJSONDictionary:result error:&error];
                [mutableResults addObject:venue];
            }

            if (completion) {
                completion([mutableResults copy], error);
            }
        }
    }];
}

@end
