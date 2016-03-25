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
    if (![string isEqualToString:@"\n"]){
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
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"item"]) {
        if (![self essenceExistsInDatabase:self.currentLink]) {
            NSDictionary *newsItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                      self.currentTitle, @"title",
                                      self.pubDate, @"pubDate",
                                      self.currentDescription, @"description",
                                      self.currentLink, @"link", nil];
            [self saveDataBase:newsItem];

            self.currentTitle = nil;
            self.pubDate = nil;
            self.currentElement = nil;
            self.currentDescription = nil;
            self.currentLink = nil;
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ParserDidFinish" object:nil];
}

- (void)saveDataBase:(NSDictionary *)newsItem {
    NSManagedObjectContext *context = self.managedObjectContext;

    static NSDateFormatter * dateFormatter;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    }
    NSDate *date =  [dateFormatter dateFromString:newsItem[@"pubDate"]];
    
    NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"NewsRSS" inManagedObjectContext:context];
    [newDevice setValue:newsItem[@"title"] forKey:@"newsTitle"];
    [newDevice setValue:newsItem[@"description"] forKey:@"newsDescription"];
    [newDevice setValue:date forKey:@"newsDate"];
    [newDevice setValue:newsItem[@"link"] forKey:@"newsLink"];
    
    NSError *error;

    if (![context save:&error]) {
        NSLog(@"Can't save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"%@", parseError);
}

- (BOOL)essenceExistsInDatabase:(NSString *)link {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsRSS" inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"newsLink == %@", link];
    
    NSError *error = nil;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&error];
    
    if (count) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSArray *)getNewsFromDatabase {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"NewsRSS"];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"newsDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sort, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    
    return [managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

@end
