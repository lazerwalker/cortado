@import Foundation;

@class CaffeineHistoryManager;

@interface TodayInterface : NSObject

- (id)initWithProcessor:(CaffeineHistoryManager*)processor;

@property (readonly, nonatomic) CaffeineHistoryManager *processor;

- (void)stopListening;
- (void)processAllNewDrinksWithCompletion:(void (^)(NSArray *addedItems))completion;

@end
