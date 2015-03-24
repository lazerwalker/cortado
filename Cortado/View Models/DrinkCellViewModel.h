#import "RVMViewModel.h"

@class Drink;

@interface DrinkCellViewModel : RVMViewModel

@property (readonly, nonatomic, strong) Drink *drink;

@property (readonly) NSAttributedString *title;
@property (readonly) NSString *subtitle;
@property (readonly) NSString *timestamp;

- (id)initWithDrink:(Drink *)drink;

@end
