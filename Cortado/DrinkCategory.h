#import <Mantle/Mantle.h>

@interface DrinkCategory : MTLModel<MTLJSONSerializing>

@property (readonly, nonatomic, strong) NSString *name;
@property (readonly, nonatomic, strong) NSArray *drinkTypes;

@end
