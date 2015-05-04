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
__block id application;

before(^{
    id client = OCMClassMock(FoursquareClient.class);
    DataStore *dataStore = OCMPartialMock([[DataStore alloc] init]);
    subject = [[LocationDetector alloc] initWithFoursquareClient:client
                                                       dataStore:dataStore];
    application = OCMClassMock(UIApplication.class);
    subject.application = application;
});

describe(@"adding a location", ^{
    context(@"when a coffee shop exists", ^{
        it(@"should tell the data store", ^{
            FoursquareVenue *venue = [[FoursquareVenue alloc] init];
            venue.name = @"Dunkin Donuts";
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(10.0, 10.0);

            OCMStub([subject.client fetchVenuesOfCategory:[OCMArg any] nearCoordinate:coordinate]).andReturn([RACSignal return:venue]);

            [subject checkForCoordinate:coordinate];

            OCMVerify([subject.dataStore addVenue:venue]);
        });
    });
});

describe(@"venue blacklisting", ^{
    before(^{
        [DataStore eraseStoredData];
    });

    after(^{
        [DataStore eraseStoredData];
    });

    context(@"when a venue is blacklisted", ^{
        it(@"should not trigger a push notification", ^{
            FoursquareVenue *venue = [[FoursquareVenue alloc] init];
            venue.name = @"Dunkin Donuts";
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(10.0, 10.0);

            [subject.dataStore blacklistVenue:venue];

            OCMStub([subject.client fetchVenuesOfCategory:[OCMArg any] nearCoordinate:coordinate]).andReturn([RACSignal return:venue]);

            [[application reject] scheduleLocalNotification:[OCMArg any]];
            [subject checkForCoordinate:coordinate];
            OCMVerifyAll(application);
        });
    });

    context(@"when a venue is not blacklisted", ^{
        it(@"should trigger a push notification", ^{
            FoursquareVenue *venue = [[FoursquareVenue alloc] init];
            venue.name = @"Dunkin Donuts";
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(10.0, 10.0);

            OCMStub([subject.client fetchVenuesOfCategory:[OCMArg any] nearCoordinate:coordinate]).andReturn([RACSignal return:venue]);

            [subject checkForCoordinate:coordinate];
            OCMVerify([application scheduleLocalNotification:[OCMArg any]]);
        });
    });

});


SpecEnd