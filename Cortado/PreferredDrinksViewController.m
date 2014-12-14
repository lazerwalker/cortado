#import <Mantle/Mantle.h>

#import "Beverage.h"

#import "PreferredDrinksViewController.h"

static NSString * const CellIdentifier = @"cell";

@interface PreferredDrinksViewController ()

@property (readonly, nonatomic, strong) NSArray *drinks;

@end

@implementation PreferredDrinksViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults valueForKey:@"preferredDrinks"];
    _drinks = [NSKeyedUnarchiver unarchiveObjectWithData:data] ?: @[];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"My Drinks";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Check" style:UIBarButtonItemStylePlain target:UIApplication.sharedApplication.delegate action:@selector(checkCurrentLocation)];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL beverageExists = (self.drinks.count > indexPath.section && self.drinks[indexPath.section] != nil);
    if (beverageExists) {
        Beverage *beverage = self.drinks[indexPath.section];
        cell.textLabel.text = beverage.name;
    } else {
        cell.textLabel.text = @"No drink selected.";
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Drink #%@", @(section + 1)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}


@end
