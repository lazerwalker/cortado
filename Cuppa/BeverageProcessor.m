@import UIKit;

#import "BeverageProcessor.h"

@implementation BeverageProcessor

- (void)processBeverages:(NSArray *)array {
    for (NSArray *beverage in array) {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.fireDate = [NSDate date];
        notif.alertBody = [NSString stringWithFormat:@"Drank a %@ (%@mg) at %@", beverage[0], beverage[1], beverage[2]];
        [UIApplication.sharedApplication scheduleLocalNotification:notif];
    }
}

@end
