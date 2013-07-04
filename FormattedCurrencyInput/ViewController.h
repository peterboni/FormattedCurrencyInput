//
//  ViewController.h
//  FormattedCurrencyInput
//
//  Created by Peter Boni on 4/07/13.
//  Copyright (c) 2013 Peter Boni. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textField;
- (IBAction)valueButton:(id)sender;

@end
