@import Foundation;

@class DrinkConsumption;
@class RACSignal;

@interface CaffeineHistoryManager : NSObject

@property (readonly) BOOL isAuthorized;

- (void)processDrinks:(NSArray *)array;

// TODO: Refactor to use RACSignal for consistency
- (void)processDrink:(DrinkConsumption *)array
         withCompletion:(void(^)(BOOL success, NSError *error))completion;

- (RACSignal *)fetchHistory;

@end
