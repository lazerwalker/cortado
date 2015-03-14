#import <ReactiveViewModel/RVMViewModel.h>

@class Drink;
@class DrinkConsumption;
@class DrinkCellViewModel;
@class RACSubject;

@interface AddConsumptionViewModel : RVMViewModel

@property (nonatomic, strong) Drink *drink;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *venue;
@property (nonatomic, strong) NSString *coordinateString;

@property (nonatomic, assign) BOOL isEditing;

@property (readonly) NSString *timeString;
@property (readonly) BOOL inputValid;
@property (readonly) DrinkCellViewModel *drinkCellViewModel;

@property (readonly) RACSubject *completedSignal;

- (id)initWithConsumption:(DrinkConsumption *)consumption;
- (id)initWithConsumption:(DrinkConsumption *)consumption
                  editing:(BOOL)editing;

- (void)addDrink;
- (void)cancel;

- (NSString *)drinkTitle;
- (NSString *)timestampTitle;
- (NSString *)venueTitle;

@end
