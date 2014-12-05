#import "FoursquareVenue.h"

@implementation FoursquareVenue

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"foursquareId": @"id",
             @"iconPrefix": @"categories.icon.prefix",
             @"iconSuffix": @"categories.icon.suffix",
             @"latitude": @"location.lat",
             @"longitude": @"location.lng"};
}

- (NSURL *)iconURL {
    NSString *url = [NSString stringWithFormat:@"%@bg_64%@", self.iconPrefix.firstObject, self.iconSuffix.firstObject];
    return [NSURL URLWithString:url];
}
@end
