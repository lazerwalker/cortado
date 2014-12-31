#import <ReactiveViewModel/RVMViewModel.h>

@class Drink;
@class DrinkConsumption;
@class DrinkCellViewModel;
@class RACSubject;

@interface AddConsumptionViewModel : RVMViewModel

@property (nonatomic, strong) Drink *drink;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *venue;

@property (readonly) NSString *timeString;
@property (readonly) BOOL inputValid;
@property (readonly) DrinkCellViewModel *drinkCellViewModel;

@property (readonly) RACSubject *completedSignal;

- (id)initWithConsumption:(DrinkConsumption *)consumption;

- (void)addDrink;
- (void)cancel;

- (NSString *)drinkTitle;
- (NSString *)timestampTitle;

@end
