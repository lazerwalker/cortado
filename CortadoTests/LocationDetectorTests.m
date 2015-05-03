#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "DataStore.h"
#import "FoursquareClient.h"
#import "FoursquareVenue.h"

#import "LocationDetector.h"

SpecBegin(LocationDetector)

__block LocationDetector *subject;

before(^{
    id client = OCMClassMock(FoursquareClient.class);
    id dataStore = OCMClassMock(DataStore.class);
    subject = [[LocationDetector alloc] initWithFoursquareClient:client
               dataStore:dataStore];
});

describe(@"adding a location", ^{
    context(@"when a coffee shop exists", ^{
        it(@"should tell the data store", ^{

        });
    });
});


SpecEnd