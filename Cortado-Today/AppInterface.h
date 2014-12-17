@import Foundation;
@import UIKit;

@class Drink;

@interface AppInterface : NSObject

- (void)saveDrink:(Drink *)drink
          completion:(void (^)())completionBlock;

@end
