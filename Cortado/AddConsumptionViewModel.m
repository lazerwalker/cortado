@import CoreLocation;

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "MapAnnotation.h"
#import "Drink.h"
#import "DrinkConsumption.h"
#import "DrinkCellViewModel.h"

#import "AddConsumptionViewModel.h"

@interface AddConsumptionViewModel ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (readwrite) DrinkCellViewModel *drinkCellViewModel;

@property (readonly, nonatomic, strong) CLLocation *location;

@end

@implementation AddConsumptionViewModel

- (id)init {
    self = [super init];
    if (!self) return nil;

    _completedSignal = [RACSubject subject];

    self.timestamp = NSDate.date;

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;


    RAC(self, drinkCellViewModel) = [RACObserve(self, drink) map:^id(Drink *drink) {
        return [[DrinkCellViewModel alloc] initWithDrink:drink];
    }];
    
    return self;
}

- (id)initWithPreferredDrink:(Drink *)drink
                    location:(CLLocation *)location {

    self = [self init];
    if (!self) return nil;

    self.drink = drink;
    _location = location;

    RAC(self, coordinateString) = [RACObserve(self, location) map:^id(CLLocation *location) {
        return [NSString stringWithFormat:@"%@,%@", @(location.coordinate.latitude), @(location.coordinate.longitude)];
    }];

    return self;
}

- (id)initWithConsumption:(DrinkConsumption *)consumption {
    self = [self init];

    self.timestamp = consumption.timestamp;
    self.drink = consumption.drink;
    self.venue = consumption.venue;
    self.coordinateString = consumption.coordinateString;

    return self;
}

- (id)initWithConsumption:(DrinkConsumption *)consumption editing:(BOOL)editing {
    self = [self initWithConsumption:consumption];

    _isEditing = editing;

    return self;
}

#pragma mark - KVO
+ (NSSet *)keyPathsForValuesAffectingTimeString {
    return [NSSet setWithObject:@keypath(AddConsumptionViewModel.new, timestamp)];
}

+ (NSSet *)keyPathsForValuesAffectingInputValid {
    return [NSSet setWithObject:@keypath(AddConsumptionViewModel.new, drink)];
}

+ (NSSet *)keyPathsForValuesAffectingMapAnnotation {
    return [NSSet setWithObject:@keypath(AddConsumptionViewModel.new, coordinateString)];
}

#pragma mark - Data accessors
- (NSString *)timeString {
    return [self.dateFormatter stringFromDate:self.timestamp];
}

- (NSString *)drinkTitle {
    return @"Drink";
}

- (NSString *)timestampTitle {
    return @"Time";
}

- (NSString *)venueTitle {
    return (self.venue ? @"Coffee Shop" : nil);
}

- (MapAnnotation *)mapAnnotation {
    if (!self.coordinateString) return nil;

    CLLocationCoordinate2D coordinate;
    if (self.location) {
        coordinate = self.location.coordinate;
    } else {
        NSArray *values = [self.coordinateString componentsSeparatedByString:@","];
        if (values.count != 2) return nil;

        CLLocationDegrees lat = [values.firstObject doubleValue];
        CLLocationDegrees lng = [values.lastObject doubleValue];
        coordinate = CLLocationCoordinate2DMake(lat, lng);
    }

    return [[MapAnnotation alloc] initWithCoordinate:coordinate title:self.venue];
}


- (BOOL)inputValid {
    return self.drink != nil;
}

#pragma mark - Event handlers
- (void)addDrink {
    DrinkConsumption *consumption = [[DrinkConsumption alloc] initWithDrink:self.drink
                                                                  timestamp:self.timestamp
                                                                      venue:self.venue
                                                                 coordinate:self.coordinateString];
    [self.completedSignal sendNext:consumption];
    [self.completedSignal sendCompleted];
}

- (void)cancel {
    [self.completedSignal sendCompleted];
}

@end
