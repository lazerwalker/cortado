@import UIKit;

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

- (NSAttributedString *)title {
    NSString *title = self.consumption.name;

    if (self.consumption.venue) {
        title = [title stringByAppendingFormat:@" at %@", self.consumption.venue];
    }

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:UIFont.labelFontSize]
    }];
    [attrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:UIFont.labelFontSize] range:[title rangeOfString:self.consumption.name]];

    return attrString;
}

- (NSString *)timestamp {
    return [self.class.dateFormatter stringFromDate:self.consumption.timestamp];
}

- (NSString *)caffeine {
    return [NSString stringWithFormat:@"%@ mg", self.consumption.caffeine];
}

- (NSString *)size {
    return self.consumption.subtype;
}

- (BOOL)showSize {
    return self.consumption != nil;
}
@end
