@import Foundation;

typedef void (^FTUEAuthorizationBlock)();

@class RACSubject;

@protocol FTUEScreen <NSObject>

- (RACSubject *)completed;

@end
