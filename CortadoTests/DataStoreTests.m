#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "Drink.h"
#import "DrinkConsumption.h"
#import "HealthKitManager.h"

#import "DataStore.h"

SpecBegin(DataStore)

__block DataStore *subject;

before(^{
    [DataStore eraseStoredData];

    id manager = OCMClassMock(HealthKitManager.class);
    subject = [[DataStore alloc] initWithHealthKitManager:manager];
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
    it(@"should add to the current store", ^{

    });

    it(@"should persist for new stores", ^{

    });
});

describe(@"editing a drink", ^{
    it(@"should add to the current store", ^{

    });

    it(@"should persist for new stores", ^{
        
    });

    it(@"should save to HealthKit", ^{

    });
});


SpecEnd