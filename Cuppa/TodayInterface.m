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

#pragma mark - NSFilePresenter
- (NSURL *)presentedItemURL {
    NSURL *containerURL = [NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:@"group.cuppa"];
    return [containerURL URLByAppendingPathComponent:@"addCaffeine"];
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return [NSOperationQueue mainQueue];
}

- (void)presentedItemDidChange {
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.fireDate = [NSDate date];
    notif.alertBody = @"A thing happened!";
    [UIApplication.sharedApplication scheduleLocalNotification:notif];
}

@end
