//
//  AddRSSFeedViewController.m
//  RSSAppleNews
//
//  Created by ed8009 on 23.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import "AddRSSFeedViewController.h"

@interface AddRSSFeedViewController ()

@end

@implementation AddRSSFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)add:(id)sender {
    
    if (![self.nameRSSField.text isEqualToString:@""] && ![self.linkRSSField.text isEqualToString:@""] && ![[WorkingWithCoreData sharedMyManagerCoreData] essenceExistsInDatabase:self.linkRSSField.text rssEntity:@"RSSnews"]) {
        [[WorkingWithCoreData sharedMyManagerCoreData] addRSSFeedName:self.nameRSSField.text linkFeed:self.linkRSSField.text];

        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please, fill in all fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil, nil];
        [alert show];
    }
}

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end