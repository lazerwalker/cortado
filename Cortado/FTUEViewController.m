#import <ReactiveCocoa/ReactiveCocoa.h>

#import "FTUEViewController1.h"

#import "FTUEViewController.h"

static NSString * const FTUECompletedKey = @"completedFTUE";

@interface FTUEViewController ()
@property (readonly) NSArray *screens;
@end

@implementation FTUEViewController

+ (BOOL)hasBeenSeen {
    return [NSUserDefaults.standardUserDefaults boolForKey:FTUECompletedKey];
}

+ (void)setAsSeen {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setBool:YES forKey:FTUECompletedKey];
    [defaults synchronize];
}

- (id)init {
    self = [super init];
    if (!self) return nil;

    _screens = @[
        [[FTUEViewController1 alloc] init],
        [[FTUEViewController1 alloc] init]
    ];

    [self pushViewController:self.screens.firstObject animated:NO];

    self.navigationBarHidden = YES;

    _completedSignal = [[RACSignal concat:[_screens.rac_sequence map:^id(UIViewController<FTUEScreen>* vc) {
        return vc.completed;
    }]] flattenMap:^RACStream *(UIViewController *last) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSUInteger nextIndex = [_screens indexOfObject:last] + 1;
            if (nextIndex == _screens.count) {
                // TODO: Sending completed should be sufficient, but
                // subscribeCompleted wasn't picking the completed signal up for some reason
                [subscriber sendNext:@YES];
                [subscriber sendCompleted];
            } else {
                [self pushViewController:_screens[nextIndex] animated:YES];
            }
            return (RACDisposable *)nil;
        }];
    }];

    return self;
}

@end
