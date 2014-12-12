@import Foundation;

@class BeverageConsumption;

@interface BeverageProcessor : NSObject

- (void)processBeverages:(NSArray *)array;

- (void)processBeverage:(BeverageConsumption *)array
         withCompletion:(void(^)(BOOL success, NSError *error))completion;

@end
