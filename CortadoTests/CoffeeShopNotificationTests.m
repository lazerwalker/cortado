#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>
#import <OCMock/OCMock.h>

#import "Drink.h"
#import "Preferences.h"

#import "CoffeeShopNotification.h"

SpecBegin(CoffeeShopNotification)

__block CoffeeShopNotification *subject;

describe(@"creating an Apple notification", ^{
    __block UILocalNotification *notif;
    __block Drink *drink;

    context(@"when there is a preferred drink set", ^{
        before(^{
            drink = [[Drink alloc] initWithName:@"Club Mate" subtype:@"330ml" caffeine:@150];
            Preferences *preferences = [[Preferences alloc] initWithDrink:drink];
            [CoffeeShopNotification registerNotificationTypeWithPreferences:preferences];

            subject = [[CoffeeShopNotification alloc] initWithName:@"Sightglass Coffee" coordinate:CLLocationCoordinate2DMake(37.77, -122.4)];
            notif = subject.notif;
        });

        after(^{
            [CoffeeShopNotification registerNotificationTypeWithPreferences:nil];
        });

        it(@"should have the correct text", ^{
            expect(notif.alertBody).to.equal(@"It looks like you're at Sightglass Coffee. Whatcha drinkin'?");
        });

        it(@"should have the correct metadata", ^{
            expect(notif.userInfo[@"latLng"]).to.equal(@"37.77,-122.4");
            expect(notif.userInfo[@"venue"]).to.equal(@"Sightglass Coffee");
            expect(notif.userInfo[NotificationActionDrink][@"name"]).to.equal(@"Club Mate");

            NSDate *date = notif.userInfo[@"timestamp"];
            expect(date.timeIntervalSinceNow).to.beInTheRangeOf(-1.0, 1.0);
        });

        it(@"should have the proper notif category", ^{
            expect(notif.category).to.equal(NotificationCategoryBeverage);
        });

        it(@"allows drinks with no subtype", ^{
            drink = [[Drink alloc] initWithName:@"Gibraltar" caffeine:@150];
            Preferences *preferences = [[Preferences alloc] initWithDrink:drink];
            [CoffeeShopNotification registerNotificationTypeWithPreferences:preferences];

            subject = [[CoffeeShopNotification alloc] initWithName:@"Sightglass Coffee" coordinate:CLLocationCoordinate2DMake(37.77699197247508, -122.40852980833175)];
            notif = subject.notif;

            expect(notif).notTo.beNil();
        });
    });

    context(@"when there is no preferred drink set", ^{
        before(^{
            [CoffeeShopNotification registerNotificationTypeWithPreferences:nil];

            subject = [[CoffeeShopNotification alloc] initWithName:@"Sightglass Coffee" coordinate:CLLocationCoordinate2DMake(37.77, -122.4)];
            notif = subject.notif;
        });

        it(@"should have the correct text", ^{
            expect(notif.alertBody).to.equal(@"It looks like you're at Sightglass Coffee. Whatcha drinkin'?");
        });
    });
});

describe(@"notification drink preferences", ^{
    __block UIUserNotificationCategory *category;
    __block NSArray *actions;

    context(@"when there is no preferred drink", ^{
        before(^{
            [CoffeeShopNotification registerNotificationTypeWithPreferences:nil];
            UIUserNotificationSettings *settings = UIApplication.sharedApplication.currentUserNotificationSettings;
            category = settings.categories.allObjects.firstObject;
            actions = [category actionsForContext:UIUserNotificationActionContextDefault];
        });

        it(@"should only have one option", ^{
            expect(actions).to.haveALengthOf(1);
        });

        it(@"should have the correct title", ^{
            UIUserNotificationAction *action = actions.firstObject;
            expect(action.title).to.equal(@"Enter Drink");
        });

        it(@"should be a manual entry button", ^{
            UIUserNotificationAction *action = actions.firstObject;
            expect(action.identifier).to.equal(NotificationActionCustom);
            expect(action.activationMode).to.equal(UIUserNotificationActivationModeForeground);
        });
    });

    context(@"when there is a preferred drink", ^{
        before(^{
            Drink *drink = [[Drink alloc] initWithName:@"Gibraltar" caffeine:@150];
            Preferences *preferences = [[Preferences alloc] initWithDrink:drink];
            [CoffeeShopNotification registerNotificationTypeWithPreferences:preferences];

            UIUserNotificationSettings *settings = UIApplication.sharedApplication.currentUserNotificationSettings;
            category = settings.categories.allObjects.firstObject;
            actions = [category actionsForContext:UIUserNotificationActionContextDefault];
        });

        after(^{
            [CoffeeShopNotification registerNotificationTypeWithPreferences:nil];
        });

        it(@"should have two actions", ^{
            expect(actions).to.haveALengthOf(2);
        });

        it(@"should show the preferred drink", ^{
            UIUserNotificationAction *action = actions.lastObject;
            expect(action.title).to.equal(@"Gibraltar");
            expect(action.identifier).to.equal(NotificationActionDrink);
            expect(action.activationMode).to.equal(UIUserNotificationActivationModeBackground);
        });

        it(@"should show an 'Other' option", ^{
            UIUserNotificationAction *action = actions.firstObject;
            expect(action.title).to.equal(@"Other");
            expect(action.identifier).to.equal(NotificationActionCustom);
            expect(action.activationMode).to.equal(UIUserNotificationActivationModeForeground);
        });

        it(@"setting a new drink should override it", ^{
            Drink *drink = [[Drink alloc] initWithName:@"Espresso" caffeine:@150];
            Preferences *preferences = [[Preferences alloc] initWithDrink:drink];
            [CoffeeShopNotification registerNotificationTypeWithPreferences:preferences];

            UIUserNotificationSettings *settings = UIApplication.sharedApplication.currentUserNotificationSettings;
            category = settings.categories.allObjects.firstObject;
            actions = [category actionsForContext:UIUserNotificationActionContextDefault];
            expect([actions.lastObject title]).to.equal(@"Espresso");
        });
    });
});

SpecEnd
