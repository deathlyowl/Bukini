//
//  DebtorViewController.m
//  Bukini
//
//  Created by Paweł Ksieniewicz on 09.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import "DebtorViewController.h"

@interface DebtorViewController ()

@end

@implementation DebtorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.tabBarItem setSelectedImage:[UIImage imageNamed:@"user_filled"]];
    [self.tabBarItem setImage:[UIImage imageNamed:@"user"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
