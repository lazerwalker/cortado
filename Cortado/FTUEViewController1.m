#import <ReactiveCocoa/ReactiveCocoa.h>

#import "FTUEViewController1.h"

@interface FTUEViewController1 ()
@property (readonly) RACSubject *completed;
@end

@implementation FTUEViewController1

- (id)init {
    self = [super init];
    if (!self) return nil;

    _completed = [RACSubject subject];

    return self;
}

- (IBAction)didTapButton:(id)sender {
    [_completed sendNext:self];
    [_completed sendCompleted];
}


@end
