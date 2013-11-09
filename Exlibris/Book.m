//
//  Books.m
//  Exlibris
//
//  Created by Paweł Ksieniewicz on 08.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import "Book.h"

@implementation Book

@synthesize title, author, publisher;

+ (NSMutableArray *)all{
    static dispatch_once_t once;
    static NSMutableArray *allBooks;
    dispatch_once(&once, ^{
        allBooks = [[NSMutableArray alloc] init];
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:self.class.description];
        if (data)
        {
            // Loading from file
            allBooks = [NSKeyedUnarchiver unarchiveObjectWithData:data];

            NSLog(@"[Book]\tThey're %i books in my memories!", allBooks.count);
        }
        else
        {
            allBooks = NSMutableArray.new;
            NSLog(@"[Book]\tLoading default DB");
        }
    });
    return allBooks;
}

+ (void)addBook:(Book *)book{
    NSLog(@"[Book]\tAdding book: %@", book);
    [self.all addObject:book];
    [self saveQuiet:NO];
}

+ (void)removeBook:(Book *)book{
    NSLog(@"Before: %i", self.all.count);
    NSLog(@"[Book]\tRemoving book: %@", book);
    [self.all removeObject:book];
    [self saveQuiet:YES];
    NSLog(@"After: %i", self.all.count);
}

+ (void)saveBook:(Book *)newBook
        overBook:(Book *)oldBook
{
    [self.all replaceObjectAtIndex:[self.all indexOfObject:oldBook]
                        withObject:newBook];
    [self saveQuiet:NO];
}

+ (void)saveQuiet:(BOOL) isQuiet
{
    //Saving it
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.all]
                                              forKey:self.class.description];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!isQuiet) [[NSNotificationCenter defaultCenter] postNotificationName:BOOKS_UPDATED object:nil];
    
    NSLog(@"[Book]\tBooks saved");
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:title forKey:@"title"];
    [coder encodeObject:author forKey:@"author"];
    [coder encodeObject:publisher forKey:@"publisher"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    title = [coder decodeObjectForKey:@"title"];
    author = [coder decodeObjectForKey:@"author"];
    publisher = [coder decodeObjectForKey:@"publisher"];
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ — %@", author, title];
}

@end
