@import UIKit;

#import <Asterism/Asterism.h>

#import "Drink.h"
#import "DrinkConsumption.h"
#import "Preferences.h"

#import "CoffeeShopNotification.h"

NSString * const NotificationCategoryBeverage  = @"BEVERAGE";
NSString * const NotificationActionDrink = @"DRINK";
NSString * const NotificationActionCustom = @"DRINK_CUSTOM";


@interface CoffeeShopNotification ()
@end

@implementation CoffeeShopNotification

#pragma mark -
+ (void)registerNotificationTypeWithPreferences:(Preferences *)preferences {
    NSMutableArray *actions = [[NSMutableArray alloc] init];

    if (preferences.drinks) {
        for (Drink *drink in preferences.drinks) {
            UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
            action.identifier = NotificationActionDrink;
            action.title = drink.name;
            action.activationMode = UIUserNotificationActivationModeBackground;
            action.destructive = NO;
            action.authenticationRequired = NO;

            [actions addObject:action];
        }
    }

    UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
    action.identifier = NotificationActionCustom;
    action.title = (actions.count == 0 ? @"Enter Drink" : @"Other");
    action.activationMode = UIUserNotificationActivationModeForeground;
    action.destructive = NO;
    [actions insertObject:action atIndex:0];

    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    notificationCategory.identifier = NotificationCategoryBeverage;

    NSArray *defaultActions = actions.copy;
    [notificationCategory setActions:defaultActions forContext:UIUserNotificationActionContextDefault];

    NSArray *minimalActions = [actions subarrayWithRange:NSMakeRange(0, MIN(actions.count, 2))];
    [notificationCategory setActions:minimalActions forContext:UIUserNotificationActionContextMinimal];

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
    Preferences *preferences = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    Drink *drink = preferences.drinks.firstObject;

    _notif = [[UILocalNotification alloc] init];
    _notif.category = NotificationCategoryBeverage;
    _notif.userInfo = @{@"timestamp":NSDate.date,
                        @"venue":name,
                        @"latLng":coordinateString};

    if (drink) {
        NSDictionary *drinkDict = [MTLJSONAdapter JSONDictionaryFromModel:drink];
        if (drinkDict[@"subtype"] == [NSNull null]) {
            NSMutableDictionary *mutable = drinkDict.mutableCopy;
            [mutable removeObjectForKey:@"subtype"];
            drinkDict = mutable.copy;
        }
        _notif.userInfo = ASTExtend(_notif.userInfo, @{NotificationActionDrink:drinkDict});
    }

    _notif.alertBody = [NSString stringWithFormat:@"It looks like you're at %@. Whatcha drinkin'?", name];

    if ([name isEqualToString:@"no venue"]) {
        _notif.alertBody = @"Whatcha drinkin'?";
    }


    return self;
}


@end
