#import "Drink.h"
#import "DrinkConsumption.h"

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
    NSURL *containerURL = [NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:@"group.cortado"];
    return [containerURL URLByAppendingPathComponent:@"addCaffeine"];
}

- (void)saveDrink:(Drink *)drink
          completion:(void (^)())completionBlock {

    [self.coordinator coordinateReadingItemAtURL:self.presentedItemURL options:0 error:nil byAccessor:^(NSURL *newURL) {
//        NSMutableArray *array = [[NSKeyedUnarchiver unarchiveObjectWithFile:newURL.path] mutableCopy] ?: [[NSMutableArray alloc] init];

        [self.coordinator coordinateWritingItemAtURL:self.presentedItemURL
                                             options:NSFileCoordinatorWritingForReplacing
                                               error:nil
                                          byAccessor:^(NSURL *newURL) {

//            DrinkConsumption *d = [[DrinkConsumption alloc] initWithDrink:drink timestamp:NSDate.date];
//            [array addObject:d];
//            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
//            [data writeToURL:newURL atomically:YES];
            if (completionBlock) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  completionBlock();
              });
            }
        }];
    }];
}

@end
