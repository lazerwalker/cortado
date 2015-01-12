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

- (BOOL)shouldShowFTUE;
- (void)sawFTUE;

- (BOOL)shouldPromptForLocation;
- (BOOL)shouldPromptForHealthKit;
- (void)authorizeLocation;

- (void)refetchHistory;

- (AddConsumptionViewModel *)editViewModelAtIndexPath:(NSIndexPath *)indexPath;
- (HistoryCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)dateStringForSection:(NSInteger)section;

#pragma mark - Actions
- (RACSignal *)deleteAtIndexPath:(NSIndexPath *)indexPath;
- (RACSignal *)editDrinkAtIndexPath:(NSIndexPath *)indexPath to:(DrinkConsumption *)to;

@end
