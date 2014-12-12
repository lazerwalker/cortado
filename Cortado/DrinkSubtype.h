#import <Mantle/Mantle.h>

@interface DrinkSubtype : MTLModel<MTLJSONSerializing>

@property (readonly, nonatomic, strong) NSString *name;
@property (readonly, nonatomic, strong) NSNumber *caffeine;

@end
