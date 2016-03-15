//
//  ReadRssTableViewController.m
//  RSSAppleNews
//
//  Created by ed8009 on 09.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import "ReadRssTableViewController.h"

@interface ReadRssTableViewController ()

@property (nonatomic, strong) Parser *sharedMyManagerParser;
@property (nonatomic, strong) LoadingData *sharedMyManagerLoading;
@property (nonatomic, strong) NSArray* newsCoreData;

@end

@implementation ReadRssTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Apple RSS";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadingFinishLoading:) name:@"LoadingFinish" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parserDidFinish:) name:@"ParserDidFinish" object:nil];

    self.sharedMyManagerLoading = [LoadingData sharedMyManagerLoading];
    [self.sharedMyManagerLoading startConnction:[NSURL URLWithString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"]];

    self.sharedMyManagerParser = [Parser sharedMyManagerParser];
    self.newsCoreData = [self.sharedMyManagerParser fetchedResultsControllerr];
    
    [self.tableView reloadData];
}

- (void)loadingFinishLoading:(NSNotification*)notification {
    [self.sharedMyManagerParser startParser:[notification object]];
}

- (void)parserDidFinish:(NSNotification*)notification {
    self.newsCoreData = [self.sharedMyManagerParser fetchedResultsControllerr];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.newsCoreData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    TableCellCustom *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
            
        cell.currentTitle.text = @"";
        cell.currentDescription.text = @"";
        cell.currentDate.text = @"";
        return cell;
    }

    NewsRSS *newsCoreData = [self.newsCoreData objectAtIndex:indexPath.row];
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"EEE, dd MMM yyyy HH:mm zzz"];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    NSString *localDateString = [df stringFromDate:newsCoreData.newsDate];

    cell.currentTitle.text = newsCoreData.newsTitle;
    cell.currentDescription.text = newsCoreData.newsDescription;
    cell.currentDate.text = localDateString;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.estimatedRowHeight = 75;
    tableView.rowHeight = UITableViewAutomaticDimension;
    
    return UITableViewAutomaticDimension;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"browserSeque"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NewsRSS *newsCoreData = [self.newsCoreData objectAtIndex:indexPath.row];

        BrowserViewController *browser = [segue destinationViewController];
        browser.url = [NSString stringWithFormat:@"%@",newsCoreData.newsLink];
    }
}

@end
