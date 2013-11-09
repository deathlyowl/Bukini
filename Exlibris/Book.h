//
//  Books.h
//  Exlibris
//
//  Created by Paweł Ksieniewicz on 08.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BOOKS_UPDATED @"Books updated"

@interface Book : NSObject <NSCoding>

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *author;
@property(nonatomic, retain) NSString *publisher;

+ (NSMutableArray *) all;
+ (void)saveQuiet:(BOOL) isQuiet;

+ (void) addBook:(Book *) book;
+ (void) removeBook:(Book *) book;

+ (void) saveBook:(Book *) newBook
         overBook:(Book *) oldBook;

@end
