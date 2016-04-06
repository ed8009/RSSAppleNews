//
//  ReadRssTableViewController.m
//  RSSAppleNews
//
//  Created by ed8009 on 09.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import "ReadRssTableViewController.h"
#import "TableCellCustom.h"
#import "RSSnews.h"
#import "RSSDetails.h"
#import "RSSnews+CoreDataProperties.h"

@interface ReadRssTableViewController ()

@property (nonatomic, strong) NSArray* newsCoreData;

@end

@implementation ReadRssTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"General RSS feed";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadingFinishLoadingAllRSS:) name:@"loadingFinishLoadingReadRSS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parserDidFinish:) name:@"ParserDidFinishReadRSS" object:nil];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getLatestLoans2)
                  forControlEvents:UIControlEventValueChanged];
    
    self.newsCoreData = [[WorkingWithCoreData sharedMyManagerCoreData] getAllRSSRecords];

    NSLog(@"%ld", self.newsCoreData.count);
}

- (void)getLatestLoans2 {
    NSArray *catalogRSS = [[WorkingWithCoreData sharedMyManagerCoreData] getAllCategories];
    
    if (catalogRSS.count != 0) {
        for (NSArray *item in catalogRSS) {
            RSSnews *rssCatalog = (RSSnews*)item;
            [[LoadingData sharedMyManagerLoading] startConnection:[NSURL URLWithString:rssCatalog.linkRSS]];
        }
    }
    else {
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

- (void)reloadData {
    [self.tableView reloadData];
    
    if (self.refreshControl) {
        
        NSString *title = [NSString stringWithFormat:@"Please Wait"];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.newsCoreData = [[WorkingWithCoreData sharedMyManagerCoreData] getAllRSSRecords];
    [self.tableView reloadData];
}

#pragma mark - Private Methods

- (void)loadingFinishLoadingAllRSS:(NSNotification*)notification {
    [[Parser sharedMyManagerParser] startParser:[notification object] urlRSS:nil];
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)parserDidFinish:(NSNotification*)notification {
    self.newsCoreData = [[WorkingWithCoreData sharedMyManagerCoreData] getAllRSSRecords];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.newsCoreData.count != 0) {
        [self.tableView setBackgroundView:nil];
        return self.newsCoreData.count;
    }
    else {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh or add a new rss feed";
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

    TableCellCustom *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self setUpCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSString *)createStringFromDate:(NSDate *)date {
    static NSDateFormatter * dateFormatter;
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT]];
    }
    
    return [dateFormatter stringFromDate:date];
}

- (void)setUpCell:(TableCellCustom *)cell atIndexPath:(NSIndexPath *)indexPath {
    RSSDetails *newsCoreData = self.newsCoreData[indexPath.row];
    cell.currentTitle.text = newsCoreData.rss.nameRSS;//newsCoreData.newsTitle;
    cell.currentDescription.text = newsCoreData.newsDescription;
    cell.currentDate.text = [self createStringFromDate:newsCoreData.newsDate];
}

 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     RSSDetails *newsCoreData = self.newsCoreData[indexPath.row];
     
     static TableCellCustom *cell = nil;
     static dispatch_once_t onceToken;
     
     dispatch_once(&onceToken, ^{
         cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
     });
     
     CGFloat topPaddingTitle = CGRectGetMinY(cell.currentTitle.frame);
     CGFloat topPaddingDescription = CGRectGetMinY(cell.currentDescription.frame) - CGRectGetHeight(cell.currentTitle.frame) - topPaddingTitle;
     CGFloat topPaddingDate = CGRectGetMinY(cell.currentDate.frame) - CGRectGetHeight(cell.currentDescription.frame) - CGRectGetMinY(cell.currentDescription.frame);
     
     CGFloat bottomPadding = CGRectGetHeight(cell.frame) - (topPaddingTitle + topPaddingDescription + topPaddingDate + CGRectGetHeight(cell.currentTitle.frame) + CGRectGetHeight(cell.currentDescription.frame) + CGRectGetHeight(cell.currentDate.frame));
 
     CGFloat getCellHeightWithTextTitle = CGRectGetHeight([newsCoreData.newsTitle boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.tableView.frame) - CGRectGetMinX(cell.currentTitle.frame)*2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: cell.currentTitle.font} context:nil]);
 
     CGFloat getCellHeightWithTextDescription = CGRectGetHeight([newsCoreData.newsDescription boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.tableView.frame) - CGRectGetMinX(cell.currentDescription.frame)*2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: cell.currentDescription.font} context:nil]);
 
     CGFloat getCellHeightWithTextDate = CGRectGetHeight([[self createStringFromDate:newsCoreData.newsDate] boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.tableView.frame) - CGRectGetMinX(cell.currentDate.frame)*2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: cell.currentDate.font} context:nil]);

     CGFloat value = topPaddingTitle + topPaddingDescription + topPaddingDate + getCellHeightWithTextTitle + getCellHeightWithTextDescription + getCellHeightWithTextDate + bottomPadding*2;

     return value;
 }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"browserSeque"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RSSDetails *newsCoreData = self.newsCoreData[indexPath.row];
        BrowserViewController *browser = [segue destinationViewController];
        browser.url = newsCoreData.newsLink;
    }
}

@end