#import <ReactiveCocoa/ReactiveCocoa.h>
#import <YLGIFImage/YLGIFImage.h>
#import <YLGIFImage/YLImageView.h>

#import "NotificationsFTUEViewController.h"

@interface NotificationsFTUEViewController ()
@property (readonly) RACSubject *completed;
@property (copy, readonly) FTUEAuthorizationBlock authorizationBlock;
@property (weak, nonatomic) IBOutlet YLImageView *gifView;
@end

@implementation NotificationsFTUEViewController

- (id)initWithAuthorizationBlock:(FTUEAuthorizationBlock)authorizationBlock {
    self = [super init];
    if (!self) return nil;

    _completed = [RACSubject subject];
    _authorizationBlock = authorizationBlock;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.gifView.image = [YLGIFImage imageNamed:@"swipe.gif"];
}

- (IBAction)didTapButton:(id)sender {
    if (self.authorizationBlock) {
        self.authorizationBlock();
    }

    [_completed sendNext:self];
    [_completed sendCompleted];
}

@end
