@import UIKit;
#import <IntentKit/INKWebViewController.h>

#import "ImageAttributionViewController.h"

@interface ImageAttributionViewController ()

@end

@implementation ImageAttributionViewController

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSURL *url = [NSURL URLWithString:cell.reuseIdentifier];

    INKWebViewController *webViewController = [[INKWebViewController alloc] init];
    [webViewController loadURL:url];

    // TODO: INKWebViewController should be more configurable re: showing/hiding the done button
    webViewController.navigationItem.rightBarButtonItem = nil;

    [self.navigationController pushViewController:webViewController animated:YES];
}

@end
