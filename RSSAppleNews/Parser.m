//
//  Parser.m
//  RSSAppleNews
//
//  Created by ed8009 on 14.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import "Parser.h"

@interface Parser ()

@property (nonatomic, strong) NSString * currentElement;
@property (nonatomic, strong) NSMutableString * currentDescription;
@property (nonatomic, strong) NSMutableString *currentTitle;
@property (nonatomic, strong) NSMutableString *pubDate;
@property (nonatomic, strong) NSMutableString *currentLink;
@property (nonatomic, strong) NSArray* newsCoreData;
@property (nonatomic, strong) NSMutableArray *news;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation Parser

+ (instancetype)sharedMyManagerParser {
    static Parser *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[[self class] alloc] init];
    });
    
    return sharedMyManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = delegate.managedObjectContext;
    }
    
    return self;
}

- (void)startParser:(NSMutableData *)data {
    self.news = [NSMutableArray array];
    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:data];
    rssParser.delegate = self;
    [rssParser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(nonnull NSDictionary<NSString *,NSString *> *)attributeDict {
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
    }
    else if ([self.currentElement isEqualToString:@"pubDate"]) {
        [self.pubDate appendString:string];
    }
    else if ([self.currentElement isEqualToString:@"description"]) {
        [self.currentDescription appendString:string];
    }
    else if ([self.currentElement isEqualToString:@"link"]) {
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

- (BOOL)newsDatabaseEqualTo:(NSString *)link {
    for (int i = 0; i < self.news.count; i++) {
        if ([link isEqualToString:self.news[i][@"link"]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self getNewsFromDatabase];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (self.newsCoreData.count != 0) {
        for (int i = 0; i < self.news.count; i++) {
            
            NewsRSS *newsRSS = self.newsCoreData[i];
            
            if ([self newsDatabaseEqualTo:newsRSS.newsLink] == NO) {
                [self saveDataBse:self.news[i]];
            }
        }
    }
    else {
        for(NSDictionary *item in self.news) {
            [self saveDataBse:item];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ParserDidFinish" object:nil];
}

- (void)saveDataBse:(NSDictionary *)newsItem {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    NSString *str = [NSString stringWithFormat:@"%@",[newsItem objectForKey:@"pubDate"]];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSDate *date =  [dateFormat dateFromString:str ];
    
    NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"NewsRSS" inManagedObjectContext:context];
    [newDevice setValue:[newsItem objectForKey:@"title"] forKey:@"newsTitle"];
    [newDevice setValue:[newsItem objectForKey:@"description"] forKey:@"newsDescription"];
    [newDevice setValue:date forKey:@"newsDate"];
    [newDevice setValue:[newsItem objectForKey:@"link"] forKey:@"newsLink"];
    
    NSError *error;
    
    if (![context save:&error]) {
        NSLog(@"Can't save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"%@", parseError);
}

- (NSArray *)getNewsFromDatabase {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"NewsRSS"];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"newsDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sort, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    self.newsCoreData = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return self.newsCoreData;
}

@end
