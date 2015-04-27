#import <UIKit/UIKit.h>
#import "AppDelegate.h" 
#import "TestingAppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        BOOL isRunningTests = NSClassFromString(@"XCTestCase") != nil;
        Class appDelegateClass = isRunningTests ? [TestingAppDelegate class] : [AppDelegate class];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass(appDelegateClass));
    }
}
