#import "FoursquareVenue.h"

@implementation FoursquareVenue

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"foursquareId": @"id",
             @"iconPrefix": @"categories.icon.prefix",
             @"iconSuffix": @"categories.icon.suffix",
             @"categoryId": @"categories.id",
             @"latitude": @"location.lat",
             @"longitude": @"location.lng",
             @"address": @"location.address",
             @"crossStreet": @"location.crossStreet"};
}

- (NSURL *)iconURL {
    NSString *url = [NSString stringWithFormat:@"%@bg_64%@", self.iconPrefix.firstObject, self.iconSuffix.firstObject];
    return [NSURL URLWithString:url];
}
@end
