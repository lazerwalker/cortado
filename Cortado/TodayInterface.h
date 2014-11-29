@import Foundation;

@interface TodayInterface : NSObject

- (void)stopListening;
- (void)processAllNewBeveragesWithCompletion:(void (^)(NSArray *addedItems))completion;

@end
