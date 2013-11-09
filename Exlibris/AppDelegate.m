//
//  AppDelegate.m
//  Exlibris
//
//  Created by Paweł Ksieniewicz on 08.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import "AppDelegate.h"
#import "Book.h"
#import <DBChooser/DBChooser.h>

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation
{
    if ([[DBChooser defaultChooser] handleOpenURL:url]) return YES;
    [Book importArchive:[NSData dataWithContentsOfURL:url]];
    return YES;
}

@end
