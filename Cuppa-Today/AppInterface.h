@import Foundation;
@import UIKit;

@interface AppInterface : NSObject

- (void)saveBeverage:(NSString *)beverage
        withCaffeine:(CGFloat)caffeine
          completion:(void (^)())completionBlock;

@end
