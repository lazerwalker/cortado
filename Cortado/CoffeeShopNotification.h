@import UIKit;
@import CoreLocation;

@class DrinkConsumption;
@class PreferredDrinks;

@interface CoffeeShopNotification : NSObject

+ (void)registerNotificationTypeWithPreferences:(PreferredDrinks *)preferences;

+ (DrinkConsumption *)drinkForIdentifier:(NSString *)identifier notification:(UILocalNotification *)notif;

@property (readonly) NSString *name;
@property (readonly) CLLocationCoordinate2D coordinate;
@property (readonly, weak) UIApplication *application;

- (id)initWithName:(NSString *)name
        coordinate:(CLLocationCoordinate2D)coordinate;

- (id)initWithName:(NSString *)name
        coordinate:(CLLocationCoordinate2D)coordinate
       application:(UIApplication *)application NS_DESIGNATED_INITIALIZER;

- (void)schedule;

@end
