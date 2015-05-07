#import "Preferences.h"

@implementation Preferences

- (id)initWithDrinks:(NSArray *)drinks {
    self = [super init];
    if (!self) return nil;

    _drinks = drinks;

    return self;
}

@end
