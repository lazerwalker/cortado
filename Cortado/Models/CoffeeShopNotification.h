@import UIKit;
@import CoreLocation;

extern NSString * const NotificationActionCustom;
extern NSString * const NotificationActionDrink;

@class DrinkConsumption;
@class PreferredDrinks;

@interface CoffeeShopNotification : NSObject

+ (void)registerNotificationTypeWithPreferences:(PreferredDrinks *)preferences;

@property (readonly) NSString *name;
@property (readonly) CLLocationCoordinate2D coordinate;
@property (readonly, weak) UIApplication *application;

@property (readonly) UILocalNotification *notif;

- (id)initWithName:(NSString *)name
        coordinate:(CLLocationCoordinate2D)coordinate;

@end
