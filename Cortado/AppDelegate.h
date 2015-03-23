@import UIKit;

@class LocationFetcher;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) LocationFetcher *fetcher;

- (void)manuallyCheckCurrentLocation;

@end

