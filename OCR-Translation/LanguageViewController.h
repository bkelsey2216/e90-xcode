//
//  LanguageViewController.h
//  OCR-Translation
//
//  Created by Brooke Kelsey on 2/29/16.
//  Copyright © 2016 26775. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LanguageViewController : UIViewController{
        UIImage *takenImage;
}

@property (strong,nonatomic) UIImage *takenImage;
@property (strong, nonatomic) IBOutlet UIButton *confirm;

@end
