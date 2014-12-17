@import Foundation;

@class DrinkConsumption;

@interface CaffeineHistoryManager : NSObject

- (void)processDrinks:(NSArray *)array;

- (void)processDrink:(DrinkConsumption *)array
         withCompletion:(void(^)(BOOL success, NSError *error))completion;

@end
