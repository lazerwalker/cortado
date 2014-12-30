#import <CoreLocation/CoreLocation.h>
#import <Mantle/Mantle.h>

@class CLLocation;

@class Drink;

@interface DrinkConsumption : MTLModel<MTLJSONSerializing>

@property (readonly, strong, nonatomic) NSString *name;
@property (readonly, strong, nonatomic) NSString *subtype;
@property (readonly, strong, nonatomic) NSNumber *caffeine;

@property (readonly, strong, nonatomic) NSDate *timestamp;
@property (readonly, strong, nonatomic) NSString *venue;
@property (readonly, strong, nonatomic) NSString *coordinateString; //@"lat,lng"

@property (readonly) CLLocationCoordinate2D coordinate;

- (id)initWithDrink:(Drink *)drink
          timestamp:(NSDate *)timestamp
              venue:(NSString *)venue
         coordinate:(NSString *)coordinate NS_DESIGNATED_INITIALIZER;

- (id)initWithDrink:(Drink *)drink;

- (id)initWithDrink:(Drink *)drink
          timestamp:(NSDate *)timestamp;

@end
