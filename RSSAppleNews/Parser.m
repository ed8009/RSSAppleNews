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

- (void)startParser:(NSMutableData *)data urlRSS:(NSString *)urlRSS {
    self.urlRSS = urlRSS;
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

        if (![[WorkingWithCoreData sharedMyManagerCoreData] essenceExistsInDatabase:self.currentLink rssEntity:@"RSSDetails"]) {
            NSDictionary *newsItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                      self.currentTitle, @"title",
                                      self.pubDate, @"pubDate",
                                      self.currentDescription, @"description",
                                      self.currentLink, @"link", nil];
            [[WorkingWithCoreData sharedMyManagerCoreData] saveDataBase:newsItem urlRSS:self.urlRSS];

            self.currentTitle = nil;
            self.pubDate = nil;
            self.currentElement = nil;
            self.currentDescription = nil;
            self.currentLink = nil;
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ParserDidFinishUserRSS" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ParserDidFinishReadRSS" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ParserDidFinishCatalogRSS" object:nil];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"%@", parseError);
}

@end
