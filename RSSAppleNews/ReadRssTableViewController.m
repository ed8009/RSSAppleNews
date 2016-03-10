//
//  ReadRssTableViewController.m
//  RSSAppleNews
//
//  Created by ed8009 on 09.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import "ReadRssTableViewController.h"
#import "TableCellCustom.h"
#import "BrowserViewController.h"
#import "NewsRSS.h"

@interface ReadRssTableViewController ()

@property (nonatomic) NSMutableData *rssData;
@property (nonatomic) NSMutableArray *news;
@property (nonatomic) NSString * currentElement;
@property (nonatomic) NSMutableString * currentDescription;
@property (nonatomic) NSMutableString *currentTitle;
@property (nonatomic) NSMutableString *pubDate;
@property (nonatomic) NSMutableString *currentLink;

@end

@implementation ReadRssTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Apple RSS";

    [self readDataBase];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *url = [NSURL URLWithString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        self.rssData = [NSMutableData data];
    } else {
        NSLog(@"Connection failed");
    }
}

- (void)readDataBase{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"NewsRSS"];
    self.newsCoreData = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - Connection

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.rssData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.news = [NSMutableArray array];
    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:self.rssData];
    rssParser.delegate = self;
    [rssParser parse];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

#pragma mark - Parser

- (void)parser:(NSXMLParser *)parser didStartElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(nonnull NSDictionary<NSString *,NSString *> *)attributeDict{
    
    self.currentElement = elementName;
    if ([elementName isEqualToString:@"item"]) {
        self.currentTitle = [NSMutableString string];
        self.pubDate = [NSMutableString string];
        self.currentDescription = [NSMutableString string];
        self.currentLink = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([self.currentElement isEqualToString:@"title"]) {
        [self.currentTitle appendString:string];
    } else if ([self.currentElement isEqualToString:@"pubDate"]) {
        [self.pubDate appendString:string];
    }else if ([self.currentElement isEqualToString:@"description"]) {
        [self.currentDescription appendString:string];
    }else if ([self.currentElement isEqualToString:@"link"]){
        [self.currentLink appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"item"]) {
        NSDictionary *newsItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.currentTitle, @"title",
                                  self.pubDate, @"pubDate",
                                  self.currentDescription, @"description",
                                  self.currentLink, @"link", nil];
        [self.news addObject:newsItem];
        self.currentTitle = nil;
        self.pubDate = nil;
        self.currentElement = nil;
        self.currentDescription = nil;
        self.currentLink = nil;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        if (self.newsCoreData.count != 0) {
            for (int i = 0; i < self.news.count; i++){
                
                NewsRSS *device = self.newsCoreData[i];
                
                if (![device.newsLink isEqualToString:self.news[i][@"link"]]) {
                    
                    [self saveDataBse:self.news[i]];
                    
                }
            }
        } else {
            for(NSDictionary *item in self.news){
                
                [self saveDataBse:item];
            }
        }
    [self readDataBase];
}

- (void)saveDataBse:(NSDictionary *)newsItem{
    NSManagedObjectContext *context = [self managedObjectContext];

    NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"NewsRSS" inManagedObjectContext:context];
    [newDevice setValue:[newsItem objectForKey:@"title"] forKey:@"newsTitle"];
    [newDevice setValue:[newsItem objectForKey:@"description"] forKey:@"newsDescription"];
    [newDevice setValue:[newsItem objectForKey:@"pubDate"] forKey:@"newsDate"];
    [newDevice setValue:[newsItem objectForKey:@"link"] forKey:@"newsLink"];
    
    NSError *error = nil;
    
    if(![context save:&error]){
        NSLog(@"Can't save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"%@", parseError);
}

#pragma mark - TableView

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
        
        NSLog(@"error");
        
        cell.currentTitle.text = @"";
        cell.currentDescription.text = @"";
        cell.currentDate.text = @"";
        return cell;
    }

    NewsRSS *newsCoreData = [self.newsCoreData objectAtIndex:indexPath.row];
    
    cell.currentTitle.text = newsCoreData.newsTitle;
    cell.currentDescription.text = newsCoreData.newsDescription;
    cell.currentDate.text = newsCoreData.newsDate;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    tableView.estimatedRowHeight = 75;
    tableView.rowHeight = UITableViewAutomaticDimension;
    
    return UITableViewAutomaticDimension;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"browserSeque"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NewsRSS *newsCoreData = [self.newsCoreData objectAtIndex:indexPath.row];

        BrowserViewController *browser = [segue destinationViewController];
        browser.url = [NSString stringWithFormat:@"%@",newsCoreData.newsLink];
    }
}





@end
