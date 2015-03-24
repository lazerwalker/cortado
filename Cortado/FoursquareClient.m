@import UIKit;
#import <ARAnalytics/ARAnalytics.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

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

- (RACSignal *)fetchVenuesNearCoordinate:(CLLocationCoordinate2D)coordinate {
//                       completion:(void(^)(NSArray *results, NSError *error))completion {
    return [self makeRequest:[self searchURLForCoordinate:coordinate] coordinate:coordinate];
}

- (RACSignal *)fetchVenuesOfCategory:(NSString *)categoryId
                      nearCoordinate:(CLLocationCoordinate2D)coordinate {
    return [self makeRequest:[self searchURLForCoordinate:coordinate categoryId:categoryId] coordinate:coordinate];
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
    NSString *urlString = [BaseURL stringByAppendingFormat:@"?client_id=%@&client_secret=%@&v=%@&intent=checkin&radius=0&categoryId=%@&limit=1&ll=%f,%f",
                           self.clientID,
                           self.clientSecret,
                           APIDate,
                           categoryId,
                           coordinate.latitude,
                           coordinate.longitude];
    return [NSURL URLWithString:urlString];
}

- (RACSignal *)makeRequest:(NSURL *)url coordinate:(CLLocationCoordinate2D)coordinate {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

            if (data) {
                NSError *jsonError;
                NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];

                if (jsonError && !error) {
                    error = jsonError;
                }

                if (error) {
                    [subscriber sendError:error];
                    return;
                }

                NSArray *venueJSON = jsonResults[@"response"][@"venues"];
                for (NSDictionary *venueDict in venueJSON) {
                    FoursquareVenue *venue = [MTLJSONAdapter modelOfClass:FoursquareVenue.class fromJSONDictionary:venueDict error:&error];
                    if (error) {
                        [subscriber sendError:error];
                    } else {
                        [subscriber sendNext:venue];
                    }
                }
                [subscriber sendCompleted];

                if (venueJSON.count == 0) {
                    [ARAnalytics event:@"no coffee shop found"];

                }
            }
        }];

        // TODO: This should be disposable.
        return (RACDisposable *)nil;
    }];
}

@end
