#import "RVMViewModel.h"

@class CaffeineHistoryManager;
@class DrinkConsumption;

@interface HistoryViewModel : RVMViewModel

- (id)initWithCaffeineHistoryManager:(CaffeineHistoryManager *)manager;

@property (readonly, nonatomic, strong) CaffeineHistoryManager *manager;
@property (readonly) NSInteger numberOfRows;
@property (readonly) NSArray *drinks;

- (void)refetchHistory;

- (NSString *)titleAtIndex:(NSUInteger)index;
- (NSString *)subtitleAtIndex:(NSUInteger)index;
- (DrinkConsumption *)drinkAtIndex:(NSUInteger)index;

#pragma mark - Actions
- (void)deleteAtIndex:(NSUInteger)index;

@end
