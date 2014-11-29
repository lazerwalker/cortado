@import Foundation;

@class BeverageProcessor;

@interface TodayInterface : NSObject

- (id)initWithProcessor:(BeverageProcessor*)processor;

@property (readonly, nonatomic) BeverageProcessor *processor;

- (void)stopListening;
- (void)processAllNewBeveragesWithCompletion:(void (^)(NSArray *addedItems))completion;

@end
