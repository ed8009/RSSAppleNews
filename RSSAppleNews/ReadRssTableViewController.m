//
//  ReadRssTableViewController.m
//  RSSAppleNews
//
//  Created by ed8009 on 09.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import "ReadRssTableViewController.h"
#import "TableCellCustom.h"

@interface ReadRssTableViewController ()

@property (nonatomic, strong) NSArray* newsCoreData;

@end

@implementation ReadRssTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Apple RSS";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadingFinishLoading:) name:@"LoadingFinish" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parserDidFinish:) name:@"ParserDidFinish" object:nil];
    
    self.newsCoreData = [[Parser sharedMyManagerParser] getNewsFromDatabase];
    
    [[LoadingData sharedMyManagerLoading] startConnection:[NSURL URLWithString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"]];
}

#pragma mark - Private Methods

- (void)loadingFinishLoading:(NSNotification*)notification {
    [[Parser sharedMyManagerParser] startParser:[notification object]];
}

- (void)parserDidFinish:(NSNotification*)notification {
    self.newsCoreData = [[Parser sharedMyManagerParser] getNewsFromDatabase];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.newsCoreData.count;
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
    NewsRSS *newsCoreData = self.newsCoreData[indexPath.row];
    
    cell.currentTitle.text = newsCoreData.newsTitle;
    cell.currentDescription.text = newsCoreData.newsDescription;
    cell.currentDate.text = [self createStringFromDate:newsCoreData.newsDate];
}

 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     NewsRSS *newsCoreData = self.newsCoreData[indexPath.row];
     
     static TableCellCustom *cell = nil;
     static dispatch_once_t onceToken;
     
     dispatch_once(&onceToken, ^{
         cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
     });
     
     int topPaddingTitle = CGRectGetMinY(cell.currentTitle.frame);
     int topPaddingDescription = CGRectGetMinY(cell.currentDescription.frame);
     int topPaddingDate = CGRectGetMinY(cell.currentDate.frame);
 
     int bottomPadding = CGRectGetHeight(cell.frame) - (topPaddingTitle + topPaddingDescription + topPaddingDate + CGRectGetHeight(cell.currentTitle.frame) + CGRectGetHeight(cell.currentDescription.frame) + CGRectGetHeight(cell.currentDate.frame));
 
     CGFloat getCellHeightWithTextTitle = CGRectGetHeight([newsCoreData.newsTitle boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.tableView.frame) - CGRectGetMinX(cell.currentTitle.frame)*2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: cell.currentTitle.font} context:nil]);
 
     CGFloat getCellHeightWithTextDescription = CGRectGetHeight([newsCoreData.newsDescription boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.tableView.frame) - CGRectGetMinX(cell.currentDescription.frame)*2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: cell.currentDescription.font} context:nil]);
 
     CGFloat getCellHeightWithTextDate = CGRectGetHeight([[self createStringFromDate:newsCoreData.newsDate] boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.tableView.frame) - CGRectGetMinX(cell.currentDate.frame)*2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: cell.currentDate.font} context:nil]);

     CGFloat value = topPaddingTitle + topPaddingDescription + topPaddingDate + getCellHeightWithTextTitle + getCellHeightWithTextDescription + getCellHeightWithTextDate + bottomPadding;
     
     return value;
 }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"browserSeque"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NewsRSS *newsCoreData = self.newsCoreData[indexPath.row];

        BrowserViewController *browser = [segue destinationViewController];
        browser.url = [NSString stringWithFormat:@"%@",newsCoreData.newsLink];
    }
}

@end
