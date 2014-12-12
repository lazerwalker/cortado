#import <Mantle/Mantle.h>

@interface Beverage : MTLModel

@property (readonly, strong, nonatomic) NSString *name;
@property (readonly, strong, nonatomic) NSNumber *caffeine; // in mg

- (id)initWithName:(NSString *)name
          caffeine:(NSNumber *)caffeine;

@end
