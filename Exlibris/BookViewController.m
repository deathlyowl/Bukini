//
//  NewBookViewController.m
//  Bukini
//
//  Created by Paweł Ksieniewicz on 09.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import "BookViewController.h"

@interface BookViewController () <UIAlertViewDelegate> {
    UIAlertView *missingAlert;
}

@end

@implementation BookViewController
@synthesize book;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    missingAlert = [[UIAlertView alloc] initWithTitle:@"Błąd"
                                              message:@"Czegoś brakuje"
                                             delegate:self
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil];
    
    if (book)
    {
        [_authorField setText:book.author];
        [_titleField setText:book.title];
        [_publisherField setText:book.publisher];
        
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void) selectFirstEmptyField{
    if      (!_authorField.text.length)     [_authorField becomeFirstResponder];
    else if (!_titleField.text.length)      [_titleField becomeFirstResponder];
    else if (!_publisherField.text.length)  [_publisherField becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self selectFirstEmptyField];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self selectFirstEmptyField];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)save:(id)sender {
    if (!_authorField.text.length || !_titleField.text.length || !_publisherField.text.length)
    {
        [missingAlert show];
    }
    else
    {
        if (!book)
        {
            // New Book
            book = Book.new;
            book.author = _authorField.text;
            book.title = _titleField.text;
            book.publisher = _publisherField.text;
            
            [Book addBook:book];
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
        }
        else
        {
            // Edit book
            Book *newBook = Book.new;
            newBook.author = _authorField.text;
            newBook.title = _titleField.text;
            newBook.publisher = _publisherField.text;
            
            [Book saveBook:newBook
                  overBook:book];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (IBAction)nextField:(id)sender {
    if (sender == _authorField) [_titleField becomeFirstResponder];
    if (sender == _titleField) [_publisherField becomeFirstResponder];
}

@end
