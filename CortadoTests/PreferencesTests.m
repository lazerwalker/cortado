#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>

#import "Drink.h"

#import "Preferences.h"


SpecBegin(Preferences)

__block Drink *drink1, *drink2, *drink3;
__block NSArray *drinks;
__block Preferences *subject;

before(^{
    drink1 = [[Drink alloc] initWithName:@"Chai Tea" caffeine:@40];
    drink2 = [[Drink alloc] initWithName:@"Tai Chi" caffeine:@0];
    drink3 = [[Drink alloc] initWithName:@"Mai Tai" caffeine:@0];

    drinks = @[drink1, drink2];
    subject = [[Preferences alloc] initWithDrinks:drinks];
});

it(@"should initialize with the proper drinks", ^{
    expect(subject.drinks).to.equal(drinks);
});

it(@"should allow adding a drink", ^{
    Preferences *newPreferences = [subject preferencesByAddingDrink:drink3];
    expect(newPreferences.drinks).to.equal(@[drink1, drink2, drink3]);
});

it(@"should allow removing a drink", ^{
    Preferences *newPreferences = [subject preferencesByRemovingDrinkAtIndex:0];
    expect(newPreferences.drinks).to.equal(@[drink2]);
});


describe(@"reordering drinks", ^{
    it(@"should allow reordering drinks farther back", ^{
        subject = [subject preferencesByAddingDrink:drink3];
        Preferences *newPreferences = [subject preferencesByMovingDrinkAtIndex:0 toIndex:1];
        expect(newPreferences.drinks).to.equal(@[drink2, drink1, drink3]);
    });

    it(@"should allow reordering drinks farther forward", ^{
        subject = [subject preferencesByAddingDrink:drink3];
        Preferences *newPreferences = [subject preferencesByMovingDrinkAtIndex:2 toIndex:0];
        expect(newPreferences.drinks).to.equal(@[drink3, drink1, drink2]);
    });

    it(@"should do nothing for an identity move", ^{
        Preferences *newPreferences = [subject preferencesByMovingDrinkAtIndex:1 toIndex:1];
        expect(newPreferences.drinks).to.equal(subject.drinks);
    });
});

it(@"should allow replacing drinks", ^{
    Preferences *newPreferences = [subject preferencesByReplacingDrinkAtIndex:1 withDrink:drink3];
    expect (newPreferences.drinks).to.equal(@[drink1, drink3]);
});

SpecEnd