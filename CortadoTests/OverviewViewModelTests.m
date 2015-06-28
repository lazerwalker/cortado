#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>
#import <OCMock/OCMock.h>

#import "DataStore.h"
#import "DrinkConsumption.h"

#import "OverviewViewModel.h"

SpecBegin(OverviewViewModel)

__block DataStore *dataStore;
__block OverviewViewModel *viewModel;

fdescribe(@"calculating the overall average", ^{
    before(^{
        [DataStore eraseStoredData];

        dataStore = [[DataStore alloc] initWithHealthKitManager:nil];
        viewModel = [[OverviewViewModel alloc] initWithDataStore:dataStore];
    });

    after(^{
        [DataStore eraseStoredData];
    });

    context(@"when there is only one day of data", ^{
        before(^{
            DrinkConsumption *consumption1 = [[DrinkConsumption alloc] initWithDrink:nil timestamp:NSDate.date];
            DrinkConsumption *consumption2 = [[DrinkConsumption alloc] initWithDrink:nil timestamp:NSDate.date];
            [dataStore addDrinkImmediately:consumption1];
            [dataStore addDrinkImmediately:consumption2];
        });

        it(@"should show that day's caffeine consumption", ^{
            expect(viewModel.averageCount).to.equal(@"2");
        });
    });

    context(@"when there are two consecutive days of data", ^{
        before(^{
            NSCalendar *calendar = NSCalendar.currentCalendar;

            NSDate *date1 = NSDate.date;
            NSDate *date2 = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:NSDate.date options:0];
            DrinkConsumption *consumption1 = [[DrinkConsumption alloc] initWithDrink:nil timestamp:date1];
            DrinkConsumption *consumption2 = [[DrinkConsumption alloc] initWithDrink:nil timestamp:date2];

            [dataStore addDrinkImmediately:consumption1];
            [dataStore addDrinkImmediately:consumption2];
        });

        it(@"should show the proper average", ^{
            expect(viewModel.averageCount).to.equal(@"1");
        });
    });

    context(@"when there are two non-consecutive days of data", ^{
        before(^{
            NSCalendar *calendar = NSCalendar.currentCalendar;

            NSDate *date1 = NSDate.date;
            NSDate *date2 = [calendar dateByAddingUnit:NSCalendarUnitDay value:2 toDate:NSDate.date options:0];
            DrinkConsumption *consumption1 = [[DrinkConsumption alloc] initWithDrink:nil timestamp:date1];
            DrinkConsumption *consumption2 = [[DrinkConsumption alloc] initWithDrink:nil timestamp:date2];

            [dataStore addDrinkImmediately:consumption1];
            [dataStore addDrinkImmediately:consumption2];
        });

        it(@"should show the proper average, including days with 0 consumption", ^{
            expect(viewModel.averageCount).to.equal(@"0-1");
        });
    });

});
SpecEnd
