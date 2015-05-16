#import "DataStore.h"

#import "OverviewViewModel.h"

@interface OverviewViewModel ()

@property (readwrite, nonatomic, strong) DataStore *dataStore;

@property (readwrite, nonatomic, strong) NSString *todayCount;
@property (readwrite, nonatomic, strong) NSString *averageCount;

@end

@implementation OverviewViewModel

- (id)initWithDataStore:(DataStore *)dataStore {
    self = [super init];
    if (!self) return nil;

    return self;
}

- (NSString *)todayCount {
    return @"2";
}

- (NSString *)averageCount {
    return @"0-1";
}
@end
