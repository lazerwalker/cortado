@import UIKit;

#import "Drink.h"
#import "DrinkConsumption.h"
#import "DrinkConsumptionSerializer.h"
#import "PreferredDrinks.h"

#import "CoffeeShopNotification.h"

NSString * const NotificationCategoryBeverage  = @"BEVERAGE";
NSString * const NotificationActionOne = @"DRINK_ONE";
NSString * const NotificationActionTwo = @"DRINK_TWO";
NSString * const NotificationActionNone = @"DRINK_NONE";


@interface CoffeeShopNotification ()

@property (readonly, nonatomic, strong) UILocalNotification *notif;

@end

@implementation CoffeeShopNotification

#pragma mark -
+ (void)registerNotificationTypeWithPreferences:(PreferredDrinks *)preferences {
    NSMutableArray *actions = [[NSMutableArray alloc] init];

    if (preferences.second) {
        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
        action.identifier = NotificationActionOne;
        action.title = preferences.second.name;
        action.activationMode = UIUserNotificationActivationModeBackground;
        action.destructive = NO;
        action.authenticationRequired = NO;

        [actions addObject:action];
    }

    if (preferences.first) {
        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
        action.identifier = NotificationActionTwo;
        action.title = preferences.first.name;
        action.activationMode = UIUserNotificationActivationModeBackground;
        action.destructive = NO;
        action.authenticationRequired = NO;

        [actions addObject:action];
    }

    if (actions.count == 0) {
        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
        action.identifier = NotificationActionNone;
        action.title = @"Enter Drink";
        action.activationMode = UIUserNotificationActivationModeForeground;
        action.destructive = NO;

        [actions addObject:action];

    }

    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    notificationCategory.identifier = NotificationCategoryBeverage;
    [notificationCategory setActions:actions.copy forContext:UIUserNotificationActionContextDefault];
    [notificationCategory setActions:actions.copy forContext:UIUserNotificationActionContextMinimal];

    NSSet *category = [NSSet setWithObject:notificationCategory];

    UIUserNotificationType notificationType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:category];
    [UIApplication.sharedApplication registerUserNotificationSettings:notificationSettings];

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:preferences];
    [NSUserDefaults.standardUserDefaults setObject:data forKey:@"notificationPreferences"];
}

+ (DrinkConsumption *)drinkForIdentifier:(NSString *)identifier notification:(UILocalNotification *)notif {
    if (![@[NotificationActionOne, NotificationActionTwo] containsObject:identifier]) return nil;
    return [DrinkConsumptionSerializer consumptionFromUserInfo:notif.userInfo identifier:identifier];
}

#pragma mark -
- (id)initWithName:(NSString *)name
        coordinate:(CLLocationCoordinate2D)coordinate
       application:(UIApplication *)application {
    self = [super init];
    if (!self) return nil;

    _name = name;
    _coordinate = coordinate;
    _application = application;

    NSString *coordinateString = [NSString stringWithFormat:@"%@,%@", @(coordinate.latitude), @(coordinate.longitude)];

    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:@"notificationPreferences"];
    PreferredDrinks *preferences = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    Drink *drink1 = preferences.second;
    Drink *drink2 = preferences.first;
    NSDictionary *drinkOneDict = [MTLJSONAdapter JSONDictionaryFromModel:drink1];
    NSDictionary *drinkTwoDict = [MTLJSONAdapter JSONDictionaryFromModel:drink2];

    _notif = [[UILocalNotification alloc] init];
    _notif.category = NotificationCategoryBeverage;
    _notif.userInfo = @{@"timestamp":NSDate.date,
                        @"venue":name,
                        @"latLng":coordinateString,
                        NotificationActionOne:drinkOneDict,
                        NotificationActionTwo:drinkTwoDict
                      };

    _notif.alertBody = [NSString stringWithFormat:@"It looks like you're at %@. Whatcha drinkin'?", name];

    return self;
}

- (id)initWithName:(NSString *)name
        coordinate:(CLLocationCoordinate2D)coordinate {
    return [self initWithName:name
                  coordinate:coordinate
                  application:UIApplication.sharedApplication];
}

- (void)schedule {
    [self.application scheduleLocalNotification:self.notif];
}

@end
