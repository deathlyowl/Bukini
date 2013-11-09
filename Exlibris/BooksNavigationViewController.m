//
//  BooksNavigationViewController.m
//  Exlibris
//
//  Created by Paweł Ksieniewicz on 08.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import "BooksNavigationViewController.h"

@interface BooksNavigationViewController ()

@end

@implementation BooksNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.tabBarItem setSelectedImage:[UIImage imageNamed:@"bookmarks_filled"]];
    [self.tabBarItem setImage:[UIImage imageNamed:@"bookmarks"]];
}

@end
