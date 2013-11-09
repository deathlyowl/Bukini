//
//  Books.h
//  Exlibris
//
//  Created by Paweł Ksieniewicz on 08.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BOOKS_UPDATED @"Books updated"

@interface Book : NSObject <NSCoding, UITableViewDataSource, UISearchBarDelegate>

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *author;
@property(nonatomic, retain) NSString *publisher;

+ (NSMutableArray *) all;
+ (void)saveQuiet:(BOOL) isQuiet;

+ (void) sort;

+ (void) addBook:(Book *) book;
+ (void) removeBook:(Book *) book;

+ (void) saveBook:(Book *) newBook
         overBook:(Book *) oldBook;

+ (Book *) bookForIndexPath:(NSIndexPath *)indexPath;

+ (Book *) bookWithVolumeInfoDictionary:(NSDictionary *)volumeInfo;

+ (void) importArchive:(NSData *)archive;

@end
