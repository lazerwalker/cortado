#import "RVMViewModel.h"

@class AddConsumptionViewModel;
@class DrinkConsumption;
@class CaffeineHistoryManager;
@class HistoryCellViewModel;

@interface HistoryViewModel : RVMViewModel

- (id)initWithCaffeineHistoryManager:(CaffeineHistoryManager *)manager;

@property (readonly, nonatomic, strong) CaffeineHistoryManager *manager;
@property (readonly) NSInteger numberOfSections;
@property (readonly) NSArray *drinks;

- (void)refetchHistory;

// TODO: When history cells are a custom class, should just return a view model
- (NSString *)titleAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)subtitleAtIndexPath:(NSIndexPath *)indexPath;

- (AddConsumptionViewModel *)editViewModelAtIndexPath:(NSIndexPath *)indexPath;
- (HistoryCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)dateStringForSection:(NSInteger)section;

#pragma mark - Actions
- (RACSignal *)deleteAtIndexPath:(NSIndexPath *)indexPath;
- (RACSignal *)editDrinkAtIndexPath:(NSIndexPath *)indexPath to:(DrinkConsumption *)to;

@end
