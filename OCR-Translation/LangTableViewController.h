//
//  LangTableViewController.h
//  OCR-Translation
//
//  Created by Brooke Kelsey on 2/29/16.
//  Copyright © 2016 26775. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LangTableViewController : UITableViewController

@property (strong, nonatomic) UIImage *takenImage;
@property (strong, nonatomic) NSString *selectedLanguage;
@property (strong, nonatomic) NSString *selectedLangCode;

@end
