#import <CoreLocation/CoreLocation.h>

#import "Drink.h"

#import "DrinkConsumption.h"

@implementation DrinkConsumption

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"timestamp": NSNull.null,
             @"caffeine": NSNull.null,
             @"name": @"Name",
             @"subtype": @"Subtype",
             @"venue": @"Venue",
             @"coordinateString": @"Coordinates"
            };
}

#pragma mark -

- (id)initWithDrink:(Drink *)drink
          timestamp:(NSDate *)timestamp
              venue:(NSString *)venue
         coordinate:(NSString *)coordinate {
    self = [super init];
    if (!self) return nil;

    _name = drink.name;
    _subtype = drink.subtype;
    _caffeine = drink.caffeine;
    _timestamp = timestamp;
    _venue = venue;
    _coordinateString = coordinate;

    return self;
}

- (id)initWithDrink:(Drink *)drink {
    return [self initWithDrink:drink
                     timestamp:NSDate.date
                         venue:nil
                    coordinate:nil];
}

- (id)initWithDrink:(Drink *)drink
          timestamp:(NSDate *)timestamp {
    return [self initWithDrink:drink
                     timestamp:timestamp
                         venue:nil
                    coordinate:nil];
}

- (CLLocationCoordinate2D)coordinate {
    NSArray *strings = [self.coordinateString componentsSeparatedByString:@","];
    if (strings.count != 2) { return CLLocationCoordinate2DMake(0, 0); }

    CLLocationDegrees lat = [strings.firstObject floatValue];
    CLLocationDegrees lng = [strings.lastObject floatValue];
    return CLLocationCoordinate2DMake(lat, lng);
}

@end
