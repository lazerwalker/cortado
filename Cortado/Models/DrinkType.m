#import "DrinkSubtype.h"

#import "DrinkType.h"

@implementation DrinkType

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{};
}

+ (NSValueTransformer *)subtypesJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *subtypeDicts) {
        return [MTLJSONAdapter modelsOfClass:DrinkSubtype.class fromJSONArray:subtypeDicts error:nil];
    } reverseBlock:^(NSArray *subtypes) {
        return [MTLJSONAdapter JSONArrayFromModels:subtypes];
    }];
}


@end
