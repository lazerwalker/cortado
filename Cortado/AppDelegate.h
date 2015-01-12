#import <UIKit/UIKit.h>

@class CLLocationManager;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CLLocationManager *locationManager;

- (void)manuallyCheckCurrentLocation;

@end

