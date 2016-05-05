//
//  ViewController.h
//  infojobOCR
//
//  Created by Paolo Tagliani on 08/06/12.
//  Copyright (c) 2012 26775. All rights reserved.
//

//
//  ImgProcVController.h
//  OCR-Translation
//  Modified on 05/06/16 by Brooke Kelsey and Gibson Cook
//

#import <UIKit/UIKit.h>
#import "ImageProcessingProtocol.h"

@interface ImgProcessController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>{
    UIImagePickerController *mediaPicker;
    UIImage *takenImage;
    UIImage *processedImage;
}

@property (strong, nonatomic) IBOutlet UITextField *destLanguage;
@property (strong, nonatomic) NSString *destLangCode;
@property (strong, nonatomic) NSString *destLangLabel;
@property (strong, nonatomic) IBOutlet UIButton *process;
@property (strong, nonatomic) IBOutlet UIImageView *resultView;
@property (strong, nonatomic) id <ImageProcessingProtocol> imageProcessor;
@property (strong, nonatomic) IBOutlet UIButton *read;
@property (strong,nonatomic) UIImage *takenImage;
@property (strong,nonatomic) UIImage *processedImage;
@property (strong, nonatomic) IBOutlet UIButton *confirmLanguage;
@property (strong, nonatomic) IBOutlet UIButton *takeNewPhoto;

- (IBAction)Pre:(id)sender;
- (IBAction)OCR:(id)sender;

- (IBAction)confirmLanguage:(id)sender;
- (IBAction)takeNewPhoto:(id)sender;

@end