@import Foundation;

@class DrinkProcessor;

@interface TodayInterface : NSObject

- (id)initWithProcessor:(DrinkProcessor*)processor;

@property (readonly, nonatomic) DrinkProcessor *processor;

- (void)stopListening;
- (void)processAllNewDrinksWithCompletion:(void (^)(NSArray *addedItems))completion;

@end
