@import UIKit;

#import "TodayInterface.h"

@interface TodayInterface () <NSFilePresenter>

@property (nonatomic, strong) NSFileCoordinator *coordinator;

@end

@implementation TodayInterface

- (id)init {
    self = [super init];
    if (!self) return nil;

    NSError *error;
    self.coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
    [self.coordinator coordinateReadingItemAtURL:self.presentedItemURL
                                         options:0
                                           error:&error
                                      byAccessor:^(NSURL *newURL) {
        [NSFileCoordinator addFilePresenter:self];
    }];

    return self;
}

#pragma mark -
- (void)stopListening {
    [NSFileCoordinator removeFilePresenter:self];
}

- (void)processBeverages {
    [self.coordinator coordinateReadingItemAtURL:self.presentedItemURL options:0 error:nil byAccessor:^(NSURL *newURL) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:newURL.path];
        if (!array) return;

        for (NSArray *beverage in array) {
            UILocalNotification *notif = [[UILocalNotification alloc] init];
            notif.fireDate = [NSDate date];
            notif.alertBody = [NSString stringWithFormat:@"Drank a %@ (%@mg) at %@", beverage[0], beverage[1], beverage[2]];
            [UIApplication.sharedApplication scheduleLocalNotification:notif];
        }

        [self.coordinator coordinateWritingItemAtURL:self.presentedItemURL
                                             options:NSFileCoordinatorWritingForReplacing
                                               error:nil
                                          byAccessor:^(NSURL *newURL) {
                                              NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@[]];
                                              [data writeToURL:newURL atomically:YES];
                                          }];
    }];
}

#pragma mark - NSFilePresenter
- (NSURL *)presentedItemURL {
    NSURL *containerURL = [NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:@"group.cuppa"];
    return [containerURL URLByAppendingPathComponent:@"addCaffeine"];
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return [NSOperationQueue mainQueue];
}

- (void)presentedItemDidChange {
    [self processBeverages];
}

@end
