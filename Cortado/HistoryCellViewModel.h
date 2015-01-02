#import "RVMViewModel.h"

@class DrinkConsumption;

@interface HistoryCellViewModel : RVMViewModel

- (id)initWithConsumption:(DrinkConsumption *)consumption;

@property (readonly) NSString *title;
@property (readonly) NSString *subtitle;

@property (readonly) DrinkConsumption *consumption;

@end
