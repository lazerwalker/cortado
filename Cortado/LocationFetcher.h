@import Foundation;

@class FoursquareClient;

@interface LocationFetcher : NSObject

+ (BOOL)shouldPromptUserForPermissions;
+ (void)doNotPromptForPermissions;

- (void)manuallyCheckCurrentLocation;

- (id)initWithFoursquareClient:(FoursquareClient *)client NS_DESIGNATED_INITIALIZER;

@end
