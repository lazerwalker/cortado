#import "TodayInterface.h"

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) TodayInterface *interface;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.interface = [[TodayInterface alloc] init];

    [application setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum];

    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil];
    [UIApplication.sharedApplication registerUserNotificationSettings:settings];

    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.interface stopListening];
    self.interface = nil;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (!self.interface) {
        self.interface = [[TodayInterface alloc] init];
    }

    [self.interface processAllNewBeveragesWithCompletion:^(NSArray *addedItems) {
        if ([addedItems count] > 0) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
        [self.interface stopListening];
    }];
}


@end
