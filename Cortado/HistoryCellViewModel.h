#import "RVMViewModel.h"

@class DrinkConsumption;

@interface HistoryCellViewModel : RVMViewModel

- (id)initWithConsumption:(DrinkConsumption *)consumption;

@property (readonly) NSAttributedString *title;
@property (readonly) NSString *caffeine;
@property (readonly) NSString *size;
@property (readonly) NSString *timestamp;

@property (readonly) BOOL showSize;

@property (readonly) DrinkConsumption *consumption;

@end
