@import Foundation;

@class DataStore;

@interface OverviewViewModel : NSObject

@property (readonly, nonatomic, strong) NSString *todayCount;
@property (readonly, nonatomic, strong) NSString *averageCount;

- (id)initWithDataStore:(DataStore *)dataStore;

@end
