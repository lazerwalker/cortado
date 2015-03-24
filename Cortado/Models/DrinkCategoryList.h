#import <Foundation/Foundation.h>

@interface DrinkCategoryList : NSObject

- (id)initWithFilePath:(NSString *)filePath NS_DESIGNATED_INITIALIZER;
- (id)initWithDefaultList;

@property (readonly, nonatomic, strong) NSArray *categories;

@end
