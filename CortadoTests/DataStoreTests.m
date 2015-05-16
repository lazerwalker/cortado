#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "Drink.h"
#import "DrinkConsumption.h"
#import "FoursquareVenue.h"
#import "HealthKitManager.h"

#import "DataStore.h"

SpecBegin(DataStore)

__block DataStore *subject;

before(^{
    [DataStore eraseStoredData];

    id manager = OCMClassMock(HealthKitManager.class);
    subject = [[DataStore alloc] initWithHealthKitManager:manager];
});

describe(@"blacklisting a venue", ^{
    __block FoursquareVenue *venue1 = [[FoursquareVenue alloc] init];
    __block FoursquareVenue *venue2 = [[FoursquareVenue alloc] init];

    before(^{
        venue1.name = @"Venue 1";
        venue2.name = @"Venue 2";
    });

    it(@"should add to the list", ^{
        [subject blacklistVenue:venue1];
        [subject blacklistVenue:venue2];

        expect(subject.blacklistedVenues).to.haveACountOf(2);
        expect(subject.blacklistedVenues).to.contain(venue1);
        expect(subject.blacklistedVenues).to.contain(venue2);
    });

    it(@"should persist to disk", ^{
        [subject blacklistVenue:venue1];
        [subject blacklistVenue:venue2];

        DataStore *newStore = [[DataStore alloc] initWithHealthKitManager:nil];
        expect(newStore.blacklistedVenues).to.haveACountOf(2);
    });

    context(@"unblacklisting a venue", ^{
        it(@"should remove from the list", ^{
            [subject blacklistVenue:venue1];
            [subject blacklistVenue:venue2];

            expect(subject.blacklistedVenues).to.haveACountOf(2);

            [subject unblacklistVenue:venue1];
            expect(subject.blacklistedVenues).to.haveACountOf(1);
            expect(subject.blacklistedVenues).notTo.contain(venue1);
        });

        it(@"should persist to disk", ^{
            [subject blacklistVenue:venue1];
            [subject blacklistVenue:venue2];
            [subject unblacklistVenue:venue1];

            DataStore *newStore = [[DataStore alloc] initWithHealthKitManager:nil];
            expect(newStore.blacklistedVenues).to.haveACountOf(1);
        });
    });
});

describe(@"blacklisting all Starbucks", ^{
    it(@"should persist to disk", ^{
        subject.ignoreAllStarbucks = YES;;

        DataStore *newStore = [[DataStore alloc] initWithHealthKitManager:nil];
        expect(newStore.ignoreAllStarbucks).to.beTruthy();

        newStore.ignoreAllStarbucks = NO;

        DataStore *newNewStore = [[DataStore alloc] initWithHealthKitManager:nil];
        expect(newNewStore.ignoreAllStarbucks).to.beFalsy();

    });
});

describe(@"adding a location", ^{
    __block FoursquareVenue *venue1 = [[FoursquareVenue alloc] init];
    __block FoursquareVenue *venue2 = [[FoursquareVenue alloc] init];

    before(^{
        venue1.name = @"Venue 1";
        venue2.name = @"Venue 2";

        [subject addVenue:venue1];
        [subject addVenue:venue2];
    });

    it(@"should add to the front of list", ^{
        expect(subject.venueHistory).to.haveACountOf(2);
        expect([subject.venueHistory.firstObject name]).to.equal(@"Venue 2");
    });

    it(@"should move existing entries to the front", ^{
        expect([subject.venueHistory.firstObject name]).to.equal(@"Venue 2");

        [subject addVenue:venue1];

        expect(subject.venueHistory).to.haveACountOf(2);
        expect([subject.venueHistory.firstObject name]).to.equal(@"Venue 1");
    });

    it(@"should persist to disk", ^{
        DataStore *newStore = [[DataStore alloc] initWithHealthKitManager:nil];
        expect(newStore.venueHistory).to.haveACountOf(2);
        expect([newStore.venueHistory.firstObject name]).to.equal(@"Venue 2");
    });
});

describe(@"importing from HealthKit", ^{
    it(@"should return the drinks in the signal", ^{
        DrinkConsumption *first = [DrinkConsumption new];
        DrinkConsumption *second = [DrinkConsumption new];
        RACSignal *signal = @[first, second].rac_sequence.signal;
        OCMStub([subject.healthKitManager fetchHistory]).andReturn(signal);

        waitUntil(^(DoneCallback done) {
            [[subject importFromHealthKit] subscribeNext:^(NSArray *drinks) {
                expect(drinks).to.equal(@[first, second]);
                done();
            }];
        });
    });

    it(@"should replace its internal data", ^{
        [subject addDrinkImmediately:[DrinkConsumption new]];

        DrinkConsumption *first = [DrinkConsumption new];
        DrinkConsumption *second = [DrinkConsumption new];
        RACSignal *signal = @[first, second].rac_sequence.signal;
        OCMStub([subject.healthKitManager fetchHistory]).andReturn(signal);

        waitUntil(^(DoneCallback done) {
            [[subject importFromHealthKit] subscribeCompleted:^{
                expect(subject.drinks).to.equal(@[first, second]);
                done();
            }];
        });
    });
});

describe(@"adding a new drink", ^{
    context(@"when adding immediately", ^{
        it(@"should add to the current store", ^{
            DrinkConsumption *drink = [DrinkConsumption new];
            [subject addDrinkImmediately:drink];
            expect(subject.drinks).to.contain(drink);
        });

        it(@"should persist for new stores", ^{
            Drink *drink = [[Drink alloc] initWithName:@"Hot Cocoa" caffeine:@20];
            DrinkConsumption *consumption = [[DrinkConsumption alloc] initWithDrink:drink];
            [subject addDrinkImmediately:consumption];

            DataStore *newStore = [[DataStore alloc] initWithHealthKitManager:nil];

            DrinkConsumption *c = newStore.drinks.lastObject;
            expect(c.name).to.equal(@"Hot Cocoa");
        });

        it(@"should save to HealthKit", ^{
            DrinkConsumption *drink = [DrinkConsumption new];
            [subject addDrinkImmediately:drink];

            OCMVerify([subject.healthKitManager addDrink:drink]);
        });
    });

    context(@"when using a signal", ^{
        it(@"should add to the current store", ^{
            waitUntil(^(DoneCallback done) {
                OCMStub([subject.healthKitManager addDrink:[OCMArg any]]).andReturn([RACSignal empty]);

                DrinkConsumption *drink = [DrinkConsumption new];
                [[subject addDrink:drink] subscribeCompleted:^{
                    expect(subject.drinks).to.contain(drink);
                    done();
                }];
            });
        });

        it(@"should persist for new stores", ^{
            waitUntil(^(DoneCallback done) {
                Drink *drink = [[Drink alloc] initWithName:@"Mexican Hot Chocolate" caffeine:@30];
                DrinkConsumption *consumption = [[DrinkConsumption alloc] initWithDrink:drink];

                OCMStub([subject.healthKitManager addDrink:[OCMArg any]]).andReturn([RACSignal empty]);

                [[subject addDrink:consumption] subscribeCompleted:^{
                    DataStore *newStore = [[DataStore alloc] initWithHealthKitManager:nil];
                    DrinkConsumption *c = newStore.drinks.lastObject;
                    expect(c.name).to.equal(@"Mexican Hot Chocolate");
                    done();
                }];
            });
        });

        it(@"should save to HealthKit", ^{
            OCMStub([subject.healthKitManager addDrink:[OCMArg any]]).andReturn([RACSignal empty]);

            waitUntil(^(DoneCallback done) {
                DrinkConsumption *drink = [DrinkConsumption new];
                [[subject addDrink:drink] subscribeCompleted:^{
                    OCMVerify([subject.healthKitManager addDrink:drink]);
                    done();
                }];
            });
        });

        it(@"should pass through an error", ^{
            NSError *error = [NSError new];

            waitUntil(^(DoneCallback done) {
                OCMStub([subject.healthKitManager addDrink:[OCMArg any]]).andReturn([RACSignal error:error]);

                DrinkConsumption *drink = [DrinkConsumption new];
                [[subject addDrink:drink] subscribeError:^(NSError *e) {
                    expect(e).to.equal(error);
                    done();
                } completed:^{
                    failure(@"Did not send error signal");
                    done();
                }];
            });
        });
    });
});

describe(@"removing a drink", ^{
    it(@"should remove from the current store", ^{
        waitUntil(^(DoneCallback done) {
            DrinkConsumption *drink = [[DrinkConsumption alloc] initWithDrink:
                                       [[Drink alloc] initWithName:@"Foo" caffeine:@10]];
            DrinkConsumption *drink2 = [[DrinkConsumption alloc] initWithDrink:
                                       [[Drink alloc] initWithName:@"Bar" caffeine:@20]];

            [subject addDrinkImmediately:drink];
            [subject addDrinkImmediately:drink2];
            expect(subject.drinks).to.haveACountOf(2);

            OCMStub([subject.healthKitManager deleteDrink:[OCMArg any]]).andReturn([RACSignal empty]);

            [[subject deleteDrink:drink] subscribeCompleted:^{
                expect(subject.drinks).to.haveACountOf(1);
                expect(subject.drinks.firstObject).to.equal(drink2);
                done();
            }];
        });
    });

    it(@"should persist for new stores", ^{
        waitUntil(^(DoneCallback done) {
            DrinkConsumption *drink = [[DrinkConsumption alloc] initWithDrink:
                                       [[Drink alloc] initWithName:@"Foo" caffeine:@10]];
            DrinkConsumption *drink2 = [[DrinkConsumption alloc] initWithDrink:
                                        [[Drink alloc] initWithName:@"Bar" caffeine:@20]];

            [subject addDrinkImmediately:drink];
            [subject addDrinkImmediately:drink2];
            expect(subject.drinks).to.haveACountOf(2);

            OCMStub([subject.healthKitManager deleteDrink:[OCMArg any]]).andReturn([RACSignal empty]);

            [[subject deleteDrink:drink] subscribeCompleted:^{
                DataStore *newStore = [[DataStore alloc] initWithHealthKitManager:nil];

                expect(newStore.drinks).to.haveACountOf(1);
                expect([newStore.drinks.firstObject name]).to.equal(@"Bar");
                done();
            }];
        });
    });

    it(@"should remove from HealthKit", ^{
        OCMStub([subject.healthKitManager deleteDrink:[OCMArg any]]).andReturn([RACSignal empty]);

        waitUntil(^(DoneCallback done) {
            DrinkConsumption *drink = [DrinkConsumption new];
            [[subject deleteDrink:drink] subscribeCompleted:^{
                OCMVerify([subject.healthKitManager deleteDrink:drink]);
                done();
            }];
        });
    });

    it(@"should pass through an error", ^{
        NSError *error = [NSError new];

        waitUntil(^(DoneCallback done) {
            OCMStub([subject.healthKitManager deleteDrink:[OCMArg any]]).andReturn([RACSignal error:error]);

            DrinkConsumption *drink = [DrinkConsumption new];
            [[subject deleteDrink:drink] subscribeError:^(NSError *e) {
                expect(e).to.equal(error);
                done();
            } completed:^{
                failure(@"Did not send error signal");
                done();
            }];
        });

    });

});

describe(@"editing a drink", ^{
    it(@"should edit in the current store", ^{
        waitUntil(^(DoneCallback done) {
            DrinkConsumption *drink = [[DrinkConsumption alloc] initWithDrink:
                                       [[Drink alloc] initWithName:@"Single-Shot Espresso" caffeine:@75]];
            [subject addDrinkImmediately:drink];

            DrinkConsumption *newDrink = [[DrinkConsumption alloc] initWithDrink:
                                          [[Drink alloc] initWithName:@"Double-Shot Espresso" caffeine:@150]];

            OCMStub([subject.healthKitManager editDrink:[OCMArg any] toDrink:[OCMArg any]]).andReturn([RACSignal empty]);

            [[subject editDrink:drink toDrink:newDrink] subscribeCompleted:^{
                DrinkConsumption *d = subject.drinks.firstObject;
                expect(d.name).to.equal(@"Double-Shot Espresso");
                done();
            }];
        });
    });

    it(@"should persist for new stores", ^{
        waitUntil(^(DoneCallback done) {
            DrinkConsumption *drink = [[DrinkConsumption alloc] initWithDrink:
                                       [[Drink alloc] initWithName:@"Single-Shot Espresso" caffeine:@75]];
            [subject addDrinkImmediately:drink];

            DrinkConsumption *newDrink = [[DrinkConsumption alloc] initWithDrink:
                                          [[Drink alloc] initWithName:@"Double-Shot Espresso" caffeine:@150]];

            OCMStub([subject.healthKitManager editDrink:[OCMArg any] toDrink:[OCMArg any]]).andReturn([RACSignal empty]);

            [[subject editDrink:drink toDrink:newDrink] subscribeCompleted:^{
                DataStore *newStore = [[DataStore alloc] initWithHealthKitManager:nil];
                DrinkConsumption *d = newStore.drinks.firstObject;
                expect(d.name).to.equal(@"Double-Shot Espresso");
                done();
            }];
        });
    });
});


SpecEnd