#import "DrinkType.h"

#import "DrinkCategory.h"

@implementation DrinkCategory

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{};
}

+ (NSValueTransformer *)drinkTypesJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *typeDicts) {
        return [MTLJSONAdapter modelsOfClass:DrinkType.class fromJSONArray:typeDicts error:nil];
    } reverseBlock:^(NSArray *drinkTypes) {
        return [MTLJSONAdapter JSONArrayFromModels:drinkTypes];
    }];
}

@end
