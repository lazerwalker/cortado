@import UIKit;

#import "Beverage.h"
#import "BeverageConsumption.h"
#import "PreferredDrinks.h"

#import "CoffeeShopNotification.h"

NSString * const NotificationCategoryBeverage  = @"BEVERAGE";
NSString * const NotificationActionOne = @"DRINK_ONE";
NSString * const NotificationActionTwo = @"DRINK_TWO";

@interface CoffeeShopNotification ()

@property (readonly, nonatomic, strong) UILocalNotification *notif;

@end

@implementation CoffeeShopNotification

#pragma mark -
+ (void)registerNotificationTypeWithPreferences:(PreferredDrinks *)preferences {
    if (!(preferences.first && preferences.second)) return;
    
    UIMutableUserNotificationAction *notificationAction1 = [[UIMutableUserNotificationAction alloc] init];
    notificationAction1.identifier = NotificationActionOne;
    notificationAction1.title = preferences.first.name;
    notificationAction1.activationMode = UIUserNotificationActivationModeBackground;
    notificationAction1.destructive = NO;
    notificationAction1.authenticationRequired = NO;

    UIMutableUserNotificationAction *notificationAction2 = [[UIMutableUserNotificationAction alloc] init];
    notificationAction2.identifier = NotificationActionTwo;
    notificationAction2.title = preferences.second.name;
    notificationAction2.activationMode = UIUserNotificationActivationModeBackground;
    notificationAction2.destructive = NO;
    notificationAction2.authenticationRequired = NO;

    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    notificationCategory.identifier = NotificationCategoryBeverage;
    [notificationCategory setActions:@[notificationAction1,notificationAction2] forContext:UIUserNotificationActionContextDefault];
    [notificationCategory setActions:@[notificationAction1,notificationAction2] forContext:UIUserNotificationActionContextMinimal];

    NSSet *category = [NSSet setWithObject:notificationCategory];

    UIUserNotificationType notificationType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:category];
    [UIApplication.sharedApplication registerUserNotificationSettings:notificationSettings];

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:preferences];
    [NSUserDefaults.standardUserDefaults setObject:data forKey:@"notificationPreferences"];
}

+ (BeverageConsumption *)drinkForIdentifier:(NSString *)identifier notification:(UILocalNotification *)notif {
    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:@"notificationPreferences"];
    PreferredDrinks *preferences = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    NSDate *timestamp = notif.userInfo[@"timestamp"];
    Beverage *beverage;
    if ([identifier isEqualToString:NotificationActionOne]) {
        beverage = preferences.first;
    } else {
        beverage = preferences.second;
    }

    return [[BeverageConsumption alloc] initWithBeverage:beverage timestamp:timestamp];
}

#pragma mark -
- (id)initWithName:(NSString *)name
       application:(UIApplication *)application {
    self = [super init];
    if (!self) return nil;

    _name = name;
    _application = application;

    _notif = [[UILocalNotification alloc] init];
    _notif.category = NotificationCategoryBeverage;
    _notif.userInfo = @{@"timestamp":NSDate.date};
    _notif.alertBody = [NSString stringWithFormat:@"It looks like you're at %@. Whatcha drinkin'?", name];

    return self;
}

- (id)initWithName:(NSString *)name {
    return [self initWithName:name application:UIApplication.sharedApplication];
}

- (void)schedule {
    [self.application scheduleLocalNotification:self.notif];
}

@end
