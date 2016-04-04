//
//  CatalogRSSFeedTableViewController.m
//  RSSAppleNews
//
//  Created by ed8009 on 23.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import "CatalogRSSFeedTableViewController.h"
#import "TableCellCustom.h"
#import "RSSnews.h"
#import "UserRSSFeedTableViewController.h"

@interface CatalogRSSFeedTableViewController ()

@property (nonatomic, strong) NSArray* catalogRSS;

@end

@implementation CatalogRSSFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Catalog RSS";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadingRSSToFinish:) name:@"LoadingCatalogRSS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parserDidFinish:) name:@"ParserDidFinishCatalogRSS" object:nil];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.catalogRSS = [[WorkingWithCoreData sharedMyManagerCoreData] getAllCategories];
    
    [self.tableView reloadData];
}

#pragma mark - Private Methods

- (void)loadingRSSToFinish:(NSNotification*)notification {
    RSSnews *rssCatalog = (RSSnews*)self.catalogRSS.firstObject;
    [[Parser sharedMyManagerParser] startParser:[notification object] urlRSS:rssCatalog.linkRSS];
}

- (void)parserDidFinish:(NSNotification*)notification {
    self.catalogRSS = [[WorkingWithCoreData sharedMyManagerCoreData] getAllCategories];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.catalogRSS.count != 0) {
        [self.tableView setBackgroundView:nil];
        return self.catalogRSS.count;
    }
    else {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = @"No readable rss feed. Please add a new rss feed";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];

        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    RSSnews *rssCatalog = (RSSnews*)self.catalogRSS[indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    cell.textLabel.text = rssCatalog.nameRSS;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu",rssCatalog.details.count];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        RSSnews *rssCatalog = (RSSnews*)self.catalogRSS[indexPath.row];

        [[WorkingWithCoreData sharedMyManagerCoreData] deleteCategories:rssCatalog];
        
        self.catalogRSS = [[WorkingWithCoreData sharedMyManagerCoreData] getAllCategories];
        
        [self.tableView endUpdates];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"userRSSSeque"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        RSSnews *rssCatalog = (RSSnews*)self.catalogRSS[indexPath.row];
        
        UserRSSFeedTableViewController *userRSS = [segue destinationViewController];
        userRSS.urlRSS = rssCatalog.linkRSS;
        userRSS.title = rssCatalog.nameRSS;
    }
}

@end
