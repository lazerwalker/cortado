@import Foundation;

@class DrinkConsumption;

@interface DrinkProcessor : NSObject

- (void)processDrinks:(NSArray *)array;

- (void)processDrink:(DrinkConsumption *)array
         withCompletion:(void(^)(BOOL success, NSError *error))completion;

@end
