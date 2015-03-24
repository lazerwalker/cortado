#import <Mantle/Mantle.h>

@interface DrinkType : MTLModel<MTLJSONSerializing>

@property (readonly, nonatomic, strong) NSString *name;
@property (readonly, nonatomic, strong) NSArray *subtypes;

@end
