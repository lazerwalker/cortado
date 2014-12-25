@import Foundation;

@class DrinkConsumption;
@class RACSignal;

@interface CaffeineHistoryManager : NSObject

@property (readonly) BOOL isAuthorized;

- (RACSignal *)processDrink:(DrinkConsumption *)drink;

// TODO: Remove? Only used by today extension
- (void)processDrinks:(NSArray *)array;

- (RACSignal *)fetchHistory;

@end
