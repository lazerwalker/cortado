#import "AppInterface.h"

@interface AppInterface () <NSFilePresenter>

@property (nonatomic, strong) NSFileCoordinator *coordinator;

@end

@implementation AppInterface

@synthesize presentedItemOperationQueue;

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];

    presentedItemOperationQueue = [[NSOperationQueue alloc] init];
    return self;
}

- (NSURL *)presentedItemURL {
    NSURL *containerURL = [NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:@"group.cuppa"];
    return [containerURL URLByAppendingPathComponent:@"addCaffeine"];
}

- (void)saveBeverage:(NSString *)beverage
        withCaffeine:(CGFloat)caffeine
          completion:(void (^)())completionBlock {
    NSError *error;
    [self.coordinator coordinateWritingItemAtURL:self.presentedItemURL
                                         options:NSFileCoordinatorWritingForReplacing
                                           error:&error
                                      byAccessor:^(NSURL *newURL) {
        NSArray *drink = @[beverage, @(caffeine), NSDate.date];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:drink];
        [data writeToURL:newURL atomically:YES];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    }];
    NSLog(@"================> %@", error);
}

@end
