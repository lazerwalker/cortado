@import Foundation;
@import UIKit;

@class Beverage;

@interface AppInterface : NSObject

- (void)saveBeverage:(Beverage *)beverage
          completion:(void (^)())completionBlock;

@end
