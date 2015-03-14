#import "MapAnnotation.h"

@implementation MapAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title {
    self = [super init];
    if (!self) return nil;

    _coordinate = coordinate;
    _title = title;

    return self;
}
@end
