#import "RVMViewModel.h"

@class AddConsumptionViewModel;
@class DrinkConsumption;
@class DataStore;
@class HistoryCellViewModel;

@interface HistoryViewModel : RVMViewModel

- (id)initWithDataStore:(DataStore *)dataStore;

@property (readonly, nonatomic, strong) DataStore *dataStore;
@property (readonly) NSInteger numberOfSections;
@property (readonly) NSArray *drinks;

- (BOOL)shouldPromptForLocation;
- (BOOL)shouldPromptForHealthKit;
- (void)authorizeLocation;

- (AddConsumptionViewModel *)editViewModelAtIndexPath:(NSIndexPath *)indexPath;
- (HistoryCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)dateStringForSection:(NSInteger)section;

#pragma mark - Actions
- (RACSignal *)deleteAtIndexPath:(NSIndexPath *)indexPath;
- (RACSignal *)addDrink:(DrinkConsumption *)drink;
- (RACSignal *)editDrinkAtIndexPath:(NSIndexPath *)indexPath to:(DrinkConsumption *)to;

@end
