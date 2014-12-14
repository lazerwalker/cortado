@import UIKit;

@class BeverageConsumption;

@interface CoffeeShopNotification : NSObject

+ (void)registerNotificationType;

+ (BeverageConsumption *)drinkForIdentifier:(NSString *)identifier notification:(UILocalNotification *)notif;

@property (readonly) NSString *name;
@property (readonly, weak) UIApplication *application;

- (id)initWithName:(NSString *)name;

- (id)initWithName:(NSString *)name
       application:(UIApplication *)application NS_DESIGNATED_INITIALIZER;

- (void)schedule;

@end
