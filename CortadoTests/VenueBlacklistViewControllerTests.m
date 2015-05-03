#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "DataStore.h"
#import "FoursquareVenue.h"

#import "VenueBlacklistViewController.h"

SpecBegin(VenueBlacklistViewController)

__block DataStore *dataStore;
__block VenueBlacklistViewController *subject;

__block FoursquareVenue *venue1;
__block FoursquareVenue *venue2;

before(^{
    [DataStore eraseStoredData];
    dataStore = [[DataStore alloc] init];
    subject = [[VenueBlacklistViewController alloc] initWithDataStore:dataStore];
    [subject viewDidLoad];

    venue1 = [[FoursquareVenue alloc] init];
    venue1.name = @"Momofuku Milk Bar";
    venue1.address = @"247 E 13th St";
    venue1.crossStreet = @"at 2nd Ave";

    venue2 = [[FoursquareVenue alloc] init];
    venue2.name = @"Domofuku Silk Bar";
    venue2.address = @"208 E 13th St";
    venue2.crossStreet = @"at 3rd Ave";
});

after(^{
    [DataStore eraseStoredData];
});

describe(@"listing blacklisted venues", ^{
    context(@"when nothing has been blacklisted", ^{
        it(@"should not show the section", ^{
            expect([subject numberOfSectionsInTableView:subject.tableView]).to.equal(1);
        });
    });

    context(@"when a venue has been blacklisted", ^{
        it(@"should show the blacklisted section", ^{
            [dataStore blacklistVenue:venue1];
            expect([subject numberOfSectionsInTableView:subject.tableView]).to.equal(2);
        });

        it(@"should show the correct blacklisted items", ^{
            [dataStore blacklistVenue:venue2];

            expect([subject tableView:subject.tableView numberOfRowsInSection:VenueBlacklistSectionBlacklisted]).to.equal(1);

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:VenueBlacklistSectionBlacklisted];
            UITableViewCell *cell = [subject tableView:subject.tableView cellForRowAtIndexPath:indexPath];
            [subject tableView:subject.tableView willDisplayCell:cell forRowAtIndexPath:indexPath];

            expect(cell.textLabel.text).to.equal(@"Domofuku Silk Bar");
            expect(cell.detailTextLabel.text).to.equal(@"208 E 13th St (at 3rd Ave)");


        });
    });
});

describe(@"listing all venues", ^{
    context(@"when there are no venues", ^{
        it(@"should show an empty state", ^{
            expect([subject tableView:subject.tableView numberOfRowsInSection:VenueBlacklistSectionHistory]).to.equal(1);
        });
    });

    context(@"when there are venues", ^{
        before(^{
            [dataStore addVenue:venue1];
            [dataStore addVenue:venue2];
        });

        it(@"should show a list of all venues", ^{
            expect([subject tableView:subject.tableView numberOfRowsInSection:VenueBlacklistSectionHistory]).to.equal(2);
        });

        it(@"should sort the venues", ^{
            NSIndexPath *first = [NSIndexPath indexPathForRow:0 inSection:VenueBlacklistSectionHistory];
            UITableViewCell *firstCell = [subject tableView:subject.tableView cellForRowAtIndexPath:first];
            [subject tableView:subject.tableView willDisplayCell:firstCell forRowAtIndexPath:first];

            NSIndexPath *second = [NSIndexPath indexPathForRow:1 inSection:VenueBlacklistSectionHistory];
            UITableViewCell *secondCell = [subject tableView:subject.tableView cellForRowAtIndexPath:second];
            [subject tableView:subject.tableView willDisplayCell:secondCell forRowAtIndexPath:second];

            expect(firstCell.textLabel.text).to.equal(@"Domofuku Silk Bar");
            expect(firstCell.detailTextLabel.text).to.equal(@"208 E 13th St (at 3rd Ave)");

            expect(secondCell.textLabel.text).to.equal(@"Momofuku Milk Bar");
            expect(secondCell.detailTextLabel.text).to.equal(@"247 E 13th St (at 2nd Ave)");
        });
    });

});



SpecEnd