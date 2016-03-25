//
//  BrowserViewController.m
//  RSSAppleNews
//
//  Created by ed8009 on 09.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import "BrowserViewController.h"

@interface BrowserViewController()

@property (strong, nonatomic) IBOutlet UIWebView *myBrowser;
@property (strong, nonatomic) IBOutlet UILabel *labelErrorConnect;

@end

@implementation BrowserViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.labelErrorConnect.hidden = YES;
    self.myBrowser.delegate = self;
    
    NSString* webStringURL = [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.myBrowser loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webStringURL]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSLog(@"Start load");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSLog(@"Finish load");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@", error);

    self.labelErrorConnect.hidden = NO;
}

@end
