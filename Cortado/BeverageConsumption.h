#import <Mantle/Mantle.h>

@class Beverage;

@interface BeverageConsumption : MTLModel

@property (readonly, strong, nonatomic) NSString *name;
@property (readonly, strong, nonatomic) NSNumber *caffeine;
@property (readonly, strong, nonatomic) NSDate *timestamp;

- (id)initWithBeverage:(Beverage *)beverage
             timestamp:(NSDate *)timestamp NS_DESIGNATED_INITIALIZER;

- (id)initWithBeverage:(Beverage *)beverage;

@end
