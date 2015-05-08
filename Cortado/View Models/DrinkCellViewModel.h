#import "RVMViewModel.h"

@class Drink;

@interface DrinkCellViewModel : RVMViewModel

@property (readonly, nonatomic, strong) Drink *drink;

@property (readonly) NSString *title;
@property (readonly) NSString *subtitle;
@property (readonly) NSString *timestamp;

@property (readonly, nonatomic, assign) BOOL isPlaceholder;

- (id)initWithDrink:(Drink *)drink;

@end
