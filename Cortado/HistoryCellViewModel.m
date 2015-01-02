#import "DrinkConsumption.h"

#import "HistoryCellViewModel.h"

@implementation HistoryCellViewModel

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *df;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        df.timeStyle = NSDateFormatterShortStyle;
    });
    return df;

}

- (id)initWithConsumption:(DrinkConsumption *)consumption {
    self = [super init];
    if (!self) return nil;

    _consumption = consumption;

    return self;
}

#pragma mark -

- (NSString *)title {
    NSString *title = [self.consumption.name stringByAppendingFormat:@" (%@ mg)", self.consumption.caffeine];

    if (self.consumption.venue) {
        title = [title stringByAppendingFormat:@" at %@", self.consumption.venue];
    }
    
    return title;
}

- (NSString *)subtitle {
    return [self.class.dateFormatter stringFromDate:self.consumption.timestamp];
}
@end
