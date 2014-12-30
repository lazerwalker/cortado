#import <ReactiveViewModel/RVMViewModel.h>

@class Drink;
@class RACSubject;

typedef NS_ENUM(NSInteger, AddConsumptionItem) {
    AddConsumptionItemDrink = 0,
    AddConsumptionItemDate,
    AddConsumptionItemCount
};

@interface AddConsumptionViewModel : RVMViewModel

@property (nonatomic, strong) Drink *drink;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *venue;

@property (readonly) RACSubject *completedSignal;

- (void)addDrink;
- (void)cancel;

- (NSString *)titleForItem:(AddConsumptionItem)item;
- (NSString *)valueForItem:(AddConsumptionItem)item;
- (NSInteger)numberOfItems;
@end
