@import Foundation;
@import MapKit;

@interface MapAnnotation : NSObject<MKAnnotation>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly, copy) NSString *title;

@end
