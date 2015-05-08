#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>
#import <OCMock/OCMock.h>

#import "Drink.h"
#import "DrinkConsumption.h"
#import "CoffeeShopNotification.h"

#import "DrinkConsumptionSerializer.h"

SpecBegin(DrinkConsumptionSerializer)

__block DrinkConsumption *subject;

describe(@"converting from an NSDictionary", ^{
    __block NSDate *timestamp;

    before(^{
        timestamp = NSDate.date;

        Drink *drink = [[Drink alloc] initWithName:@"Latte" subtype:@"Double Shot" caffeine:@150];

        NSDictionary *userInfo = @{
            @"timestamp": timestamp,
            @"venue": @"Ritual Roasters",
            @"latLng": @"37.75,-122.42",
            NotificationActionDrink: @{
                drink.identifier: @{
                    @"name": @"Latte",
                    @"subtype": @"Double Shot",
                    @"caffeine": @150
                }
            }
        };

        subject = [DrinkConsumptionSerializer consumptionFromUserInfo:userInfo identifier:drink.identifier];
    });

    it(@"should set the correct properties", ^{
        expect(subject.timestamp).to.equal(timestamp);
        expect(subject.venue).to.equal(@"Ritual Roasters");

        expect(subject.coordinate.latitude).to.beCloseTo(37.75);
        expect(subject.coordinate.longitude).to.beCloseTo(-122.42);
    });

    it(@"should properly set the drink", ^{
       expect(subject.drink.name).to.equal(@"Latte");
       expect(subject.drink.subtype).to.equal(@"Double Shot");
       expect(subject.drink.caffeine).to.equal(@150);
   });
});

describe(@"converting from a HealthKit sample", ^{
    __block NSDate *timestamp;

    before(^{
        timestamp = NSDate.date;
        
        HKUnit *mg = [HKUnit unitFromString:@"mg"];
        HKQuantity *quantity = [HKQuantity quantityWithUnit:mg doubleValue:75.0];
        HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];

        NSDictionary *metadata = @{
            @"Venue": @"Ritual Roasters",
            @"Coordinates": @"37.75,-122.42",
            @"Name": @"Latte",
            @"Subtype": @"Single Shot",
        };

        HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:timestamp endDate:timestamp metadata:metadata];

        subject = [DrinkConsumptionSerializer consumptionFromQuantitySample:sample];
    });

    it(@"should set the correct properties", ^{
        expect(subject.timestamp).to.equal(timestamp);
        expect(subject.venue).to.equal(@"Ritual Roasters");

        expect(subject.coordinate.latitude).to.beCloseTo(37.75);
        expect(subject.coordinate.longitude).to.beCloseTo(-122.42);
    });

    it(@"should properly set the drink", ^{
        expect(subject.drink.name).to.equal(@"Latte");
        expect(subject.drink.subtype).to.equal(@"Single Shot");
        expect(subject.drink.caffeine).to.equal(@75);
    });
});

SpecEnd