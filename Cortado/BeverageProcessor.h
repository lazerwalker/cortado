@import Foundation;

@interface BeverageProcessor : NSObject

- (void)processBeverages:(NSArray *)array;

- (void)processBeverage:(NSArray *)array
         withCompletion:(void(^)(BOOL success, NSError *error))completion;

@end
