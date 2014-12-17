#import <Mantle/Mantle.h>

@class Drink;

@interface DrinkConsumption : MTLModel<MTLJSONSerializing>

@property (readonly, strong, nonatomic) NSString *name;
@property (readonly, strong, nonatomic) NSString *subtype;
@property (readonly, strong, nonatomic) NSNumber *caffeine;
@property (readonly, strong, nonatomic) NSDate *timestamp;

- (id)initWithDrink:(Drink *)drink
             timestamp:(NSDate *)timestamp NS_DESIGNATED_INITIALIZER;

- (id)initWithDrink:(Drink *)drink;

@end
