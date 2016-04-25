//
//  WorkingWithCoreData.m
//  RSSAppleNews
//
//  Created by ed8009 on 24.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import "WorkingWithCoreData.h"

@interface WorkingWithCoreData ()

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation WorkingWithCoreData

+ (instancetype)sharedMyManagerCoreData {
    static WorkingWithCoreData *sharedMyManager = nil;
    
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addRSSFeedName:(NSString *)nameFeed linkFeed:(NSString *)linkFeed {
    RSSnews *rssnews = [NSEntityDescription insertNewObjectForEntityForName:@"RSSnews" inManagedObjectContext:self.managedObjectContext];
    
    rssnews.nameRSS = nameFeed;
    rssnews.linkRSS = linkFeed;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"couldn't save: %@", [error localizedDescription]);
    }
    [[LoadingData sharedMyManagerLoading] startConnection:[NSURL URLWithString:linkFeed]];
}

- (NSArray *)getAllRSSRecords {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RSSDetails" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor= [[NSSortDescriptor alloc]initWithKey:@"newsDate" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (NSArray *)getAllCategories {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RSSnews" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor= [[NSSortDescriptor alloc]initWithKey:@"nameRSS" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    RSSnews *rssCatalog = (RSSnews*)array.firstObject;

    NSLog(@"%@ %ld", rssCatalog.nameRSS, rssCatalog.details.count);

    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (void)deleteCategories:(RSSnews *)objectRSS {
    
    [self.managedObjectContext deleteObject:objectRSS];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (NSArray *)getDetailOfSelectedCategory:(NSString *)linkRSS {    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RSSDetails" inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor *sortDescriptor= [[NSSortDescriptor alloc]initWithKey:@"newsDate" ascending:NO];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rss.linkRSS == %@", linkRSS];

    fetchRequest.entity = entity;
    fetchRequest.sortDescriptors = @[sortDescriptor];
    fetchRequest.predicate = predicate;
    
    NSError *error;
    NSLog(@"%@", [self.managedObjectContext executeFetchRequest:fetchRequest error:&error]);
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (NSArray *)getRSSByURL:(NSString *)linkRSS {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RSSnews" inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"linkRSS == %@", linkRSS];
    
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    
    NSError *error;
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (void)saveDataBase:(NSDictionary *)newsItem urlRSS:(NSString *)urlRSS {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    static NSDateFormatter * dateFormatter;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    }
    NSLog(@"%@",newsItem[@"pubDate"]);
    NSDate *date =  [dateFormatter dateFromString:newsItem[@"pubDate"]];
        
    RSSDetails *rssdetails = [NSEntityDescription insertNewObjectForEntityForName:@"RSSDetails" inManagedObjectContext:context];
    
    rssdetails.newsTitle = newsItem[@"title"];
    rssdetails.newsLink = newsItem[@"link"];
    rssdetails.newsDate = date;
    rssdetails.newsDescription = newsItem[@"description"];
    
    RSSnews *selectedAccount = [self getRSSByURL:urlRSS].firstObject;
    
    [selectedAccount addDetailsObject:rssdetails];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"couldn't save: %@", [error localizedDescription]);
    }
}

- (BOOL)essenceExistsInDatabase:(NSString *)link rssEntity:(NSString *)rssEntity {
    NSEntityDescription *entity = [NSEntityDescription entityForName:rssEntity inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setFetchLimit:1];
    
    if ([rssEntity isEqualToString:@"RSSDetails"]) {
        [request setPredicate:[NSPredicate predicateWithFormat:@"(newsLink == %@)", link]];
    }
    else if ([rssEntity isEqualToString:@"RSSnews"]) {
        [request setPredicate:[NSPredicate predicateWithFormat:@"(linkRSS == %@)", link]];
    }
    
    NSError *error = nil;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&error];
    
    if (count) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
