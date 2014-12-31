@import UIKit;

#import <Asterism/Asterism.h>

#import "Drink.h"
#import "DrinkConsumption.h"
#import "PreferredDrinks.h"

#import "CoffeeShopNotification.h"

NSString * const NotificationCategoryBeverage  = @"BEVERAGE";
NSString * const NotificationActionDrink = @"DRINK";
NSString * const NotificationActionCustom = @"DRINK_CUSTOM";


@interface CoffeeShopNotification ()
@end

@implementation CoffeeShopNotification

#pragma mark -
+ (void)registerNotificationTypeWithPreferences:(PreferredDrinks *)preferences {
    NSMutableArray *actions = [[NSMutableArray alloc] init];

    if (preferences.drink) {
        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
        action.identifier = NotificationActionDrink;
        action.title = preferences.drink.name;
        action.activationMode = UIUserNotificationActivationModeBackground;
        action.destructive = NO;
        action.authenticationRequired = NO;

        [actions addObject:action];
    }

    UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
    action.identifier = NotificationActionCustom;
    action.title = (actions.count == 0 ? @"Enter Drink" : @"Other");
    action.activationMode = UIUserNotificationActivationModeForeground;
    action.destructive = NO;
    [actions insertObject:action atIndex:0];

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

#pragma mark -
- (id)initWithName:(NSString *)name
        coordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (!self) return nil;

    _name = name;
    _coordinate = coordinate;

    NSString *coordinateString = [NSString stringWithFormat:@"%@,%@", @(coordinate.latitude), @(coordinate.longitude)];

    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:@"notificationPreferences"];
    PreferredDrinks *preferences = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    Drink *drink = preferences.drink;

    _notif = [[UILocalNotification alloc] init];
    _notif.category = NotificationCategoryBeverage;
    _notif.userInfo = @{@"timestamp":NSDate.date,
                        @"venue":name,
                        @"latLng":coordinateString};

    if (drink) {
        NSDictionary *drinkDict = [MTLJSONAdapter JSONDictionaryFromModel:drink];
        _notif.userInfo = ASTExtend(_notif.userInfo, @{NotificationActionDrink:drinkDict});
    }

    _notif.alertBody = [NSString stringWithFormat:@"It looks like you're at %@. Whatcha drinkin'?", name];

    return self;
}


@end
