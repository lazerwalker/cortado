#import "DrinkCategory.h"
#import "DrinkCategoryList.h"
#import "DrinkType.h"

#import "DrinkSelectionViewController.h"

static NSString * const CellIdentifier = @"cell";

@interface DrinkSelectionViewController ()

@property (nonatomic, strong) NSArray *categories;

@end

@implementation DrinkSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.categories = [[[DrinkCategoryList alloc] initWithDefaultList] categories];

    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    DrinkCategory *category = self.categories[indexPath.section];
    DrinkType *type = category.drinkTypes[indexPath.row];
    cell.textLabel.text = type.name;
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.categories[section] name];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.categories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DrinkCategory *category = self.categories[section];
    return category.drinkTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
}

@end
