@import Foundation;

@class DataStore;

@interface OverviewViewModel : NSObject

@property (readonly, nonatomic, strong) NSString *todayCount;
@property (readonly, nonatomic, strong) NSString *averageCount;

@property (readonly, nonatomic, strong) NSString *todayDrinksText;
@property (readonly, nonatomic, strong) NSString *averageDrinksText;

- (id)initWithDataStore:(DataStore *)dataStore;

@end
