#import <Mantle/Mantle.h>

#import "DrinkCategory.h"

#import "DrinkCategoryList.h"

@implementation DrinkCategoryList

- (id)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (!self) return nil;

    NSError *error;

    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    _categories = [MTLJSONAdapter modelsOfClass:DrinkCategory.class fromJSONArray:json error:&error];

    return self;
}

- (id)initWithDefaultList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"drinks" ofType:@"json"];

    return [self initWithFilePath:path];
}

@end
