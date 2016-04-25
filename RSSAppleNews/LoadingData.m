//
//  LoadingData.m
//  RSSAppleNews
//
//  Created by ed8009 on 14.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import "LoadingData.h"

@implementation LoadingData

+ (instancetype)sharedMyManagerLoading {
    static LoadingData *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[[self class] alloc] init];
    });
    
    return sharedMyManager;
}

- (void)startConnection:(NSURL *)url{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        self.rssData = [NSMutableData data];
    }
    else {
        NSLog(@"Connection failed");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.rssData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *result = [[NSString alloc] initWithData:self.rssData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",result);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingFinishUserRSS" object:self.rssData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadingFinishLoadingReadRSS" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingCatalogRSS" object:self.rssData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ParserDidFinishUserRSS" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ParserDidFinishReadRSS" object:nil];
}

@end