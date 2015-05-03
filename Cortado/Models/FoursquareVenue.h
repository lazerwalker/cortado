#import <Mantle/Mantle.h>

@interface FoursquareVenue : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *foursquareId;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

@property (nonatomic, readonly) NSURL *iconURL;

@property (nonatomic, strong) NSArray *categoryId;
@property (nonatomic, strong) NSArray *iconPrefix;
@property (nonatomic, strong) NSArray *iconSuffix;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *crossStreet;

@end
