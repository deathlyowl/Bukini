//
//  Books.m
//  Exlibris
//
//  Created by Paweł Ksieniewicz on 08.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import "Books.h"

@implementation Books

+ (NSArray *)allBooks{
    static dispatch_once_t once;
    static NSArray *allBooks;
    dispatch_once(&once, ^{
        allBooks = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"books"
                                                                                    ofType:@"plist"]];
    });
    return allBooks;
}

@end
