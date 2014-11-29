@import UIKit;

#import "BeverageProcessor.h"

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

- (void)processAllNewBeveragesWithCompletion:(void (^)(NSArray *addedItems))completion {
    [self.coordinator coordinateReadingItemAtURL:self.presentedItemURL options:0 error:nil byAccessor:^(NSURL *newURL) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:newURL.path];
        if (!array)  {
            if (completion) {
                completion(nil);
            }
            return;
        }

        BeverageProcessor *processor = [[BeverageProcessor alloc] init];
        [processor processBeverages:array];

        [self.coordinator coordinateWritingItemAtURL:self.presentedItemURL
                                             options:NSFileCoordinatorWritingForReplacing
                                               error:nil
                                          byAccessor:^(NSURL *newURL) {
                                              NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@[]];
                                              [data writeToURL:newURL atomically:YES];
                                              if (completion) {
                                                  completion(array);
                                              }
                                          }];
    }];
}

#pragma mark - NSFilePresenter
- (NSURL *)presentedItemURL {
    NSURL *containerURL = [NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:@"group.cortado"];
    return [containerURL URLByAppendingPathComponent:@"addCaffeine"];
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return [NSOperationQueue mainQueue];
}

- (void)presentedItemDidChange {
    [self processAllNewBeveragesWithCompletion:nil];
}

@end
