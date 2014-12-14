#import <Foundation/Foundation.h>

@class FoursquareClient;

@interface LocationDetector : NSObject

- (id)initWithFoursquareClient:(FoursquareClient *)client;

- (void)checkForCoordinate:(CLLocationCoordinate2D)coordinate;

@property (readonly) FoursquareClient *client;

@end
