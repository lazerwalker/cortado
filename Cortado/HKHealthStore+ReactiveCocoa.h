@import HealthKit;

@class RACSignal;

@interface HKHealthStore (ReactiveCocoa)

- (RACSignal *)rac_queryWithSampleType:(HKSampleType *)sampleType
                         predicate:(NSPredicate *)predicate
                             limit:(NSUInteger)limit
                   sortDescriptors:(NSArray *)sortDescriptors;

@end
