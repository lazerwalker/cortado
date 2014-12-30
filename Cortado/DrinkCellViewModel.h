#import "RVMViewModel.h"

@class Drink;

@interface DrinkCellViewModel : RVMViewModel

@property (readonly, nonatomic, strong) Drink *drink;

@property (readonly) NSString *title;
@property (readonly) NSString *subtitle;

- (id)initWithDrink:(Drink *)drink;

@end
