#import "TodayInterface.h"

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) TodayInterface *interface;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.interface = [[TodayInterface alloc] init];

    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil];
    [UIApplication.sharedApplication registerUserNotificationSettings:settings];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.interface stopListening];
    self.interface = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
