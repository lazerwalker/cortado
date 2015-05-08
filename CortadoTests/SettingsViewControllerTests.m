@import UIKit;

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>

#import "DataStore.h"
#import "VenueBlacklistViewController.h"

#import "SettingsViewController.h"

SpecBegin(SettingsViewController)

__block SettingsViewController *subject;
__block UINavigationController *navController;

before(^{
    subject = [[SettingsViewController alloc] initWithDataStore:[[DataStore alloc] init]
               preferencesViewModel:nil];
    navController = [[UINavigationController alloc] initWithRootViewController:subject];

    [subject viewDidLoad];
});

describe(@"tapping on cells", ^{
    describe(@"tapping on the blacklist cell", ^{
        it(@"should show a VenueBlacklistViewController", ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [subject tableView:subject.tableView didSelectRowAtIndexPath:indexPath];
            expect(navController.topViewController).will.beInstanceOf(VenueBlacklistViewController.class);

            DataStore *dataStore = [(VenueBlacklistViewController *)navController.topViewController dataStore];
            expect(dataStore).notTo.beNil();
            expect(dataStore).to.equal(subject.dataStore);
        });
    });
});


SpecEnd