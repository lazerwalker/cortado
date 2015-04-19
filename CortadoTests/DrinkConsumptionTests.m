//
//  CortadoTests.m
//  CortadoTests
//
//  Created by Mike Lazer-Walker on 4/18/15.
//  Copyright (c) 2015 Lazerwalker. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>
#import <OCMock/OCMock.h>

#import "Drink.h"

#import "DrinkConsumption.h"

SpecBegin(DrinkConsumption)

__block DrinkConsumption *subject;

describe(@"validity", ^{
    context(@"when the consumption is valid", ^{
        it(@"should be considered valid", ^{
            Drink *drink = [[Drink alloc] initWithName:@"Drink" caffeine:@150.0];
            subject = [[DrinkConsumption alloc] initWithDrink:drink timestamp:NSDate.date];

            expect(subject.isValid).to.beTruthy();
        });
    });

    context(@"when the consumption has no name", ^{
        it(@"should be invalid", ^{
            Drink *drink = [[Drink alloc] initWithName:nil caffeine:@150];
            subject = [[DrinkConsumption alloc] initWithDrink:drink];

            expect(subject.isValid).to.beFalsy();
        });
    });

    context(@"when the consumption has no date", ^{
        Drink *drink = [[Drink alloc] initWithName:@"Drink" caffeine:@150];
        subject = [[DrinkConsumption alloc] initWithDrink:drink timestamp:nil];

        expect(subject.isValid).to.beFalsy();
    });
});

describe(@"setting the coordinate from a string", ^{
    it(@"should have a valid CLLocationCoordinate2D property", ^{
        subject = [[DrinkConsumption alloc] initWithDrink:[Drink new] timestamp:NSDate.date venue:@"Coffee Shop" coordinate:@"40.7127,74.0059"];

        expect(subject.coordinate.latitude).to.beCloseTo(40.7127);
        expect(subject.coordinate.longitude).to.beCloseTo(74.0059);
    });
});

SpecEnd
